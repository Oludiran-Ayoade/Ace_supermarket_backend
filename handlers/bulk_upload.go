package handlers

import (
	"ace-mall-backend/utils"
	"database/sql"
	"encoding/csv"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// BulkUploadStaff handles CSV upload of multiple staff members
func BulkUploadStaff(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)

	// Parse multipart form
	file, _, err := c.Request.FormFile("csv_file")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "CSV file is required"})
		return
	}
	defer file.Close()

	// Parse CSV
	reader := csv.NewReader(file)
	reader.TrimLeadingSpace = true

	// Read header
	header, err := reader.Read()
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Failed to read CSV header"})
		return
	}

	// Validate required columns
	requiredColumns := []string{
		"full_name", "email", "phone_number", "role_id", "gender",
	}

	headerMap := make(map[string]int)
	for i, col := range header {
		headerMap[strings.ToLower(strings.TrimSpace(col))] = i
	}

	for _, required := range requiredColumns {
		if _, exists := headerMap[required]; !exists {
			c.JSON(http.StatusBadRequest, gin.H{
				"error": fmt.Sprintf("Missing required column: %s", required),
			})
			return
		}
	}

	// Process rows
	var successCount, errorCount int
	var errors []map[string]interface{}
	now := time.Now()

	for rowNum := 2; ; rowNum++ { // Start at row 2 (after header)
		record, err := reader.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			errorCount++
			errors = append(errors, map[string]interface{}{
				"row":   rowNum,
				"error": "Failed to parse row",
			})
			continue
		}

		// Extract data from CSV
		fullName := getCSVValue(record, headerMap, "full_name")
		email := getCSVValue(record, headerMap, "email")
		phone := getCSVValue(record, headerMap, "phone_number")
		roleID := getCSVValue(record, headerMap, "role_id")
		gender := getCSVValue(record, headerMap, "gender")
		dob := getCSVValue(record, headerMap, "date_of_birth")
		maritalStatus := getCSVValue(record, headerMap, "marital_status")
		stateOfOrigin := getCSVValue(record, headerMap, "state_of_origin")
		homeAddress := getCSVValue(record, headerMap, "home_address")
		employeeID := getCSVValue(record, headerMap, "employee_id")
		departmentID := getCSVValue(record, headerMap, "department_id")
		branchID := getCSVValue(record, headerMap, "branch_id")
		salary := getCSVValue(record, headerMap, "salary")

		// Education
		courseOfStudy := getCSVValue(record, headerMap, "course_of_study")
		grade := getCSVValue(record, headerMap, "grade")
		institution := getCSVValue(record, headerMap, "institution")

		// Next of Kin
		nokName := getCSVValue(record, headerMap, "nok_name")
		nokRelationship := getCSVValue(record, headerMap, "nok_relationship")
		nokPhone := getCSVValue(record, headerMap, "nok_phone")
		nokEmail := getCSVValue(record, headerMap, "nok_email")
		nokHomeAddress := getCSVValue(record, headerMap, "nok_home_address")
		nokWorkAddress := getCSVValue(record, headerMap, "nok_work_address")

		// Guarantor 1
		g1Name := getCSVValue(record, headerMap, "g1_name")
		g1Phone := getCSVValue(record, headerMap, "g1_phone")
		g1Occupation := getCSVValue(record, headerMap, "g1_occupation")
		g1Relationship := getCSVValue(record, headerMap, "g1_relationship")
		g1Address := getCSVValue(record, headerMap, "g1_address")
		g1Email := getCSVValue(record, headerMap, "g1_email")

		// Guarantor 2
		g2Name := getCSVValue(record, headerMap, "g2_name")
		g2Phone := getCSVValue(record, headerMap, "g2_phone")
		g2Occupation := getCSVValue(record, headerMap, "g2_occupation")
		g2Relationship := getCSVValue(record, headerMap, "g2_relationship")
		g2Address := getCSVValue(record, headerMap, "g2_address")
		g2Email := getCSVValue(record, headerMap, "g2_email")

		// Validate required fields
		if fullName == "" || email == "" || phone == "" || roleID == "" {
			errorCount++
			errors = append(errors, map[string]interface{}{
				"row":   rowNum,
				"email": email,
				"error": "Missing required fields (full_name, email, phone_number, or role_id)",
			})
			continue
		}

		// Check if email already exists
		var existingID string
		err = db.QueryRow("SELECT id FROM users WHERE email = $1", email).Scan(&existingID)
		if err == nil {
			errorCount++
			errors = append(errors, map[string]interface{}{
				"row":   rowNum,
				"email": email,
				"error": "Email already exists",
			})
			continue
		}

		// Generate password from email
		emailParts := strings.Split(email, "@")
		defaultPassword := emailParts[0]
		hashedPassword, err := utils.HashPassword(defaultPassword)
		if err != nil {
			errorCount++
			errors = append(errors, map[string]interface{}{
				"row":   rowNum,
				"email": email,
				"error": "Failed to hash password",
			})
			continue
		}

		// Create user
		userUUID := uuid.New().String()

		var dobTime interface{}
		if dob != "" {
			parsedDob, err := time.Parse("2006-01-02", dob)
			if err == nil {
				dobTime = parsedDob
			}
		}

		var salaryFloat interface{}
		if salary != "" {
			fmt.Sscanf(salary, "%f", &salaryFloat)
		}

		query := `
			INSERT INTO users (
				id, email, password_hash, full_name, phone_number, role_id,
				department_id, branch_id, employee_id, gender, marital_status,
				state_of_origin, home_address, date_of_birth, current_salary,
				course_of_study, grade, institution,
				is_active, is_terminated, date_joined, created_at, updated_at
			) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23)
		`

		_, err = db.Exec(query,
			userUUID, email, hashedPassword, fullName, phone, roleID,
			nullString(departmentID), nullString(branchID), nullString(employeeID),
			nullString(gender), nullString(maritalStatus), nullString(stateOfOrigin),
			nullString(homeAddress), dobTime, salaryFloat,
			nullString(courseOfStudy), nullString(grade), nullString(institution),
			true, false, now, now, now)

		if err != nil {
			errorCount++
			errors = append(errors, map[string]interface{}{
				"row":   rowNum,
				"email": email,
				"error": fmt.Sprintf("Failed to create user: %v", err),
			})
			continue
		}

		// Insert Next of Kin if provided
		if nokName != "" {
			nokUUID := uuid.New().String()
			_, _ = db.Exec(`
				INSERT INTO next_of_kin (id, user_id, full_name, relationship, email, phone_number, home_address, work_address, created_at, updated_at)
				VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
			`, nokUUID, userUUID, nokName, nokRelationship, nokEmail, nokPhone, nokHomeAddress, nokWorkAddress, now, now)
		}

		// Insert Guarantor 1 if provided
		if g1Name != "" {
			g1UUID := uuid.New().String()
			_, _ = db.Exec(`
				INSERT INTO guarantors (id, user_id, guarantor_number, full_name, phone_number, occupation, relationship, home_address, email, created_at, updated_at)
				VALUES ($1, $2, 1, $3, $4, $5, $6, $7, $8, $9, $10)
			`, g1UUID, userUUID, g1Name, g1Phone, g1Occupation, g1Relationship, g1Address, g1Email, now, now)
		}

		// Insert Guarantor 2 if provided
		if g2Name != "" {
			g2UUID := uuid.New().String()
			_, _ = db.Exec(`
				INSERT INTO guarantors (id, user_id, guarantor_number, full_name, phone_number, occupation, relationship, home_address, email, created_at, updated_at)
				VALUES ($1, $2, 2, $3, $4, $5, $6, $7, $8, $9, $10)
			`, g2UUID, userUUID, g2Name, g2Phone, g2Occupation, g2Relationship, g2Address, g2Email, now, now)
		}

		// Send welcome email (non-blocking)
		go func(userEmail, userName, userPass string) {
			_ = utils.SendAccountCreatedEmail(userEmail, userName, userEmail, userPass, "", "", "")
		}(email, fullName, defaultPassword)

		successCount++
	}

	c.JSON(http.StatusOK, gin.H{
		"message":       "Bulk upload completed",
		"success_count": successCount,
		"error_count":   errorCount,
		"errors":        errors,
	})
}

// Helper function to get CSV value safely
func getCSVValue(record []string, headerMap map[string]int, columnName string) string {
	if idx, exists := headerMap[columnName]; exists && idx < len(record) {
		return strings.TrimSpace(record[idx])
	}
	return ""
}

// Helper function to convert string to sql.NullString
func nullString(s string) interface{} {
	if s == "" {
		return nil
	}
	return s
}
