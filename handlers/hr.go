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
			u.employee_id, u.profile_image_url,
			r.id as role_id, r.name as role_name, r.category as role_category,
			d.id as department_id, d.name as department_name,
			b.id as branch_id, b.name as branch_name,
			u.current_salary, u.date_joined, u.is_active
		FROM users u
		LEFT JOIN roles r ON u.role_id = r.id
		LEFT JOIN departments d ON u.department_id = d.id
		LEFT JOIN branches b ON u.branch_id = b.id
		WHERE u.is_active = true
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
			roleID, roleName, roleCategory                   sql.NullString
			departmentID, departmentName                     sql.NullString
			branchIDVal, branchName                          sql.NullString
			currentSalary                                    sql.NullFloat64
			dateJoined                                       sql.NullTime
			isActive                                         bool
		)

		err := rows.Scan(
			&id, &email, &fullName, &gender, &phoneNumber,
			&employeeID, &profileImageURL,
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

	// Total staff count
	var totalStaff int
	err := db.QueryRow(`SELECT COUNT(*) FROM users`).Scan(&totalStaff)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch stats"})
		return
	}

	// Staff by category
	rows, err := db.Query(`
		SELECT r.category, COUNT(*) as count
		FROM users u
		INNER JOIN roles r ON u.role_id = r.id
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

	// Total staff in branch
	var totalStaff int
	err = db.QueryRow(`SELECT COUNT(*) FROM users WHERE branch_id = $1`, branchID.String).Scan(&totalStaff)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch branch stats"})
		return
	}

	// Active staff count
	var activeStaff int
	err = db.QueryRow(`SELECT COUNT(*) FROM users WHERE branch_id = $1 AND is_active = true`, branchID.String).Scan(&activeStaff)
	if err != nil {
		activeStaff = 0
	}

	// Staff by department in this branch
	rows, err := db.Query(`
		SELECT d.name, COUNT(u.id) as count
		FROM departments d
		LEFT JOIN users u ON d.id = u.department_id AND u.branch_id = $1
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
		Phone         string            `json:"phone" binding:"required"`
		EmployeeID    *string           `json:"employee_id"`
		RoleID        string            `json:"role_id" binding:"required"`
		DepartmentID  *string           `json:"department_id"`
		BranchID      *string           `json:"branch_id"`
		Gender        *string           `json:"gender"`
		MaritalStatus *string           `json:"marital_status"`
		StateOfOrigin *string           `json:"state_of_origin"`
		DateOfBirth   *string           `json:"date_of_birth"`
		HomeAddress   *string           `json:"home_address"`
		CourseOfStudy *string           `json:"course_of_study"`
		Grade         *string           `json:"grade"`
		Institution   *string           `json:"institution"`
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
		true, false, now, now, now)

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

	// Insert Guarantor 1
	if req.Guarantor1 != nil && req.Guarantor1.FullName != "" {
		g1UUID := uuid.New().String()
		_, g1Err := config.DB.Exec(`
			INSERT INTO guarantors (id, user_id, guarantor_number, full_name, phone_number, occupation, relationship, sex, age, home_address, email, grade_level, created_at, updated_at)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
		`, g1UUID, userUUID, 1, req.Guarantor1.FullName, req.Guarantor1.Phone, req.Guarantor1.Occupation,
			req.Guarantor1.Relationship, req.Guarantor1.Sex, req.Guarantor1.Age, req.Guarantor1.HomeAddress,
			req.Guarantor1.Email, req.Guarantor1.GradeLevel, now, now)
		if g1Err != nil {
			// Non-critical: guarantor 1 insert failed
		}
	}

	// Insert Guarantor 2
	if req.Guarantor2 != nil && req.Guarantor2.FullName != "" {
		g2UUID := uuid.New().String()
		_, g2Err := config.DB.Exec(`
			INSERT INTO guarantors (id, user_id, guarantor_number, full_name, phone_number, occupation, relationship, sex, age, home_address, email, grade_level, created_at, updated_at)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
		`, g2UUID, userUUID, 2, req.Guarantor2.FullName, req.Guarantor2.Phone, req.Guarantor2.Occupation,
			req.Guarantor2.Relationship, req.Guarantor2.Sex, req.Guarantor2.Age, req.Guarantor2.HomeAddress,
			req.Guarantor2.Email, req.Guarantor2.GradeLevel, now, now)
		if g2Err != nil {
			// Non-critical: guarantor 2 insert failed
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
