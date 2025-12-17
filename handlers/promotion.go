package handlers

import (
	"database/sql"
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

// PromoteStaff handles staff promotion with role change and salary history
func PromoteStaff(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	promoterID := c.GetString("user_id")

	var req struct {
		StaffID      string  `json:"staff_id" binding:"required"`
		NewRoleID    *string `json:"new_role_id"` // null if salary increase only
		NewSalary    float64 `json:"new_salary" binding:"required,min=1"`
		Reason       string  `json:"reason"`
		BranchID     *string `json:"branch_id"`
		DepartmentID *string `json:"department_id"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Verify promoter has permission (HR, CEO, Chairman)
	var roleName, roleCategory string
	err := db.QueryRow(`
		SELECT r.name, r.category
		FROM users u
		INNER JOIN roles r ON u.role_id = r.id
		WHERE u.id = $1
	`, promoterID).Scan(&roleName, &roleCategory)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get promoter role"})
		return
	}

	// Check if user is authorized (HR, CEO, Chairman, or senior_admin category)
	if !isAuthorizedToPromote(roleName, roleCategory) {
		c.JSON(http.StatusForbidden, gin.H{
			"error":         "Only HR, CEO, or Chairman can promote staff",
			"your_role":     roleName,
			"your_category": roleCategory,
		})
		return
	}

	// Get current staff details
	var currentRoleID string
	var currentSalary float64
	var currentRoleName, staffName string
	err = db.QueryRow(`
		SELECT u.role_id, COALESCE(u.current_salary, 0), r.name, u.full_name
		FROM users u
		INNER JOIN roles r ON u.role_id = r.id
		WHERE u.id = $1
	`, req.StaffID).Scan(&currentRoleID, &currentSalary, &currentRoleName, &staffName)

	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Staff not found"})
		return
	}

	// Start transaction
	tx, err := db.Begin()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to start transaction"})
		return
	}
	defer tx.Rollback()

	// Insert into promotion_history
	var promotionID int
	err = tx.QueryRow(`
		INSERT INTO promotion_history (
			user_id,
			previous_role_id,
			new_role_id,
			previous_salary,
			new_salary,
			promotion_date,
			promoted_by,
			reason
		) VALUES ($1, $2, $3, $4, $5, CURRENT_DATE, $6, $7)
		RETURNING id
	`, req.StaffID, currentRoleID,
		func() interface{} {
			if req.NewRoleID != nil {
				return *req.NewRoleID
			}
			return currentRoleID
		}(),
		currentSalary, req.NewSalary, promoterID, req.Reason).Scan(&promotionID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to record promotion: " + err.Error()})
		return
	}

	// Update user record
	updateQuery := `UPDATE users SET current_salary = $1, updated_at = CURRENT_TIMESTAMP`
	args := []interface{}{req.NewSalary}
	argCount := 2

	if req.NewRoleID != nil {
		updateQuery += fmt.Sprintf(", role_id = $%d", argCount)
		args = append(args, *req.NewRoleID)
		argCount++
	}

	if req.BranchID != nil {
		updateQuery += fmt.Sprintf(", branch_id = $%d", argCount)
		args = append(args, *req.BranchID)
		argCount++
	}

	if req.DepartmentID != nil {
		updateQuery += fmt.Sprintf(", department_id = $%d", argCount)
		args = append(args, *req.DepartmentID)
		argCount++
	}

	updateQuery += fmt.Sprintf(" WHERE id = $%d", argCount)
	args = append(args, req.StaffID)

	_, err = tx.Exec(updateQuery, args...)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update user: " + err.Error()})
		return
	}

	// Get new role name if role changed
	newRoleName := currentRoleName
	if req.NewRoleID != nil {
		tx.QueryRow("SELECT name FROM roles WHERE id = $1", *req.NewRoleID).Scan(&newRoleName)
	}

	// Create notification for staff
	var promoterName string
	db.QueryRow("SELECT full_name FROM users WHERE id = $1", promoterID).Scan(&promoterName)

	notificationTitle := "Promotion Notification"
	notificationMessage := promoterName + " has promoted you"
	if req.NewRoleID != nil {
		notificationMessage += " to " + newRoleName
	} else {
		notificationMessage += " with a salary increase"
	}

	tx.Exec(`
		INSERT INTO notifications (user_id, type, title, message)
		VALUES ($1, 'promotion', $2, $3)
	`, req.StaffID, notificationTitle, notificationMessage)

	// Commit transaction
	if err := tx.Commit(); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to commit promotion"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success":         true,
		"promotion_id":    promotionID,
		"message":         "Staff promoted successfully",
		"staff_name":      staffName,
		"previous_role":   currentRoleName,
		"new_role":        newRoleName,
		"previous_salary": currentSalary,
		"new_salary":      req.NewSalary,
	})
}

// GetPromotionHistory returns promotion history for a staff member
func GetPromotionHistory(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	staffID := c.Param("staff_id")

	query := `
		SELECT 
			ph.id,
			ph.promotion_date,
			pr.name as previous_role,
			nr.name as new_role,
			ph.previous_salary,
			ph.new_salary,
			ph.reason,
			u.full_name as promoted_by
		FROM promotion_history ph
		LEFT JOIN roles pr ON ph.previous_role_id = pr.id
		LEFT JOIN roles nr ON ph.new_role_id = nr.id
		INNER JOIN users u ON ph.promoted_by = u.id
		WHERE ph.user_id = $1
		ORDER BY ph.promotion_date DESC
	`

	rows, err := db.Query(query, staffID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch promotion history"})
		return
	}
	defer rows.Close()

	promotions := []map[string]interface{}{}
	for rows.Next() {
		var id, previousSalary, newSalary int
		var promotionDate time.Time
		var previousRole, newRole, reason, promotedBy string

		err := rows.Scan(&id, &promotionDate, &previousRole, &newRole,
			&previousSalary, &newSalary, &reason, &promotedBy)
		if err != nil {
			continue
		}

		increase := newSalary - previousSalary
		increasePercent := float64(increase) / float64(previousSalary) * 100

		promotions = append(promotions, map[string]interface{}{
			"id":               id,
			"date":             promotionDate.Format("2006-01-02"),
			"previous_role":    previousRole,
			"new_role":         newRole,
			"previous_salary":  previousSalary,
			"new_salary":       newSalary,
			"increase":         increase,
			"increase_percent": increasePercent,
			"reason":           reason,
			"promoted_by":      promotedBy,
		})
	}

	c.JSON(http.StatusOK, promotions)
}

func isAuthorizedToPromote(roleName, roleCategory string) bool {
	// Allow senior_admin category (HR, CEO, Chairman, COO)
	if roleCategory == "senior_admin" {
		return true
	}

	// Also check specific role names
	authorized := []string{"HR", "CEO", "Chairman", "COO"}
	for _, role := range authorized {
		if containsStr(roleName, role) {
			return true
		}
	}
	return false
}

func containsStr(s, substr string) bool {
	return len(s) >= len(substr) && (s == substr || len(s) > len(substr) && (s[:len(substr)] == substr || s[len(s)-len(substr):] == substr || containsStrMiddle(s, substr)))
}

func containsStrMiddle(s, substr string) bool {
	for i := 0; i <= len(s)-len(substr); i++ {
		if s[i:i+len(substr)] == substr {
			return true
		}
	}
	return false
}
