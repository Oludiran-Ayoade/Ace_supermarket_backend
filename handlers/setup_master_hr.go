package handlers

import (
	"database/sql"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// CreateMasterHR creates or resets the master HR account
// Email: hr@acesupermarket.com
// Password: password123
func CreateMasterHR(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)

	// Get Human Resource role ID
	var hrRoleID string
	err := db.QueryRow(`SELECT id FROM roles WHERE name = 'Human Resource' LIMIT 1`).Scan(&hrRoleID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Human Resource role not found"})
		return
	}

	// Delete existing master HR if exists
	_, _ = db.Exec(`DELETE FROM users WHERE email = 'hr@acesupermarket.com'`)

	// Create master HR account
	masterHRID := uuid.New().String()
	_, err = db.Exec(`
		INSERT INTO users (
			id, email, password_hash, full_name, role_id, employee_id,
			is_active, date_joined, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, NOW(), NOW(), NOW())
	`,
		masterHRID,
		"hr@acesupermarket.com",
		"password123",
		"Master HR Administrator",
		hrRoleID,
		"HR-MASTER-001",
		true, // is_active
	)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create master HR: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":     "✅ Master HR account created successfully",
		"email":       "hr@acesupermarket.com",
		"password":    "password123",
		"employee_id": "HR-MASTER-001",
		"note":        "This account will NOT be deleted during cleanup operations",
	})
}
