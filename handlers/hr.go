package handlers

import (
	"ace-mall-backend/config"
	"ace-mall-backend/utils"
	"database/sql"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// GetAllStaff returns all staff members (HR/CEO/COO only)
func GetAllStaff(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	requesterID := c.GetString("user_id")

	// Check if this is being called from branch endpoint
	isBranchEndpoint := c.GetBool("is_branch_endpoint")

	// Get optional filters
	branchID := c.Query("branch_id")
	departmentID := c.Query("department_id")
	roleCategory := c.Query("role_category")
	search := c.Query("search")

	// If called from branch endpoint and no branch_id specified, use user's branch
	if isBranchEndpoint && branchID == "" {
		userID, exists := c.Get("user_id")
		if exists {
			var userBranchID sql.NullString
			err := db.QueryRow(`SELECT branch_id FROM users WHERE id = $1`, userID).Scan(&userBranchID)
			if err == nil && userBranchID.Valid {
				branchID = userBranchID.String
			}
		}
	}

	// Build query - exclude terminated staff by default
	query := `
		SELECT 
			u.id, u.email, u.full_name, u.gender, u.phone_number,
			u.employee_id, u.profile_image_url, u.date_of_birth,
			r.id as role_id, r.name as role_name, r.category as role_category,
			d.id as department_id, d.name as department_name,
			b.id as branch_id, b.name as branch_name,
			u.current_salary, u.date_joined, u.is_active
		FROM users u
		LEFT JOIN roles r ON u.role_id = r.id
		LEFT JOIN departments d ON u.department_id = d.id
		LEFT JOIN branches b ON u.branch_id = b.id
		WHERE u.is_active = true AND u.is_terminated = false
	`

	args := []interface{}{}
	argCount := 1

	// Apply filters
	if branchID != "" {
		query += ` AND u.branch_id = $1`
		args = append(args, branchID)
		argCount++
	}

	if departmentID != "" {
		query += ` AND u.department_id = $` + fmt.Sprintf("%d", argCount)
		args = append(args, departmentID)
		argCount++
	}

	if roleCategory != "" {
		query += ` AND r.category = $` + fmt.Sprintf("%d", argCount)
		args = append(args, roleCategory)
		argCount++
	}

	if search != "" {
		searchPattern := "%" + search + "%"
		query += ` AND (u.full_name ILIKE $` + fmt.Sprintf("%d", argCount) +
			` OR u.email ILIKE $` + fmt.Sprintf("%d", argCount+1) +
			` OR u.employee_id ILIKE $` + fmt.Sprintf("%d", argCount+2) + `)`
		args = append(args, searchPattern, searchPattern, searchPattern)
		argCount += 3
	}

	query += ` ORDER BY r.category, u.full_name`

	rows, err := db.Query(query, args...)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch staff: " + err.Error()})
		return
	}
	defer rows.Close()

	var staff []map[string]interface{}
	for rows.Next() {
		var (
			id, email, fullName                              string
			gender, phoneNumber, employeeID, profileImageURL sql.NullString
			dateOfBirth                                      sql.NullTime
			roleID, roleName, roleCategory                   sql.NullString
			departmentID, departmentName                     sql.NullString
			branchIDVal, branchName                          sql.NullString
			currentSalary                                    sql.NullFloat64
			dateJoined                                       sql.NullTime
			isActive                                         bool
		)

		err := rows.Scan(
			&id, &email, &fullName, &gender, &phoneNumber,
			&employeeID, &profileImageURL, &dateOfBirth,
			&roleID, &roleName, &roleCategory,
			&departmentID, &departmentName,
			&branchIDVal, &branchName,
			&currentSalary, &dateJoined, &isActive,
		)

		if err != nil {
			continue
		}

		staffMember := map[string]interface{}{
			"id":        id,
			"email":     email,
			"full_name": fullName,
			"is_active": isActive,
		}

		if gender.Valid {
			staffMember["gender"] = gender.String
		}
		if phoneNumber.Valid {
			staffMember["phone_number"] = phoneNumber.String
		}
		if employeeID.Valid {
			staffMember["employee_id"] = employeeID.String
		}
		if profileImageURL.Valid {
			staffMember["profile_image_url"] = profileImageURL.String
		}
		if dateOfBirth.Valid {
			staffMember["date_of_birth"] = dateOfBirth.Time
		}
		if roleID.Valid {
			staffMember["role_id"] = roleID.String
		}
		if roleName.Valid {
			staffMember["role_name"] = roleName.String
		}
		if roleCategory.Valid {
			staffMember["role_category"] = roleCategory.String
		}
		if departmentID.Valid {
			staffMember["department_id"] = departmentID.String
		}
		if departmentName.Valid {
			staffMember["department_name"] = departmentName.String
		}
		if branchIDVal.Valid {
			staffMember["branch_id"] = branchIDVal.String
		}
		if branchName.Valid {
			staffMember["branch_name"] = branchName.String
		}
		if currentSalary.Valid {
			staffMember["current_salary"] = currentSalary.Float64
		}
		if dateJoined.Valid {
			staffMember["date_joined"] = dateJoined.Time
		}

		// Calculate permission level for this staff member
		permissionLevel, _ := utils.CanViewProfile(db, requesterID, id)
		staffMember["permission_level"] = string(permissionLevel)

		staff = append(staff, staffMember)
	}

	c.JSON(http.StatusOK, gin.H{
		"staff": staff,
		"count": len(staff),
	})
}

// GetStaffStats returns statistics about staff (HR/CEO/COO only)
func GetStaffStats(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)

	// Total staff count (exclude terminated)
	var totalStaff int
	err := db.QueryRow(`SELECT COUNT(*) FROM users WHERE is_terminated = false`).Scan(&totalStaff)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch stats"})
		return
	}

	// Staff by category (exclude terminated)
	rows, err := db.Query(`
		SELECT r.category, COUNT(*) as count
		FROM users u
		INNER JOIN roles r ON u.role_id = r.id
		WHERE u.is_terminated = false
		GROUP BY r.category
		ORDER BY r.category
	`)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch category stats"})
		return
	}
	defer rows.Close()

	categoryStats := make(map[string]int)
	for rows.Next() {
		var category string
		var count int
		if err := rows.Scan(&category, &count); err == nil {
			categoryStats[category] = count
		}
	}

	// Staff by branch
	rows2, err := db.Query(`
		SELECT b.name, COUNT(u.id) as count
		FROM branches b
		LEFT JOIN users u ON b.id = u.branch_id
		GROUP BY b.name
		ORDER BY count DESC
		LIMIT 10
	`)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch branch stats"})
		return
	}
	defer rows2.Close()

	branchStats := []map[string]interface{}{}
	for rows2.Next() {
		var branchName string
		var count int
		if err := rows2.Scan(&branchName, &count); err == nil {
			branchStats = append(branchStats, map[string]interface{}{
				"branch": branchName,
				"count":  count,
			})
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"total_staff": totalStaff,
		"by_category": categoryStats,
		"by_branch":   branchStats,
	})
}

// GetBranchStats returns statistics for a specific branch (Branch Managers)
func GetBranchStats(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)

	// Get branch_id from authenticated user
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	// Get user's branch_id
	var branchID sql.NullString
	err := db.QueryRow(`SELECT branch_id FROM users WHERE id = $1`, userID).Scan(&branchID)
	if err != nil || !branchID.Valid {
		c.JSON(http.StatusBadRequest, gin.H{"error": "User has no assigned branch"})
		return
	}

	// Total staff in branch (exclude terminated)
	var totalStaff int
	err = db.QueryRow(`SELECT COUNT(*) FROM users WHERE branch_id = $1 AND is_terminated = false`, branchID.String).Scan(&totalStaff)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch branch stats"})
		return
	}

	// Active staff count (exclude terminated)
	var activeStaff int
	err = db.QueryRow(`SELECT COUNT(*) FROM users WHERE branch_id = $1 AND is_active = true AND is_terminated = false`, branchID.String).Scan(&activeStaff)
	if err != nil {
		activeStaff = 0
	}

	// Staff by department in this branch (exclude terminated)
	rows, err := db.Query(`
		SELECT d.name, COUNT(u.id) as count
		FROM departments d
		LEFT JOIN users u ON d.id = u.department_id AND u.branch_id = $1 AND u.is_terminated = false
		GROUP BY d.name
		ORDER BY count DESC
	`, branchID.String)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch department stats"})
		return
	}
	defer rows.Close()

	departmentStats := []map[string]interface{}{}
	for rows.Next() {
		var deptName string
		var count int
		if err := rows.Scan(&deptName, &count); err == nil {
			departmentStats = append(departmentStats, map[string]interface{}{
				"department": deptName,
				"count":      count,
			})
		}
	}

	// Staff by role category in this branch
	rows2, err := db.Query(`
		SELECT r.category, COUNT(u.id) as count
		FROM users u
		INNER JOIN roles r ON u.role_id = r.id
		WHERE u.branch_id = $1
		GROUP BY r.category
		ORDER BY r.category
	`, branchID.String)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch category stats"})
		return
	}
	defer rows2.Close()

	categoryStats := make(map[string]int)
	for rows2.Next() {
		var category string
		var count int
		if err := rows2.Scan(&category, &count); err == nil {
			categoryStats[category] = count
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"branch_id":     branchID.String,
		"total_staff":   totalStaff,
		"active_staff":  activeStaff,
		"by_department": departmentStats,
		"by_category":   categoryStats,
	})
}

// NextOfKinRequest represents next of kin data
type NextOfKinRequest struct {
	FullName     string `json:"full_name"`
	Relationship string `json:"relationship"`
	Email        string `json:"email"`
	Phone        string `json:"phone"`
	HomeAddress  string `json:"home_address"`
	WorkAddress  string `json:"work_address"`
}

// GuarantorRequest represents guarantor data
type GuarantorRequest struct {
	FullName     string `json:"full_name"`
	Phone        string `json:"phone"`
	Occupation   string `json:"occupation"`
	Relationship string `json:"relationship"`
	Sex          string `json:"sex"`
	Age          int    `json:"age"`
	HomeAddress  string `json:"home_address"`
	Email        string `json:"email"`
	DateOfBirth  string `json:"date_of_birth"`
	GradeLevel   string `json:"grade_level"`
}

// CreateStaffByHR allows HR/senior_admin to create ANY type of staff
func CreateStaffByHR(c *gin.Context) {
	var req struct {
		FullName      string            `json:"full_name" binding:"required"`
		Email         string            `json:"email" binding:"required,email"`
		Phone         *string           `json:"phone"`
		EmployeeID    *string           `json:"employee_id"`
		RoleID        string            `json:"role_id" binding:"required"`
		DepartmentID  *string           `json:"department_id"`
		BranchID      *string           `json:"branch_id"`
		Gender        *string           `json:"gender"`
		MaritalStatus *string           `json:"marital_status"`
		StateOfOrigin *string           `json:"state_of_origin"`
		DateOfBirth   *string           `json:"date_of_birth"`
		DateJoined    *string           `json:"date_joined"`
		HomeAddress   *string           `json:"home_address"`
		CourseOfStudy *string           `json:"course_of_study"`
		Grade         *string           `json:"grade"`
		Institution   *string           `json:"institution"`
		ExamScores    *string           `json:"exam_scores"`
		Salary        *float64          `json:"salary"`
		NextOfKin     *NextOfKinRequest `json:"next_of_kin"`
		Guarantor1    *GuarantorRequest `json:"guarantor_1"`
		Guarantor2    *GuarantorRequest `json:"guarantor_2"`
		// Document URLs from Cloudinary
		PassportURL          *string `json:"passport_url"`
		NationalIDURL        *string `json:"national_id_url"`
		BirthCertificateURL  *string `json:"birth_certificate_url"`
		WaecCertificateURL   *string `json:"waec_certificate_url"`
		NecoCertificateURL   *string `json:"neco_certificate_url"`
		DegreeCertificateURL *string `json:"degree_certificate_url"`
		NyscCertificateURL   *string `json:"nysc_certificate_url"`
		StateOfOriginCertURL *string `json:"state_of_origin_cert_url"`
		ProfileImageURL      *string `json:"profile_image_url"`
		// Guarantor document URLs
		G1PassportURL   *string `json:"g1_passport_url"`
		G1NationalIDURL *string `json:"g1_national_id_url"`
		G1WorkIDURL     *string `json:"g1_work_id_url"`
		G2PassportURL   *string `json:"g2_passport_url"`
		G2NationalIDURL *string `json:"g2_national_id_url"`
		G2WorkIDURL     *string `json:"g2_work_id_url"`
		// Work Experience
		WorkExperience []struct {
			CompanyName string `json:"company_name"`
			Position    string `json:"position"`
			StartDate   string `json:"start_date"`
			EndDate     string `json:"end_date"`
		} `json:"work_experience"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	emailParts := strings.Split(req.Email, "@")
	defaultPassword := emailParts[0]

	var existingID string
	err := config.DB.QueryRow("SELECT id FROM users WHERE email = $1", req.Email).Scan(&existingID)
	if err == nil {
		c.JSON(http.StatusConflict, gin.H{"error": "Email already exists"})
		return
	}

	hashedPassword, err := utils.HashPassword(defaultPassword)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to hash password"})
		return
	}

	// Use provided employee ID only - do not generate
	var employeeID *string
	if req.EmployeeID != nil && *req.EmployeeID != "" {
		employeeID = req.EmployeeID
	}

	userUUID := uuid.New().String()
	now := time.Now()

	var dob interface{}
	if req.DateOfBirth != nil && *req.DateOfBirth != "" {
		parsedDob, err := time.Parse("2006-01-02", *req.DateOfBirth)
		if err == nil {
			dob = parsedDob
		}
	}

	// Parse date_joined from request, or use current time if not provided
	var dateJoined interface{}
	if req.DateJoined != nil && *req.DateJoined != "" {
		parsedDateJoined, err := time.Parse("2006-01-02", *req.DateJoined)
		if err == nil {
			dateJoined = parsedDateJoined
		} else {
			dateJoined = now
		}
	} else {
		dateJoined = now
	}

	query := `
		INSERT INTO users (
			id, email, password_hash, full_name, phone_number, role_id, 
			department_id, branch_id, employee_id, gender, marital_status,
			state_of_origin, home_address, date_of_birth, current_salary,
			course_of_study, grade, institution,
			passport_url, national_id_url, birth_certificate_url, waec_certificate_url,
			neco_certificate_url, degree_certificate_url, nysc_certificate_url,
			state_of_origin_cert_url, profile_image_url,
			is_active, is_terminated, date_joined, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, 
			$19, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $30, $31, $32)
	`

	_, err = config.DB.Exec(query,
		userUUID, req.Email, hashedPassword, req.FullName, req.Phone, req.RoleID,
		req.DepartmentID, req.BranchID, employeeID, req.Gender, req.MaritalStatus,
		req.StateOfOrigin, req.HomeAddress, dob, req.Salary,
		req.CourseOfStudy, req.Grade, req.Institution,
		req.PassportURL, req.NationalIDURL, req.BirthCertificateURL, req.WaecCertificateURL,
		req.NecoCertificateURL, req.DegreeCertificateURL, req.NyscCertificateURL,
		req.StateOfOriginCertURL, req.ProfileImageURL,
		true, false, dateJoined, now, now)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create staff: " + err.Error()})
		return
	}

	// Insert Next of Kin
	if req.NextOfKin != nil && req.NextOfKin.FullName != "" {
		nokUUID := uuid.New().String()
		_, nokErr := config.DB.Exec(`
			INSERT INTO next_of_kin (id, user_id, full_name, relationship, email, phone_number, home_address, work_address, created_at, updated_at)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
		`, nokUUID, userUUID, req.NextOfKin.FullName, req.NextOfKin.Relationship,
			req.NextOfKin.Email, req.NextOfKin.Phone, req.NextOfKin.HomeAddress, req.NextOfKin.WorkAddress, now, now)
		if nokErr != nil {
			// Non-critical: next of kin insert failed
		}
	}

	// Insert Guarantor 1 - also create if documents are uploaded without name
	var g1UUID string
	hasG1Docs := (req.G1PassportURL != nil && *req.G1PassportURL != "") ||
		(req.G1NationalIDURL != nil && *req.G1NationalIDURL != "") ||
		(req.G1WorkIDURL != nil && *req.G1WorkIDURL != "")
	hasG1Info := req.Guarantor1 != nil && req.Guarantor1.FullName != ""

	if hasG1Info || hasG1Docs {
		g1UUID = uuid.New().String()
		g1Name := "Guarantor 1"
		var g1Phone, g1Occupation, g1Relationship, g1Sex, g1Address, g1Email, g1GradeLevel string
		var g1Age int
		if req.Guarantor1 != nil {
			if req.Guarantor1.FullName != "" {
				g1Name = req.Guarantor1.FullName
			}
			g1Phone = req.Guarantor1.Phone
			g1Occupation = req.Guarantor1.Occupation
			g1Relationship = req.Guarantor1.Relationship
			g1Sex = req.Guarantor1.Sex
			g1Age = req.Guarantor1.Age
			g1Address = req.Guarantor1.HomeAddress
			g1Email = req.Guarantor1.Email
			g1GradeLevel = req.Guarantor1.GradeLevel
		}
		_, g1Err := config.DB.Exec(`
			INSERT INTO guarantors (id, user_id, guarantor_number, full_name, phone_number, occupation, relationship, sex, age, home_address, email, grade_level, created_at, updated_at)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
		`, g1UUID, userUUID, 1, g1Name, g1Phone, g1Occupation, g1Relationship, g1Sex, g1Age, g1Address, g1Email, g1GradeLevel, now, now)
		if g1Err != nil {
			fmt.Printf("⚠️ Guarantor 1 insert failed: %v\n", g1Err)
		} else {
			fmt.Printf("✅ Created Guarantor 1 record: %s\n", g1UUID)
			// Insert Guarantor 1 documents
			if req.G1PassportURL != nil && *req.G1PassportURL != "" {
				docUUID := uuid.New().String()
				config.DB.Exec(`INSERT INTO guarantor_documents (id, guarantor_id, document_type, file_path, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6)`,
					docUUID, g1UUID, "passport", *req.G1PassportURL, now, now)
				fmt.Printf("✅ Saved Guarantor 1 passport: %s\n", *req.G1PassportURL)
			}
			if req.G1NationalIDURL != nil && *req.G1NationalIDURL != "" {
				docUUID := uuid.New().String()
				config.DB.Exec(`INSERT INTO guarantor_documents (id, guarantor_id, document_type, file_path, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6)`,
					docUUID, g1UUID, "national_id", *req.G1NationalIDURL, now, now)
			}
			if req.G1WorkIDURL != nil && *req.G1WorkIDURL != "" {
				docUUID := uuid.New().String()
				config.DB.Exec(`INSERT INTO guarantor_documents (id, guarantor_id, document_type, file_path, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6)`,
					docUUID, g1UUID, "work_id", *req.G1WorkIDURL, now, now)
			}
		}
	}

	// Insert Guarantor 2 - also create if documents are uploaded without name
	var g2UUID string
	hasG2Docs := (req.G2PassportURL != nil && *req.G2PassportURL != "") ||
		(req.G2NationalIDURL != nil && *req.G2NationalIDURL != "") ||
		(req.G2WorkIDURL != nil && *req.G2WorkIDURL != "")
	hasG2Info := req.Guarantor2 != nil && req.Guarantor2.FullName != ""

	if hasG2Info || hasG2Docs {
		g2UUID = uuid.New().String()
		g2Name := "Guarantor 2"
		var g2Phone, g2Occupation, g2Relationship, g2Sex, g2Address, g2Email, g2GradeLevel string
		var g2Age int
		if req.Guarantor2 != nil {
			if req.Guarantor2.FullName != "" {
				g2Name = req.Guarantor2.FullName
			}
			g2Phone = req.Guarantor2.Phone
			g2Occupation = req.Guarantor2.Occupation
			g2Relationship = req.Guarantor2.Relationship
			g2Sex = req.Guarantor2.Sex
			g2Age = req.Guarantor2.Age
			g2Address = req.Guarantor2.HomeAddress
			g2Email = req.Guarantor2.Email
			g2GradeLevel = req.Guarantor2.GradeLevel
		}
		_, g2Err := config.DB.Exec(`
			INSERT INTO guarantors (id, user_id, guarantor_number, full_name, phone_number, occupation, relationship, sex, age, home_address, email, grade_level, created_at, updated_at)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
		`, g2UUID, userUUID, 2, g2Name, g2Phone, g2Occupation, g2Relationship, g2Sex, g2Age, g2Address, g2Email, g2GradeLevel, now, now)
		if g2Err != nil {
			fmt.Printf("⚠️ Guarantor 2 insert failed: %v\n", g2Err)
		} else {
			fmt.Printf("✅ Created Guarantor 2 record: %s\n", g2UUID)
			// Insert Guarantor 2 documents
			if req.G2PassportURL != nil && *req.G2PassportURL != "" {
				docUUID := uuid.New().String()
				_, err := config.DB.Exec(`INSERT INTO guarantor_documents (id, guarantor_id, document_type, file_path, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6)`,
					docUUID, g2UUID, "passport", *req.G2PassportURL, now, now)
				if err != nil {
					fmt.Printf("❌ Error saving Guarantor 2 passport: %v\n", err)
				} else {
					fmt.Printf("✅ Saved Guarantor 2 passport: %s\n", *req.G2PassportURL)
				}
			}
			if req.G2NationalIDURL != nil && *req.G2NationalIDURL != "" {
				docUUID := uuid.New().String()
				_, err := config.DB.Exec(`INSERT INTO guarantor_documents (id, guarantor_id, document_type, file_path, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6)`,
					docUUID, g2UUID, "national_id", *req.G2NationalIDURL, now, now)
				if err != nil {
					fmt.Printf("❌ Error saving Guarantor 2 national ID: %v\n", err)
				} else {
					fmt.Printf("✅ Saved Guarantor 2 national ID: %s\n", *req.G2NationalIDURL)
				}
			}
			if req.G2WorkIDURL != nil && *req.G2WorkIDURL != "" {
				docUUID := uuid.New().String()
				_, err := config.DB.Exec(`INSERT INTO guarantor_documents (id, guarantor_id, document_type, file_path, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6)`,
					docUUID, g2UUID, "work_id", *req.G2WorkIDURL, now, now)
				if err != nil {
					fmt.Printf("❌ Error saving Guarantor 2 work ID: %v\n", err)
				} else {
					fmt.Printf("✅ Saved Guarantor 2 work ID: %s\n", *req.G2WorkIDURL)
				}
			}
		}
	}

	// Insert Exam Scores if provided
	if req.ExamScores != nil && *req.ExamScores != "" {
		// Parse exam scores (format: "WAEC: 5 credits, JAMB: 250")
		examScoreUUID := uuid.New().String()
		_, examErr := config.DB.Exec(`
			INSERT INTO exam_scores (id, user_id, exam_type, score, created_at)
			VALUES ($1, $2, $3, $4, $5)
		`, examScoreUUID, userUUID, "General", *req.ExamScores, now)
		if examErr != nil {
			fmt.Printf("⚠️ Exam scores insert failed: %v\n", examErr)
		} else {
			fmt.Printf("✅ Saved exam scores for user\n")
		}
	}

	// Insert Work Experience
	for _, exp := range req.WorkExperience {
		if exp.CompanyName != "" && exp.Position != "" {
			expUUID := uuid.New().String()

			// Handle empty start_date - use current date as default
			startDate := exp.StartDate
			if startDate == "" {
				startDate = now.Format("2006-01-02")
			}

			// Handle empty end_date - use NULL
			var endDate interface{}
			if exp.EndDate != "" {
				endDate = exp.EndDate
			} else {
				endDate = nil
			}

			_, err := config.DB.Exec(`
				INSERT INTO work_experience (id, user_id, company_name, position, start_date, end_date, created_at)
				VALUES ($1, $2, $3, $4, $5, $6, $7)
			`, expUUID, userUUID, exp.CompanyName, exp.Position, startDate, endDate, now)
			if err != nil {
				fmt.Printf("❌ Error inserting work experience for user %s: %v\n", userUUID, err)
			} else {
				fmt.Printf("✅ Inserted work experience: %s at %s\n", exp.Position, exp.CompanyName)
			}
		}
	}

	// Get role, department, and branch names for email
	var roleName, departmentName, branchName string
	config.DB.QueryRow("SELECT name FROM roles WHERE id = $1", req.RoleID).Scan(&roleName)
	if req.DepartmentID != nil {
		config.DB.QueryRow("SELECT name FROM departments WHERE id = $1", *req.DepartmentID).Scan(&departmentName)
	}
	if req.BranchID != nil {
		config.DB.QueryRow("SELECT name FROM branches WHERE id = $1", *req.BranchID).Scan(&branchName)
	}

	// Send welcome email with account credentials
	emailErr := utils.SendAccountCreatedEmail(req.Email, req.FullName, req.Email, defaultPassword, roleName, departmentName, branchName)
	if emailErr != nil {
		// Log error but don't fail the request
		fmt.Printf("⚠️ Failed to send welcome email to %s: %v\n", req.Email, emailErr)
	}

	response := gin.H{
		"message":  "Staff created successfully",
		"id":       userUUID,
		"email":    req.Email,
		"password": defaultPassword,
	}
	if employeeID != nil {
		response["employee_id"] = *employeeID
	}
	c.JSON(http.StatusCreated, response)
}

// UploadGuarantorDoc uploads a document for a guarantor
func UploadGuarantorDoc(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	userID := c.Param("user_id")

	var req struct {
		GuarantorNumber int    `json:"guarantor_number"`
		DocumentType    string `json:"document_type"`
		DocumentURL     string `json:"document_url"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	now := time.Now()

	// Find the guarantor ID for this user, or create one if it doesn't exist
	var guarantorID string
	err := db.QueryRow(`
		SELECT id FROM guarantors 
		WHERE user_id = $1 AND guarantor_number = $2 
		LIMIT 1
	`, userID, req.GuarantorNumber).Scan(&guarantorID)

	if err != nil {
		// Guarantor doesn't exist, create one with a placeholder name
		guarantorID = uuid.New().String()
		guarantorName := fmt.Sprintf("Guarantor %d", req.GuarantorNumber)
		_, createErr := db.Exec(`
			INSERT INTO guarantors (id, user_id, guarantor_number, full_name, created_at, updated_at)
			VALUES ($1, $2, $3, $4, $5, $6)
		`, guarantorID, userID, req.GuarantorNumber, guarantorName, now, now)
		if createErr != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create guarantor record: " + createErr.Error()})
			return
		}
		fmt.Printf("✅ Created guarantor record for user %s, guarantor %d\n", userID, req.GuarantorNumber)
	}

	// Check if document already exists
	var existingID string
	err = db.QueryRow(`
		SELECT id FROM guarantor_documents 
		WHERE guarantor_id = $1 AND document_type = $2
	`, guarantorID, req.DocumentType).Scan(&existingID)

	if err == nil {
		// Update existing document
		_, err = db.Exec(`
			UPDATE guarantor_documents 
			SET file_path = $1, updated_at = $2 
			WHERE id = $3
		`, req.DocumentURL, now, existingID)
	} else {
		// Insert new document
		docUUID := uuid.New().String()
		_, err = db.Exec(`
			INSERT INTO guarantor_documents (id, guarantor_id, document_type, file_path, created_at, updated_at)
			VALUES ($1, $2, $3, $4, $5, $6)
		`, docUUID, guarantorID, req.DocumentType, req.DocumentURL, now, now)
	}

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save document: " + err.Error()})
		return
	}

	fmt.Printf("✅ Saved guarantor document: user=%s, guarantor=%d, type=%s\n", userID, req.GuarantorNumber, req.DocumentType)
	c.JSON(http.StatusOK, gin.H{"message": "Guarantor document uploaded successfully"})
}

// UpdateWorkExperience updates work experience for a staff member
func UpdateWorkExperience(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	userID := c.Param("user_id")

	var req struct {
		WorkExperience []struct {
			CompanyName string  `json:"company_name"`
			Position    string  `json:"position"`
			StartDate   string  `json:"start_date"`
			EndDate     string  `json:"end_date"`
			RoleID      *string `json:"role_id"`
			BranchID    *string `json:"branch_id"`
		} `json:"work_experience"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Start a transaction
	tx, err := db.Begin()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to start transaction"})
		return
	}
	defer tx.Rollback()

	// Delete existing work experience for this user
	_, err = tx.Exec(`DELETE FROM work_experience WHERE user_id = $1`, userID)
	if err != nil {
		fmt.Printf("Error clearing work experience for user %s: %v\n", userID, err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to clear existing work experience: " + err.Error()})
		return
	}

	// Insert new work experience entries
	now := time.Now()
	for _, exp := range req.WorkExperience {
		if exp.CompanyName != "" && exp.Position != "" {
			expUUID := uuid.New().String()

			// Handle empty start_date - use current date as default
			startDate := exp.StartDate
			if startDate == "" {
				startDate = now.Format("2006-01-02")
			}

			// Handle empty end_date - use NULL
			var endDate interface{}
			if exp.EndDate != "" {
				endDate = exp.EndDate
			} else {
				endDate = nil
			}

			_, err := tx.Exec(`
				INSERT INTO work_experience (id, user_id, company_name, position, start_date, end_date, created_at)
				VALUES ($1, $2, $3, $4, $5, $6, $7)
			`, expUUID, userID, exp.CompanyName, exp.Position, startDate, endDate, now)
			if err != nil {
				fmt.Printf("Error inserting work experience: %v\n", err)
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to insert work experience: " + err.Error()})
				return
			}
			fmt.Printf("✅ Added work experience: %s at %s for user %s\n", exp.Position, exp.CompanyName, userID)
		}
	}

	// Commit the transaction
	if err := tx.Commit(); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to commit transaction"})
		return
	}

	fmt.Printf("✅ Updated work experience for user %s (%d entries)\n", userID, len(req.WorkExperience))
	c.JSON(http.StatusOK, gin.H{"message": "Work experience updated successfully"})
}

// UpdateRoleHistory updates role history (roles held at Ace Mall) for a staff member
func UpdateRoleHistory(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	userID := c.Param("user_id")

	var req struct {
		RoleHistory []struct {
			RoleID          string  `json:"role_id"`
			DepartmentID    *string `json:"department_id"`
			BranchID        *string `json:"branch_id"`
			StartDate       string  `json:"start_date"`
			EndDate         string  `json:"end_date"`
			PromotionReason string  `json:"promotion_reason"`
		} `json:"role_history"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Start a transaction
	tx, err := db.Begin()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to start transaction"})
		return
	}
	defer tx.Rollback()

	// Delete existing role history for this user
	_, err = tx.Exec(`DELETE FROM role_history WHERE user_id = $1`, userID)
	if err != nil {
		fmt.Printf("Error clearing role history for user %s: %v\n", userID, err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to clear existing role history: " + err.Error()})
		return
	}

	// Insert new role history entries
	now := time.Now()
	for _, role := range req.RoleHistory {
		if role.RoleID != "" && role.StartDate != "" {
			roleUUID := uuid.New().String()

			// Handle empty end_date - use NULL (means still in this role or role ended)
			var endDate interface{}
			if role.EndDate != "" {
				endDate = role.EndDate
			} else {
				endDate = nil
			}

			_, err := tx.Exec(`
				INSERT INTO role_history (id, user_id, role_id, department_id, branch_id, start_date, end_date, promotion_reason, created_by, created_at)
				VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
			`, roleUUID, userID, role.RoleID, role.DepartmentID, role.BranchID, role.StartDate, endDate, role.PromotionReason, nil, now)
			if err != nil {
				fmt.Printf("Error inserting role history: %v\n", err)
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to insert role history: " + err.Error()})
				return
			}
		}
	}

	// Commit the transaction
	if err := tx.Commit(); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to commit transaction"})
		return
	}

	fmt.Printf("✅ Updated role history for user %s (%d entries)\n", userID, len(req.RoleHistory))
	c.JSON(http.StatusOK, gin.H{"message": "Role history updated successfully"})
}
