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

// CreateStaffByFloorManager allows floor managers to create staff in their department
func CreateStaffByFloorManager(c *gin.Context) {
	userID := c.GetString("user_id")

	// Get floor manager's info
	var managerDepartmentID, managerBranchID sql.NullString
	var managerRoleCategory string

	err := config.DB.QueryRow(`
		SELECT r.category, u.department_id, u.branch_id
		FROM users u
		LEFT JOIN roles r ON u.role_id = r.id
		WHERE u.id = $1
	`, userID).Scan(&managerRoleCategory, &managerDepartmentID, &managerBranchID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get manager info"})
		return
	}

	// Verify user is a Floor Manager
	if managerRoleCategory != "admin" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only Floor Managers can create staff"})
		return
	}

	// Parse request
	var req struct {
		FullName     string  `json:"full_name" binding:"required"`
		Email        string  `json:"email" binding:"required,email"`
		Phone        *string `json:"phone"`
		EmployeeID   *string `json:"employee_id"`
		RoleID       string  `json:"role_id" binding:"required"`
		DepartmentID string  `json:"department_id" binding:"required"`
		BranchID     string  `json:"branch_id" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Generate default password from email prefix (e.g., adebola123@gmail.com -> adebola123)
	emailParts := strings.Split(req.Email, "@")
	defaultPassword := emailParts[0]

	// Verify the department and branch match the floor manager's
	if !managerDepartmentID.Valid || managerDepartmentID.String != req.DepartmentID {
		c.JSON(http.StatusForbidden, gin.H{"error": "You can only create staff in your own department"})
		return
	}

	if !managerBranchID.Valid || managerBranchID.String != req.BranchID {
		c.JSON(http.StatusForbidden, gin.H{"error": "You can only create staff in your own branch"})
		return
	}

	// Verify the role is a general staff role (not admin)
	var roleCategory string
	err = config.DB.QueryRow("SELECT category FROM roles WHERE id = $1", req.RoleID).Scan(&roleCategory)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid role"})
		return
	}

	if roleCategory != "general" {
		c.JSON(http.StatusForbidden, gin.H{"error": "You can only create general staff roles"})
		return
	}

	// Check if email already exists
	var existingID string
	err = config.DB.QueryRow("SELECT id FROM users WHERE email = $1", req.Email).Scan(&existingID)
	if err == nil {
		c.JSON(http.StatusConflict, gin.H{"error": "Email already exists"})
		return
	}

	// Hash default password
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

	// Create user
	userUUID := uuid.New().String()
	now := time.Now()

	_, err = config.DB.Exec(`
		INSERT INTO users (
			id, email, password_hash, full_name, phone, role_id, 
			department_id, branch_id, employee_id, manager_id,
			is_active, is_terminated, date_joined, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
	`, userUUID, req.Email, hashedPassword, req.FullName, req.Phone, req.RoleID,
		req.DepartmentID, req.BranchID, employeeID, userID,
		true, false, now, now, now)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user"})
		return
	}

	// Get created user details
	var user struct {
		ID             string  `json:"id"`
		Email          string  `json:"email"`
		FullName       string  `json:"full_name"`
		Phone          *string `json:"phone"`
		EmployeeID     *string `json:"employee_id"`
		RoleName       *string `json:"role_name"`
		DepartmentName *string `json:"department_name"`
		BranchName     *string `json:"branch_name"`
	}

	err = config.DB.QueryRow(`
		SELECT u.id, u.email, u.full_name, u.phone, u.employee_id,
		       r.name as role_name, d.name as department_name, b.name as branch_name
		FROM users u
		LEFT JOIN roles r ON u.role_id = r.id
		LEFT JOIN departments d ON u.department_id = d.id
		LEFT JOIN branches b ON u.branch_id = b.id
		WHERE u.id = $1
	`, userUUID).Scan(
		&user.ID, &user.Email, &user.FullName, &user.Phone, &user.EmployeeID,
		&user.RoleName, &user.DepartmentName, &user.BranchName,
	)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve user details"})
		return
	}

	// Get role, department, and branch names for email
	roleName := ""
	departmentName := ""
	branchName := ""
	if user.RoleName != nil {
		roleName = *user.RoleName
	}
	if user.DepartmentName != nil {
		departmentName = *user.DepartmentName
	}
	if user.BranchName != nil {
		branchName = *user.BranchName
	}

	// Send welcome email with account credentials
	err = utils.SendAccountCreatedEmail(req.Email, req.FullName, req.Email, defaultPassword, roleName, departmentName, branchName)
	if err != nil {
		// Log error but don't fail the request
		fmt.Printf("⚠️ Failed to send welcome email to %s: %v\n", req.Email, err)
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Staff created successfully. Welcome email sent.",
		"user":    user,
	})
}
