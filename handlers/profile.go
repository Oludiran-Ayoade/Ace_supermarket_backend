package handlers

import (
	"ace-mall-backend/utils"
	"database/sql"
	"fmt"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// GetProfile returns user profile based on permissions
func GetProfile(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	requesterID := c.GetString("user_id")
	targetUserID := c.Param("user_id")

	// If no target specified, return own profile
	if targetUserID == "" {
		targetUserID = requesterID
	}

	// Check permissions
	permissionLevel, err := utils.CanViewProfile(db, requesterID, targetUserID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to check permissions"})
		return
	}

	if permissionLevel == utils.PermissionNone {
		c.JSON(http.StatusForbidden, gin.H{"error": "You don't have permission to view this profile"})
		return
	}

	// Get profile based on permission level
	user, err := utils.GetUserProfile(db, targetUserID, permissionLevel)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch profile: " + err.Error()})
		return
	}

	// Log document access if viewing documents
	if permissionLevel == utils.PermissionViewFull && requesterID != targetUserID {
		_, _ = db.Exec(`
			INSERT INTO document_access_logs (user_id, accessed_by, document_type, action)
			VALUES ($1, $2, 'profile_view', 'view')
		`, targetUserID, requesterID)
	}

	c.JSON(http.StatusOK, gin.H{
		"user":             user,
		"permission_level": permissionLevel,
	})
}

// UpdateProfilePicture updates user's profile picture
func UpdateProfilePicture(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	userID := c.GetString("user_id")

	var req struct {
		ProfileImageURL      string  `json:"profile_image_url" binding:"required"`
		ProfileImagePublicID *string `json:"profile_image_public_id"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Delete old image if exists
	var oldPublicID sql.NullString
	_ = db.QueryRow(`SELECT profile_image_public_id FROM users WHERE id = $1`, userID).Scan(&oldPublicID)
	if oldPublicID.Valid && oldPublicID.String != "" {
		_ = utils.DeleteImage(oldPublicID.String)
	}

	// Update profile picture
	_, err := db.Exec(`
		UPDATE users
		SET profile_image_url = $1, profile_image_public_id = $2, updated_at = CURRENT_TIMESTAMP
		WHERE id = $3
	`, req.ProfileImageURL, req.ProfileImagePublicID, userID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update profile picture"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":           "Profile picture updated successfully",
		"profile_image_url": req.ProfileImageURL,
	})
}

// UpdateDocument updates a document (HR only)
func UpdateDocument(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	requesterID := c.GetString("user_id")
	targetUserID := c.Param("user_id")

	// Check if requester can edit documents
	canEdit, err := utils.CanEditDocuments(db, requesterID, targetUserID)
	if err != nil || !canEdit {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only HR can edit documents"})
		return
	}

	var req struct {
		DocumentType string  `json:"document_type" binding:"required"` // e.g., "waec_certificate"
		DocumentURL  string  `json:"document_url" binding:"required"`
		PublicID     *string `json:"public_id"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Map document type to database columns
	urlColumn := req.DocumentType + "_url"
	publicIDColumn := req.DocumentType + "_public_id"

	// Delete old document if exists
	var oldPublicID sql.NullString
	query := `SELECT ` + publicIDColumn + ` FROM users WHERE id = $1`
	_ = db.QueryRow(query, targetUserID).Scan(&oldPublicID)
	if oldPublicID.Valid && oldPublicID.String != "" {
		_ = utils.DeleteImage(oldPublicID.String)
	}

	// Update document
	updateQuery := `
		UPDATE users
		SET ` + urlColumn + ` = $1, ` + publicIDColumn + ` = $2, updated_at = CURRENT_TIMESTAMP
		WHERE id = $3
	`
	_, err = db.Exec(updateQuery, req.DocumentURL, req.PublicID, targetUserID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update document: " + err.Error()})
		return
	}

	// Log document update
	_, _ = db.Exec(`
		INSERT INTO document_access_logs (user_id, accessed_by, document_type, action)
		VALUES ($1, $2, $3, 'upload')
	`, targetUserID, requesterID, req.DocumentType)

	c.JSON(http.StatusOK, gin.H{
		"message": "Document updated successfully",
	})
}

// DeleteDocument deletes a document (HR only)
func DeleteDocument(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	requesterID := c.GetString("user_id")
	targetUserID := c.Param("user_id")

	// Check if requester can edit documents
	canEdit, err := utils.CanEditDocuments(db, requesterID, targetUserID)
	if err != nil || !canEdit {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only HR can delete documents"})
		return
	}

	var req struct {
		DocumentType string `json:"document_type" binding:"required"` // e.g., "waec_certificate"
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Map document type to database columns
	urlColumn := req.DocumentType + "_url"
	publicIDColumn := req.DocumentType + "_public_id"

	// Get public ID
	var publicID sql.NullString
	query := `SELECT ` + publicIDColumn + ` FROM users WHERE id = $1`
	err = db.QueryRow(query, targetUserID).Scan(&publicID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch document"})
		return
	}

	// Delete from Cloudinary
	if publicID.Valid && publicID.String != "" {
		if err := utils.DeleteImage(publicID.String); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete from Cloudinary"})
			return
		}
	}

	// Clear database fields
	updateQuery := `
		UPDATE users
		SET ` + urlColumn + ` = NULL, ` + publicIDColumn + ` = NULL, updated_at = CURRENT_TIMESTAMP
		WHERE id = $1
	`
	_, err = db.Exec(updateQuery, targetUserID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete document from database"})
		return
	}

	// Log document deletion
	_, _ = db.Exec(`
		INSERT INTO document_access_logs (user_id, accessed_by, document_type, action)
		VALUES ($1, $2, $3, 'delete')
	`, targetUserID, requesterID, req.DocumentType)

	c.JSON(http.StatusOK, gin.H{
		"message": "Document deleted successfully",
	})
}

// UpdateStaffProfile updates staff profile information (HR or Floor Manager for their department)
func UpdateStaffProfile(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	requesterID := c.GetString("user_id")
	targetUserID := c.Param("user_id")

	// Check requester's role and department
	var roleName string
	var requesterDeptID, requesterBranchID sql.NullString
	err := db.QueryRow(`
		SELECT r.name, u.department_id, u.branch_id FROM users u
		INNER JOIN roles r ON u.role_id = r.id
		WHERE u.id = $1
	`, requesterID).Scan(&roleName, &requesterDeptID, &requesterBranchID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify permissions"})
		return
	}

	isHR := roleName == "Human Resource" || roleName == "HR"
	isFloorManager := roleName == "Floor Manager"

	// Check if Floor Manager can edit this staff (same department and branch)
	canEdit := isHR
	if isFloorManager && !isHR {
		var targetDeptID, targetBranchID sql.NullString
		var targetRoleCategory sql.NullString
		err := db.QueryRow(`
			SELECT u.department_id, u.branch_id, r.category FROM users u
			INNER JOIN roles r ON u.role_id = r.id
			WHERE u.id = $1
		`, targetUserID).Scan(&targetDeptID, &targetBranchID, &targetRoleCategory)

		if err == nil {
			// Floor Manager can only edit general_staff in their department and branch
			sameDepart := requesterDeptID.Valid && targetDeptID.Valid && requesterDeptID.String == targetDeptID.String
			sameBranch := requesterBranchID.Valid && targetBranchID.Valid && requesterBranchID.String == targetBranchID.String
			isGeneralStaff := targetRoleCategory.Valid && targetRoleCategory.String == "general_staff"
			canEdit = sameDepart && sameBranch && isGeneralStaff
		}
	}

	if !canEdit {
		c.JSON(http.StatusForbidden, gin.H{"error": "You don't have permission to edit this profile"})
		return
	}

	var req struct {
		// Basic Info
		FullName        *string  `json:"full_name"`
		Email           *string  `json:"email"`
		Phone           *string  `json:"phone_number"`
		EmployeeID      *string  `json:"employee_id"`
		Address         *string  `json:"home_address"`
		Gender          *string  `json:"gender"`
		MaritalStatus   *string  `json:"marital_status"`
		StateOfOrigin   *string  `json:"state_of_origin"`
		DateOfBirth     *string  `json:"date_of_birth"`
		DateJoined      *string  `json:"date_joined"`
		Salary          *float64 `json:"current_salary"`
		ProfileImageURL *string  `json:"profile_image_url"`
		RoleID          *string  `json:"role_id"`

		// Education
		CourseOfStudy *string `json:"course_of_study"`
		Grade         *string `json:"grade"`
		Institution   *string `json:"institution"`
		ExamScores    *string `json:"exam_scores"`

		// Document URLs
		PassportURL           *string `json:"passport_url"`
		NationalIDURL         *string `json:"national_id_url"`
		BirthCertificateURL   *string `json:"birth_certificate_url"`
		WaecCertificateURL    *string `json:"waec_certificate_url"`
		NecoCertificateURL    *string `json:"neco_certificate_url"`
		JambResultURL         *string `json:"jamb_result_url"`
		DegreeCertificateURL  *string `json:"degree_certificate_url"`
		DiplomaCertificateURL *string `json:"diploma_certificate_url"`
		NyscCertificateURL    *string `json:"nysc_certificate_url"`
		StateOfOriginCertURL  *string `json:"state_of_origin_cert_url"`
		LgaCertificateURL     *string `json:"lga_certificate_url"`
		DriversLicenseURL     *string `json:"drivers_license_url"`
		VotersCardURL         *string `json:"voters_card_url"`
		ResumeURL             *string `json:"resume_url"`
		CoverLetterURL        *string `json:"cover_letter_url"`

		// Next of Kin
		NextOfKin *struct {
			FullName     string `json:"full_name"`
			Relationship string `json:"relationship"`
			Phone        string `json:"phone"`
			Email        string `json:"email"`
			HomeAddress  string `json:"home_address"`
			WorkAddress  string `json:"work_address"`
		} `json:"next_of_kin"`

		// Guarantors
		Guarantor1 *struct {
			FullName     string `json:"full_name"`
			Phone        string `json:"phone"`
			Occupation   string `json:"occupation"`
			Relationship string `json:"relationship"`
			HomeAddress  string `json:"home_address"`
			Email        string `json:"email"`
			Passport     string `json:"passport"`
			NationalID   string `json:"national_id"`
			WorkID       string `json:"work_id"`
		} `json:"guarantor_1"`

		Guarantor2 *struct {
			FullName     string `json:"full_name"`
			Phone        string `json:"phone"`
			Occupation   string `json:"occupation"`
			Relationship string `json:"relationship"`
			HomeAddress  string `json:"home_address"`
			Email        string `json:"email"`
			Passport     string `json:"passport"`
			NationalID   string `json:"national_id"`
			WorkID       string `json:"work_id"`
		} `json:"guarantor_2"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Build update query dynamically based on provided fields
	updates := []string{}
	args := []interface{}{}
	argCount := 1

	if req.FullName != nil {
		updates = append(updates, "full_name = $"+fmt.Sprint(argCount))
		args = append(args, *req.FullName)
		argCount++
	}
	if req.Email != nil {
		updates = append(updates, "email = $"+fmt.Sprint(argCount))
		args = append(args, *req.Email)
		argCount++
	}
	if req.Phone != nil {
		updates = append(updates, "phone_number = $"+fmt.Sprint(argCount))
		args = append(args, *req.Phone)
		argCount++
	}
	if req.EmployeeID != nil {
		updates = append(updates, "employee_id = $"+fmt.Sprint(argCount))
		args = append(args, *req.EmployeeID)
		argCount++
	}
	if req.Address != nil {
		updates = append(updates, "home_address = $"+fmt.Sprint(argCount))
		args = append(args, *req.Address)
		argCount++
	}
	if req.Gender != nil {
		updates = append(updates, "gender = $"+fmt.Sprint(argCount))
		args = append(args, *req.Gender)
		argCount++
	}
	if req.MaritalStatus != nil {
		updates = append(updates, "marital_status = $"+fmt.Sprint(argCount))
		args = append(args, *req.MaritalStatus)
		argCount++
	}
	if req.StateOfOrigin != nil {
		updates = append(updates, "state_of_origin = $"+fmt.Sprint(argCount))
		args = append(args, *req.StateOfOrigin)
		argCount++
	}
	if req.DateOfBirth != nil && *req.DateOfBirth != "" {
		updates = append(updates, "date_of_birth = $"+fmt.Sprint(argCount))
		args = append(args, *req.DateOfBirth)
		argCount++
	}
	if req.DateJoined != nil && *req.DateJoined != "" {
		updates = append(updates, "date_joined = $"+fmt.Sprint(argCount))
		args = append(args, *req.DateJoined)
		argCount++
	}
	if req.Salary != nil {
		updates = append(updates, "current_salary = $"+fmt.Sprint(argCount))
		args = append(args, *req.Salary)
		argCount++
	}
	if req.ProfileImageURL != nil {
		updates = append(updates, "profile_image_url = $"+fmt.Sprint(argCount))
		args = append(args, *req.ProfileImageURL)
		argCount++
	}
	if req.RoleID != nil && *req.RoleID != "" {
		updates = append(updates, "role_id = $"+fmt.Sprint(argCount))
		args = append(args, *req.RoleID)
		argCount++
	}
	if req.CourseOfStudy != nil {
		updates = append(updates, "course_of_study = $"+fmt.Sprint(argCount))
		args = append(args, *req.CourseOfStudy)
		argCount++
	}
	if req.Grade != nil {
		updates = append(updates, "grade = $"+fmt.Sprint(argCount))
		args = append(args, *req.Grade)
		argCount++
	}
	if req.Institution != nil {
		updates = append(updates, "institution = $"+fmt.Sprint(argCount))
		args = append(args, *req.Institution)
		argCount++
	}

	// Handle exam scores update separately (in exam_scores table)
	if req.ExamScores != nil && *req.ExamScores != "" {
		// Delete existing exam scores
		_, _ = db.Exec("DELETE FROM exam_scores WHERE user_id = $1", targetUserID)

		// Insert new exam score
		examScoreUUID := uuid.New().String()
		_, examErr := db.Exec(`
			INSERT INTO exam_scores (id, user_id, exam_type, score, created_at)
			VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)
		`, examScoreUUID, targetUserID, "General", *req.ExamScores)
		if examErr != nil {
			fmt.Printf("⚠️ Exam scores update failed: %v\n", examErr)
		}
	}

	// Document URLs
	if req.PassportURL != nil {
		updates = append(updates, "passport_url = $"+fmt.Sprint(argCount))
		args = append(args, *req.PassportURL)
		argCount++
	}
	if req.NationalIDURL != nil {
		updates = append(updates, "national_id_url = $"+fmt.Sprint(argCount))
		args = append(args, *req.NationalIDURL)
		argCount++
	}
	if req.BirthCertificateURL != nil {
		updates = append(updates, "birth_certificate_url = $"+fmt.Sprint(argCount))
		args = append(args, *req.BirthCertificateURL)
		argCount++
	}
	if req.WaecCertificateURL != nil {
		updates = append(updates, "waec_certificate_url = $"+fmt.Sprint(argCount))
		args = append(args, *req.WaecCertificateURL)
		argCount++
	}
	if req.NecoCertificateURL != nil {
		updates = append(updates, "neco_certificate_url = $"+fmt.Sprint(argCount))
		args = append(args, *req.NecoCertificateURL)
		argCount++
	}
	if req.JambResultURL != nil {
		updates = append(updates, "jamb_result_url = $"+fmt.Sprint(argCount))
		args = append(args, *req.JambResultURL)
		argCount++
	}
	if req.DegreeCertificateURL != nil {
		updates = append(updates, "degree_certificate_url = $"+fmt.Sprint(argCount))
		args = append(args, *req.DegreeCertificateURL)
		argCount++
	}
	if req.DiplomaCertificateURL != nil {
		updates = append(updates, "diploma_certificate_url = $"+fmt.Sprint(argCount))
		args = append(args, *req.DiplomaCertificateURL)
		argCount++
	}
	if req.NyscCertificateURL != nil {
		updates = append(updates, "nysc_certificate_url = $"+fmt.Sprint(argCount))
		args = append(args, *req.NyscCertificateURL)
		argCount++
	}
	if req.StateOfOriginCertURL != nil {
		updates = append(updates, "state_of_origin_cert_url = $"+fmt.Sprint(argCount))
		args = append(args, *req.StateOfOriginCertURL)
		argCount++
	}
	if req.LgaCertificateURL != nil {
		updates = append(updates, "lga_certificate_url = $"+fmt.Sprint(argCount))
		args = append(args, *req.LgaCertificateURL)
		argCount++
	}
	if req.DriversLicenseURL != nil {
		updates = append(updates, "drivers_license_url = $"+fmt.Sprint(argCount))
		args = append(args, *req.DriversLicenseURL)
		argCount++
	}
	if req.VotersCardURL != nil {
		updates = append(updates, "voters_card_url = $"+fmt.Sprint(argCount))
		args = append(args, *req.VotersCardURL)
		argCount++
	}
	if req.ResumeURL != nil {
		updates = append(updates, "resume_url = $"+fmt.Sprint(argCount))
		args = append(args, *req.ResumeURL)
		argCount++
	}
	if req.CoverLetterURL != nil {
		updates = append(updates, "cover_letter_url = $"+fmt.Sprint(argCount))
		args = append(args, *req.CoverLetterURL)
		argCount++
	}

	// Update users table if there are updates
	if len(updates) > 0 {
		updates = append(updates, "updated_at = CURRENT_TIMESTAMP")
		args = append(args, targetUserID)
		query := "UPDATE users SET " + strings.Join(updates, ", ") + " WHERE id = $" + fmt.Sprint(argCount)
		_, err = db.Exec(query, args...)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update profile: " + err.Error()})
			return
		}
	}

	// Update Next of Kin
	if req.NextOfKin != nil && req.NextOfKin.FullName != "" {
		// Delete existing and insert new
		db.Exec("DELETE FROM next_of_kin WHERE user_id = $1", targetUserID)
		db.Exec(`
			INSERT INTO next_of_kin (id, user_id, full_name, relationship, phone_number, email, home_address, work_address, created_at, updated_at)
			VALUES (uuid_generate_v4(), $1, $2, $3, $4, $5, $6, $7, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
		`, targetUserID, req.NextOfKin.FullName, req.NextOfKin.Relationship, req.NextOfKin.Phone, req.NextOfKin.Email, req.NextOfKin.HomeAddress, req.NextOfKin.WorkAddress)
	}

	// Update Guarantor 1
	if req.Guarantor1 != nil && req.Guarantor1.FullName != "" {
		db.Exec("DELETE FROM guarantors WHERE user_id = $1 AND guarantor_number = 1", targetUserID)
		var guarantor1ID string
		err := db.QueryRow(`
			INSERT INTO guarantors (id, user_id, guarantor_number, full_name, phone_number, occupation, relationship, home_address, email, created_at, updated_at)
			VALUES (uuid_generate_v4(), $1, 1, $2, $3, $4, $5, $6, $7, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
			RETURNING id
		`, targetUserID, req.Guarantor1.FullName, req.Guarantor1.Phone, req.Guarantor1.Occupation, req.Guarantor1.Relationship, req.Guarantor1.HomeAddress, req.Guarantor1.Email).Scan(&guarantor1ID)

		if err == nil {
			// Save guarantor documents
			if req.Guarantor1.Passport != "" {
				db.Exec(`INSERT INTO guarantor_documents (guarantor_id, document_type, file_name, file_path) VALUES ($1, 'passport', 'passport.jpg', $2)`, guarantor1ID, req.Guarantor1.Passport)
			}
			if req.Guarantor1.NationalID != "" {
				db.Exec(`INSERT INTO guarantor_documents (guarantor_id, document_type, file_name, file_path) VALUES ($1, 'national_id', 'national_id.jpg', $2)`, guarantor1ID, req.Guarantor1.NationalID)
			}
			if req.Guarantor1.WorkID != "" {
				db.Exec(`INSERT INTO guarantor_documents (guarantor_id, document_type, file_name, file_path) VALUES ($1, 'work_id', 'work_id.jpg', $2)`, guarantor1ID, req.Guarantor1.WorkID)
			}
		}
	}

	// Update Guarantor 2
	if req.Guarantor2 != nil && req.Guarantor2.FullName != "" {
		db.Exec("DELETE FROM guarantors WHERE user_id = $1 AND guarantor_number = 2", targetUserID)
		var guarantor2ID string
		err := db.QueryRow(`
			INSERT INTO guarantors (id, user_id, guarantor_number, full_name, phone_number, occupation, relationship, home_address, email, created_at, updated_at)
			VALUES (uuid_generate_v4(), $1, 2, $2, $3, $4, $5, $6, $7, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
			RETURNING id
		`, targetUserID, req.Guarantor2.FullName, req.Guarantor2.Phone, req.Guarantor2.Occupation, req.Guarantor2.Relationship, req.Guarantor2.HomeAddress, req.Guarantor2.Email).Scan(&guarantor2ID)

		if err == nil {
			// Save guarantor documents
			if req.Guarantor2.Passport != "" {
				db.Exec(`INSERT INTO guarantor_documents (guarantor_id, document_type, file_name, file_path) VALUES ($1, 'passport', 'passport.jpg', $2)`, guarantor2ID, req.Guarantor2.Passport)
			}
			if req.Guarantor2.NationalID != "" {
				db.Exec(`INSERT INTO guarantor_documents (guarantor_id, document_type, file_name, file_path) VALUES ($1, 'national_id', 'national_id.jpg', $2)`, guarantor2ID, req.Guarantor2.NationalID)
			}
			if req.Guarantor2.WorkID != "" {
				db.Exec(`INSERT INTO guarantor_documents (guarantor_id, document_type, file_name, file_path) VALUES ($1, 'work_id', 'work_id.jpg', $2)`, guarantor2ID, req.Guarantor2.WorkID)
			}
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Profile updated successfully",
	})
}

// GetDocumentAccessLogs returns document access logs (HR only)
func GetDocumentAccessLogs(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	requesterID := c.GetString("user_id")
	targetUserID := c.Param("user_id")

	// Check if requester is HR
	var roleName string
	err := db.QueryRow(`
		SELECT r.name FROM users u
		INNER JOIN roles r ON u.role_id = r.id
		WHERE u.id = $1
	`, requesterID).Scan(&roleName)

	if err != nil || roleName != "Human Resource" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only HR can view access logs"})
		return
	}

	rows, err := db.Query(`
		SELECT 
			dal.id, dal.document_type, dal.action, dal.created_at,
			u.full_name as accessed_by_name
		FROM document_access_logs dal
		INNER JOIN users u ON dal.accessed_by = u.id
		WHERE dal.user_id = $1
		ORDER BY dal.created_at DESC
		LIMIT 100
	`, targetUserID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch logs"})
		return
	}
	defer rows.Close()

	var logs []map[string]interface{}
	for rows.Next() {
		var id, documentType, action, accessedByName string
		var createdAt sql.NullTime

		err := rows.Scan(&id, &documentType, &action, &createdAt, &accessedByName)
		if err != nil {
			continue
		}

		logs = append(logs, map[string]interface{}{
			"id":               id,
			"document_type":    documentType,
			"action":           action,
			"accessed_by_name": accessedByName,
			"created_at":       createdAt.Time,
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"logs":  logs,
		"count": len(logs),
	})
}
