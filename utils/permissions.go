package utils

import (
	"ace-mall-backend/models"
	"database/sql"
	"fmt"
	"strings"
)

// PermissionLevel defines what a user can see/do
type PermissionLevel string

const (
	PermissionNone       PermissionLevel = "none"
	PermissionViewBasic  PermissionLevel = "view_basic"  // Staff can view their own basic info
	PermissionViewFull   PermissionLevel = "view_full"   // HR/CEO/COO can view everything
	PermissionEditBasic  PermissionLevel = "edit_basic"  // Staff can edit profile picture
	PermissionEditFull   PermissionLevel = "edit_full"   // HR can edit/delete documents
	PermissionManageTeam PermissionLevel = "manage_team" // Floor managers can manage their team
	PermissionViewTeam   PermissionLevel = "view_team"   // Managers can view their team
)

// CanViewProfile checks if requester can view target user's profile
func CanViewProfile(db *sql.DB, requesterID string, targetUserID string) (PermissionLevel, error) {
	// Get requester's role and hierarchy
	var requesterRole, requesterBranchID, requesterDeptID sql.NullString
	var requesterRoleCategory string

	err := db.QueryRow(`
		SELECT r.category, r.name, u.branch_id, u.department_id
		FROM users u
		INNER JOIN roles r ON u.role_id = r.id
		WHERE u.id = $1
	`, requesterID).Scan(&requesterRoleCategory, &requesterRole, &requesterBranchID, &requesterDeptID)

	if err != nil {
		return PermissionNone, err
	}

	// If viewing own profile
	if requesterID == targetUserID {
		return PermissionViewBasic, nil
	}

	// Only HR, CEO, and COO can view FULL profile (documents, next of kin, guarantors)
	if requesterRole.String == "Human Resource" ||
		requesterRole.String == "Chief Executive Officer" ||
		requesterRole.String == "Chief Operating Officer" {
		return PermissionViewFull, nil
	}

	// Chairman and Auditors can view basic staff info only (no documents/guarantors)
	if requesterRole.String == "Chairman" ||
		requesterRole.String == "Auditor" ||
		requesterRoleCategory == "senior_admin" {
		return PermissionViewTeam, nil
	}

	// Group Heads can view basic info for staff in their department across all branches
	if strings.Contains(requesterRole.String, "Group Head") {
		var targetDeptID sql.NullString
		err := db.QueryRow(`SELECT department_id FROM users WHERE id = $1`, targetUserID).Scan(&targetDeptID)
		if err != nil {
			return PermissionNone, err
		}
		if requesterDeptID.Valid && targetDeptID.Valid && requesterDeptID.String == targetDeptID.String {
			return PermissionViewTeam, nil
		}
	}

	// Branch Managers can view basic info for all staff in their branch
	if strings.Contains(requesterRole.String, "Branch Manager") {
		var targetBranchID sql.NullString
		err := db.QueryRow(`SELECT branch_id FROM users WHERE id = $1`, targetUserID).Scan(&targetBranchID)
		if err != nil {
			return PermissionNone, err
		}
		if requesterBranchID.Valid && targetBranchID.Valid && requesterBranchID.String == targetBranchID.String {
			return PermissionViewTeam, nil
		}
	}

	// Floor Managers can view basic info for staff in their department and branch
	if strings.Contains(requesterRole.String, "Floor Manager") {
		var targetBranchID, targetDeptID sql.NullString
		err := db.QueryRow(`
			SELECT branch_id, department_id FROM users WHERE id = $1
		`, targetUserID).Scan(&targetBranchID, &targetDeptID)
		if err != nil {
			return PermissionNone, err
		}
		if requesterBranchID.Valid && targetBranchID.Valid && requesterBranchID.String == targetBranchID.String &&
			requesterDeptID.Valid && targetDeptID.Valid && requesterDeptID.String == targetDeptID.String {
			return PermissionViewTeam, nil
		}
	}

	return PermissionNone, nil
}

// CanEditDocuments checks if requester can edit/delete documents for target user
func CanEditDocuments(db *sql.DB, requesterID string, targetUserID string) (bool, error) {
	var requesterRole string
	err := db.QueryRow(`
		SELECT r.name
		FROM users u
		INNER JOIN roles r ON u.role_id = r.id
		WHERE u.id = $1
	`, requesterID).Scan(&requesterRole)

	if err != nil {
		return false, err
	}

	// Only HR can edit/delete documents
	return requesterRole == "Human Resource", nil
}

// CanEditProfilePicture checks if user can edit profile picture
func CanEditProfilePicture(requesterID string, targetUserID string) bool {
	// Staff can only edit their own profile picture
	return requesterID == targetUserID
}

// CanCreateStaff checks if user can create staff profiles
func CanCreateStaff(db *sql.DB, requesterID string) (bool, string, error) {
	var requesterRole string
	err := db.QueryRow(`
		SELECT r.name
		FROM users u
		INNER JOIN roles r ON u.role_id = r.id
		WHERE u.id = $1
	`, requesterID).Scan(&requesterRole)

	if err != nil {
		return false, "", err
	}

	// HR can create all staff
	if requesterRole == "Human Resource" {
		return true, "all", nil
	}

	// Floor Managers can create general staff under them
	if requesterRole == "Floor Manager" {
		return true, "team_only", nil
	}

	return false, "", nil
}

// GetUserProfile returns profile based on permission level
func GetUserProfile(db *sql.DB, userID string, permissionLevel PermissionLevel) (*models.User, error) {
	user := &models.User{}

	// Base query - always include basic info
	baseFields := `
		u.id, u.email, u.full_name, u.gender, u.date_of_birth, u.marital_status,
		u.phone_number, u.home_address, u.state_of_origin,
		u.profile_image_url, u.profile_image_public_id,
		u.employee_id, u.role_id, r.name as role_name, r.category as role_category,
		u.department_id, d.name as department_name,
		u.sub_department_id, sd.name as sub_department_name,
		u.branch_id, b.name as branch_name,
		u.date_joined, u.current_salary,
		u.course_of_study, u.grade, u.institution,
		u.is_active, u.is_terminated, u.termination_reason, u.termination_date,
		u.created_at, u.updated_at, u.last_login
	`

	// Document fields - only for full access
	documentFields := `,
		u.waec_certificate_url, u.waec_certificate_public_id,
		u.neco_certificate_url, u.neco_certificate_public_id,
		u.jamb_result_url, u.jamb_result_public_id,
		u.degree_certificate_url, u.degree_certificate_public_id,
		u.diploma_certificate_url, u.diploma_certificate_public_id,
		u.birth_certificate_url, u.birth_certificate_public_id,
		u.national_id_url, u.national_id_public_id,
		u.passport_url, u.passport_public_id,
		u.drivers_license_url, u.drivers_license_public_id,
		u.voters_card_url, u.voters_card_public_id,
		u.nysc_certificate_url, u.nysc_certificate_public_id,
		u.state_of_origin_cert_url, u.state_of_origin_cert_public_id,
		u.lga_certificate_url, u.lga_certificate_public_id,
		u.resume_url, u.resume_public_id,
		u.cover_letter_url, u.cover_letter_public_id
	`

	query := `SELECT ` + baseFields
	if permissionLevel == PermissionViewFull || permissionLevel == PermissionViewTeam {
		query += documentFields
	}
	query += `
		FROM users u
		LEFT JOIN roles r ON u.role_id = r.id
		LEFT JOIN departments d ON u.department_id = d.id
		LEFT JOIN sub_departments sd ON u.sub_department_id = sd.id
		LEFT JOIN branches b ON u.branch_id = b.id
		WHERE u.id = $1
	`

	var err error
	if permissionLevel == PermissionViewFull || permissionLevel == PermissionViewTeam {
		// Scan with documents
		err = db.QueryRow(query, userID).Scan(
			&user.ID, &user.Email, &user.FullName, &user.Gender, &user.DateOfBirth, &user.MaritalStatus,
			&user.PhoneNumber, &user.HomeAddress, &user.StateOfOrigin,
			&user.ProfileImageURL, &user.ProfileImagePublicID,
			&user.EmployeeID, &user.RoleID, &user.RoleName, &user.RoleCategory,
			&user.DepartmentID, &user.DepartmentName,
			&user.SubDepartmentID, &user.SubDepartmentName,
			&user.BranchID, &user.BranchName,
			&user.DateJoined, &user.CurrentSalary,
			&user.CourseOfStudy, &user.Grade, &user.Institution,
			&user.IsActive, &user.IsTerminated, &user.TerminationReason, &user.TerminationDate,
			&user.CreatedAt, &user.UpdatedAt, &user.LastLogin,
			// Documents
			&user.WaecCertificateURL, &user.WaecCertificatePublicID,
			&user.NecoCertificateURL, &user.NecoCertificatePublicID,
			&user.JambResultURL, &user.JambResultPublicID,
			&user.DegreeCertificateURL, &user.DegreeCertificatePublicID,
			&user.DiplomaCertificateURL, &user.DiplomaCertificatePublicID,
			&user.BirthCertificateURL, &user.BirthCertificatePublicID,
			&user.NationalIDURL, &user.NationalIDPublicID,
			&user.PassportURL, &user.PassportPublicID,
			&user.DriversLicenseURL, &user.DriversLicensePublicID,
			&user.VotersCardURL, &user.VotersCardPublicID,
			&user.NyscCertificateURL, &user.NyscCertificatePublicID,
			&user.StateOfOriginCertURL, &user.StateOfOriginCertPublicID,
			&user.LgaCertificateURL, &user.LgaCertificatePublicID,
			&user.ResumeURL, &user.ResumePublicID,
			&user.CoverLetterURL, &user.CoverLetterPublicID,
		)
	} else {
		// Scan without documents
		err = db.QueryRow(query, userID).Scan(
			&user.ID, &user.Email, &user.FullName, &user.Gender, &user.DateOfBirth, &user.MaritalStatus,
			&user.PhoneNumber, &user.HomeAddress, &user.StateOfOrigin,
			&user.ProfileImageURL, &user.ProfileImagePublicID,
			&user.EmployeeID, &user.RoleID, &user.RoleName, &user.RoleCategory,
			&user.DepartmentID, &user.DepartmentName,
			&user.SubDepartmentID, &user.SubDepartmentName,
			&user.BranchID, &user.BranchName,
			&user.DateJoined, &user.CurrentSalary,
			&user.CourseOfStudy, &user.Grade, &user.Institution,
			&user.IsActive, &user.IsTerminated, &user.TerminationReason, &user.TerminationDate,
			&user.CreatedAt, &user.UpdatedAt, &user.LastLogin,
		)
	}

	if err != nil {
		return nil, err
	}

	// Fetch Work Experience - available for all permission levels (including own profile)
	workExpRows, err := db.Query(`
		SELECT company_name, position, start_date, end_date, responsibilities
		FROM work_experience
		WHERE user_id = $1
		ORDER BY start_date DESC
	`, userID)
	if err == nil {
		defer workExpRows.Close()
		workExperience := []map[string]interface{}{}
		for workExpRows.Next() {
			var companyName, position string
			var startDate, endDate sql.NullString
			var responsibilities sql.NullString

			if err := workExpRows.Scan(&companyName, &position, &startDate, &endDate, &responsibilities); err == nil {
				exp := map[string]interface{}{
					"company_name": companyName,
					"position":     position,
				}
				if startDate.Valid {
					exp["start_date"] = startDate.String
				}
				if endDate.Valid {
					exp["end_date"] = endDate.String
				}
				if responsibilities.Valid {
					exp["responsibilities"] = responsibilities.String
				}
				workExperience = append(workExperience, exp)
			}
		}
		if len(workExperience) > 0 {
			user.WorkExperience = workExperience
		}
	}

	// Fetch Role History (roles held at Ace Mall) - available for all permission levels
	roleHistoryRows, err := db.Query(`
		SELECT rh.id, r.name as role_name, d.name as department_name, b.name as branch_name,
		       rh.start_date, rh.end_date, rh.promotion_reason
		FROM role_history rh
		LEFT JOIN roles r ON rh.role_id = r.id
		LEFT JOIN departments d ON rh.department_id = d.id
		LEFT JOIN branches b ON rh.branch_id = b.id
		WHERE rh.user_id = $1
		ORDER BY rh.start_date DESC
	`, userID)
	if err == nil {
		defer roleHistoryRows.Close()
		roleHistory := []map[string]interface{}{}
		for roleHistoryRows.Next() {
			var id, roleName string
			var departmentName, branchName sql.NullString
			var startDate, endDate sql.NullString
			var promotionReason sql.NullString

			if err := roleHistoryRows.Scan(&id, &roleName, &departmentName, &branchName, &startDate, &endDate, &promotionReason); err == nil {
				role := map[string]interface{}{
					"id":        id,
					"role_name": roleName,
				}
				if departmentName.Valid {
					role["department_name"] = departmentName.String
				}
				if branchName.Valid {
					role["branch_name"] = branchName.String
				}
				if startDate.Valid {
					role["start_date"] = startDate.String
				}
				if endDate.Valid {
					role["end_date"] = endDate.String
				}
				if promotionReason.Valid {
					role["promotion_reason"] = promotionReason.String
				}
				roleHistory = append(roleHistory, role)
			}
		}
		if len(roleHistory) > 0 {
			user.RoleHistory = roleHistory
		}
	}

	// Fetch Exam Scores - available for all permission levels
	examScoresRows, err := db.Query(`
		SELECT exam_type, score, year_taken
		FROM exam_scores
		WHERE user_id = $1
		ORDER BY created_at DESC
	`, userID)
	if err == nil {
		defer examScoresRows.Close()
		examScores := []map[string]interface{}{}
		for examScoresRows.Next() {
			var examType, score string
			var yearTaken sql.NullInt64

			if err := examScoresRows.Scan(&examType, &score, &yearTaken); err == nil {
				exam := map[string]interface{}{
					"exam_type": examType,
					"score":     score,
				}
				if yearTaken.Valid {
					exam["year_taken"] = yearTaken.Int64
				}
				examScores = append(examScores, exam)
			}
		}
		if len(examScores) > 0 {
			user.ExamScores = examScores
		}
	}

	// Fetch Next of Kin and Guarantors for view_full and view_team permissions
	// This allows HR/CEO/COO and managers (Branch Managers, Floor Managers) to see this info
	if permissionLevel != PermissionViewFull && permissionLevel != PermissionViewTeam {
		return user, nil
	}

	// Fetch Next of Kin
	var nokName, nokRelationship, nokPhone, nokEmail, nokHomeAddress, nokWorkAddress sql.NullString
	db.QueryRow(`
		SELECT full_name, relationship, phone_number, email, home_address, work_address
		FROM next_of_kin WHERE user_id = $1 LIMIT 1
	`, userID).Scan(&nokName, &nokRelationship, &nokPhone, &nokEmail, &nokHomeAddress, &nokWorkAddress)

	if nokName.Valid {
		user.NextOfKinName = &nokName.String
	}
	if nokRelationship.Valid {
		user.NextOfKinRelationship = &nokRelationship.String
	}
	if nokPhone.Valid {
		user.NextOfKinPhone = &nokPhone.String
	}
	if nokEmail.Valid {
		user.NextOfKinEmail = &nokEmail.String
	}
	if nokHomeAddress.Valid {
		user.NextOfKinHomeAddress = &nokHomeAddress.String
	}
	if nokWorkAddress.Valid {
		user.NextOfKinWorkAddress = &nokWorkAddress.String
	}

	// Fetch Guarantor 1
	var g1ID, g1Name, g1Phone, g1Occupation, g1Relationship, g1Address, g1Email sql.NullString
	db.QueryRow(`
		SELECT id, full_name, phone_number, occupation, relationship, home_address, email
		FROM guarantors WHERE user_id = $1 AND guarantor_number = 1 LIMIT 1
	`, userID).Scan(&g1ID, &g1Name, &g1Phone, &g1Occupation, &g1Relationship, &g1Address, &g1Email)

	if g1Name.Valid {
		user.Guarantor1Name = &g1Name.String
	}
	if g1Phone.Valid {
		user.Guarantor1Phone = &g1Phone.String
	}
	if g1Occupation.Valid {
		user.Guarantor1Occupation = &g1Occupation.String
	}
	if g1Relationship.Valid {
		user.Guarantor1Relationship = &g1Relationship.String
	}
	if g1Address.Valid {
		user.Guarantor1Address = &g1Address.String
	}
	if g1Email.Valid {
		user.Guarantor1Email = &g1Email.String
	}

	// Fetch Guarantor 1 Documents
	if g1ID.Valid {
		fmt.Printf("🔍 Fetching documents for Guarantor 1 ID: %s\n", g1ID.String)
		rows, err := db.Query(`
			SELECT document_type, file_path
			FROM guarantor_documents
			WHERE guarantor_id = $1
		`, g1ID.String)
		if err != nil {
			fmt.Printf("❌ Error querying guarantor 1 documents: %v\n", err)
		} else {
			defer rows.Close()
			docCount := 0
			for rows.Next() {
				var docType, filePath string
				if err := rows.Scan(&docType, &filePath); err == nil {
					docCount++
					fmt.Printf("✅ Found Guarantor 1 document: %s = %s\n", docType, filePath)
					switch docType {
					case "passport":
						user.Guarantor1Passport = &filePath
					case "national_id":
						user.Guarantor1NationalID = &filePath
					case "work_id":
						user.Guarantor1WorkID = &filePath
					}
				}
			}
			fmt.Printf("📊 Total Guarantor 1 documents found: %d\n", docCount)
		}
	}

	// Fetch Guarantor 2
	fmt.Printf("🔍 Querying Guarantor 2 for user_id: %s\n", userID)
	var g2ID, g2Name, g2Phone, g2Occupation, g2Relationship, g2Address, g2Email sql.NullString
	err = db.QueryRow(`
		SELECT id, full_name, phone_number, occupation, relationship, home_address, email
		FROM guarantors WHERE user_id = $1 AND guarantor_number = 2 LIMIT 1
	`, userID).Scan(&g2ID, &g2Name, &g2Phone, &g2Occupation, &g2Relationship, &g2Address, &g2Email)

	if err != nil && err != sql.ErrNoRows {
		fmt.Printf("❌ Error querying Guarantor 2: %v\n", err)
	} else if err == sql.ErrNoRows {
		fmt.Printf("⚠️ No Guarantor 2 record found for user %s\n", userID)
	} else {
		fmt.Printf("✅ Found Guarantor 2 record: ID=%v, Name=%v\n", g2ID.Valid, g2Name.Valid)
	}

	if g2Name.Valid {
		user.Guarantor2Name = &g2Name.String
	}
	if g2Phone.Valid {
		user.Guarantor2Phone = &g2Phone.String
	}
	if g2Occupation.Valid {
		user.Guarantor2Occupation = &g2Occupation.String
	}
	if g2Relationship.Valid {
		user.Guarantor2Relationship = &g2Relationship.String
	}
	if g2Address.Valid {
		user.Guarantor2Address = &g2Address.String
	}
	if g2Email.Valid {
		user.Guarantor2Email = &g2Email.String
	}

	// Fetch Guarantor 2 Documents
	if g2ID.Valid {
		fmt.Printf("🔍 Fetching documents for Guarantor 2 ID: %s\n", g2ID.String)
		rows, err := db.Query(`
			SELECT document_type, file_path
			FROM guarantor_documents
			WHERE guarantor_id = $1
		`, g2ID.String)
		if err != nil {
			fmt.Printf("❌ Error querying guarantor 2 documents: %v\n", err)
		} else {
			defer rows.Close()
			docCount := 0
			for rows.Next() {
				var docType, filePath string
				if err := rows.Scan(&docType, &filePath); err == nil {
					docCount++
					fmt.Printf("✅ Found Guarantor 2 document: %s = %s\n", docType, filePath)
					switch docType {
					case "passport":
						user.Guarantor2Passport = &filePath
					case "national_id":
						user.Guarantor2NationalID = &filePath
					case "work_id":
						user.Guarantor2WorkID = &filePath
					}
				}
			}
			fmt.Printf("📊 Total Guarantor 2 documents found: %d\n", docCount)
		}
	}

	return user, nil
}
