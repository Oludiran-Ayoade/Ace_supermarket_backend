package handlers

import (
	"database/sql"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

// CreateMasterHR creates or resets the master HR account
// Email: hr@acesupermarket.com
// Password: AceHR2024!
func CreateMasterHR(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)

	// Get Human Resource role ID
	var hrRoleID string
	err := db.QueryRow(`SELECT id FROM roles WHERE name = 'Human Resource' LIMIT 1`).Scan(&hrRoleID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Human Resource role not found"})
		return
	}

	// Hash password: AceHR2024!
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte("AceHR2024!"), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to hash password"})
		return
	}

	// Delete existing master HR if exists
	_, _ = db.Exec(`DELETE FROM users WHERE email = 'hr@acesupermarket.com'`)

	// Create master HR account
	masterHRID := uuid.New().String()
	_, err = db.Exec(`
		INSERT INTO users (
			id, email, password, full_name, role_id, employee_id,
			is_active, is_email_verified, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW(), NOW())
	`,
		masterHRID,
		"hr@acesupermarket.com",
		string(hashedPassword),
		"Master HR Administrator",
		hrRoleID,
		"HR-MASTER-001",
		true, // is_active
		true, // is_email_verified
	)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create master HR: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":     "✅ Master HR account created successfully",
		"email":       "hr@acesupermarket.com",
		"password":    "AceHR2024!",
		"employee_id": "HR-MASTER-001",
		"note":        "This account will NOT be deleted during cleanup operations",
	})
}
