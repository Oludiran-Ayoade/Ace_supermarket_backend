package handlers

import (
	"ace-mall-backend/config"
	"ace-mall-backend/models"
	"ace-mall-backend/utils"
	"database/sql"
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

// Login handles user authentication
func Login(c *gin.Context) {
	var req models.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Get user from database
	var user models.User
	var passwordHash string
	var roleCategory string

	query := `
		SELECT u.id, u.email, u.password_hash, u.full_name, u.role_id, u.department_id, 
		       u.branch_id, u.is_active, r.category, r.name as role_name
		FROM users u
		LEFT JOIN roles r ON u.role_id = r.id
		WHERE u.email = $1 AND u.is_active = true AND u.is_terminated = false
	`

	err := config.DB.QueryRow(query, req.Email).Scan(
		&user.ID, &user.Email, &passwordHash, &user.FullName, &user.RoleID,
		&user.DepartmentID, &user.BranchID, &user.IsActive, &roleCategory, &user.RoleName,
	)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid email or password"})
		return
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	// Check password
	if !utils.CheckPassword(req.Password, passwordHash) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid email or password"})
		return
	}

	// Update last login
	_, _ = config.DB.Exec("UPDATE users SET last_login = $1 WHERE id = $2", time.Now(), user.ID)

	// Generate JWT token
	roleID := ""
	if user.RoleID != nil {
		roleID = *user.RoleID
	}
	token, err := utils.GenerateToken(user.ID, user.Email, roleID, roleCategory)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
		return
	}

	// Prepare role name for response
	roleName := ""
	if user.RoleName != nil {
		roleName = *user.RoleName
	}

	c.JSON(http.StatusOK, gin.H{
		"token":     token,
		"user":      user,
		"role_name": roleName,
	})
}

// ChangePassword handles password change
func ChangePassword(c *gin.Context) {
	userID := c.GetString("user_id")

	var req struct {
		CurrentPassword string `json:"current_password" binding:"required"`
		NewPassword     string `json:"new_password" binding:"required,min=6"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Get current password hash
	var currentHash string
	err := config.DB.QueryRow("SELECT password_hash FROM users WHERE id = $1", userID).Scan(&currentHash)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	// Verify current password
	if !utils.CheckPassword(req.CurrentPassword, currentHash) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Current password is incorrect"})
		return
	}

	// Hash new password
	newHash, err := utils.HashPassword(req.NewPassword)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to hash password"})
		return
	}

	// Update password
	_, err = config.DB.Exec("UPDATE users SET password_hash = $1, updated_at = $2 WHERE id = $3",
		newHash, time.Now(), userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update password"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Password changed successfully"})
}

// GetCurrentUser returns the authenticated user's information
func GetCurrentUser(c *gin.Context) {
	userID := c.GetString("user_id")

	var user struct {
		ID             string  `json:"id"`
		Email          string  `json:"email"`
		FullName       string  `json:"full_name"`
		RoleID         *string `json:"role_id"`
		RoleName       *string `json:"role_name"`
		RoleCategory   *string `json:"role_category"`
		DepartmentID   *string `json:"department_id"`
		DepartmentName *string `json:"department_name"`
		BranchID       *string `json:"branch_id"`
		BranchName     *string `json:"branch_name"`
		IsActive       bool    `json:"is_active"`
	}

	query := `
		SELECT 
			u.id, u.email, u.full_name, u.role_id, u.department_id, u.branch_id, u.is_active,
			r.name as role_name, r.category as role_category,
			d.name as department_name,
			b.name as branch_name
		FROM users u
		LEFT JOIN roles r ON u.role_id = r.id
		LEFT JOIN departments d ON u.department_id = d.id
		LEFT JOIN branches b ON u.branch_id = b.id
		WHERE u.id = $1 AND u.is_active = true AND u.is_terminated = false
	`

	err := config.DB.QueryRow(query, userID).Scan(
		&user.ID, &user.Email, &user.FullName, &user.RoleID, &user.DepartmentID,
		&user.BranchID, &user.IsActive, &user.RoleName, &user.RoleCategory,
		&user.DepartmentName, &user.BranchName,
	)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"user": user})
}

// ForgotPassword sends OTP to user's email for password reset
func ForgotPassword(c *gin.Context) {
	var req struct {
		Email string `json:"email" binding:"required,email"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Check if user exists
	var userID, fullName string
	err := config.DB.QueryRow("SELECT id, full_name FROM users WHERE email = $1 AND is_active = true", req.Email).Scan(&userID, &fullName)
	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "No account found with this email"})
		return
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	// Generate 6-digit OTP
	otp := utils.GenerateOTP()
	expiresAt := time.Now().Add(10 * time.Minute)

	// Store OTP in database
	_, err = config.DB.Exec(`
		INSERT INTO password_reset_otps (email, otp, expires_at, created_at)
		VALUES ($1, $2, $3, $4)
		ON CONFLICT (email) DO UPDATE SET otp = $2, expires_at = $3, created_at = $4, used = false
	`, req.Email, otp, expiresAt, time.Now())

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate OTP"})
		return
	}

	// Send OTP email
	emailErr := utils.SendPasswordResetOTP(req.Email, fullName, otp)
	if emailErr != nil {
		// Log error but return success (OTP is stored)
		fmt.Printf("⚠️ Failed to send OTP email to %s: %v\n", req.Email, emailErr)
	}

	c.JSON(http.StatusOK, gin.H{
		"message":    "Password reset code sent to your email",
		"email_sent": emailErr == nil,
	})
}

// VerifyResetOTP verifies the OTP for password reset
func VerifyResetOTP(c *gin.Context) {
	var req struct {
		Email string `json:"email" binding:"required,email"`
		OTP   string `json:"otp" binding:"required,len=6"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Verify OTP
	var storedOTP string
	var expiresAt time.Time
	var used bool
	err := config.DB.QueryRow(`
		SELECT otp, expires_at, used FROM password_reset_otps 
		WHERE email = $1
	`, req.Email).Scan(&storedOTP, &expiresAt, &used)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No password reset request found"})
		return
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	// Check if OTP is expired
	if time.Now().After(expiresAt) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "OTP has expired. Please request a new one."})
		return
	}

	// Check if OTP is already used
	if used {
		c.JSON(http.StatusBadRequest, gin.H{"error": "OTP has already been used"})
		return
	}

	// Verify OTP matches
	if storedOTP != req.OTP {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid OTP"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "OTP verified successfully",
		"valid":   true,
	})
}

// ResetPassword resets password after OTP verification
func ResetPassword(c *gin.Context) {
	var req struct {
		Email       string `json:"email" binding:"required,email"`
		OTP         string `json:"otp" binding:"required,len=6"`
		NewPassword string `json:"new_password" binding:"required,min=6"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Verify OTP again
	var storedOTP string
	var expiresAt time.Time
	var used bool
	err := config.DB.QueryRow(`
		SELECT otp, expires_at, used FROM password_reset_otps 
		WHERE email = $1
	`, req.Email).Scan(&storedOTP, &expiresAt, &used)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No password reset request found"})
		return
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	if time.Now().After(expiresAt) || used || storedOTP != req.OTP {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid or expired OTP"})
		return
	}

	// Hash new password
	newHash, err := utils.HashPassword(req.NewPassword)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to hash password"})
		return
	}

	// Update password
	_, err = config.DB.Exec("UPDATE users SET password_hash = $1, updated_at = $2 WHERE email = $3",
		newHash, time.Now(), req.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update password"})
		return
	}

	// Mark OTP as used
	_, _ = config.DB.Exec("UPDATE password_reset_otps SET used = true WHERE email = $1", req.Email)

	c.JSON(http.StatusOK, gin.H{"message": "Password reset successfully"})
}

// UpdateEmail updates user's email address
func UpdateEmail(c *gin.Context) {
	userID := c.GetString("user_id")

	var req struct {
		NewEmail        string `json:"new_email" binding:"required,email"`
		CurrentPassword string `json:"current_password" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Get current password hash
	var currentHash string
	err := config.DB.QueryRow("SELECT password_hash FROM users WHERE id = $1", userID).Scan(&currentHash)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	// Verify current password
	if !utils.CheckPassword(req.CurrentPassword, currentHash) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Current password is incorrect"})
		return
	}

	// Check if new email already exists
	var existingID string
	err = config.DB.QueryRow("SELECT id FROM users WHERE email = $1 AND id != $2", req.NewEmail, userID).Scan(&existingID)
	if err == nil {
		c.JSON(http.StatusConflict, gin.H{"error": "Email already in use"})
		return
	}

	// Update email
	_, err = config.DB.Exec("UPDATE users SET email = $1, updated_at = $2 WHERE id = $3",
		req.NewEmail, time.Now(), userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update email"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Email updated successfully"})
}
