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

	// Get current staff details including branch and department
	var currentRoleID string
	var currentSalary float64
	var currentRoleName, staffName string
	var currentBranchID, currentDepartmentID, currentBranchName sql.NullString
	var dateJoined sql.NullTime
	err = db.QueryRow(`
		SELECT u.role_id, COALESCE(u.current_salary, 0), r.name, u.full_name,
		       u.branch_id, u.department_id, b.name, u.date_joined
		FROM users u
		INNER JOIN roles r ON u.role_id = r.id
		LEFT JOIN branches b ON u.branch_id = b.id
		WHERE u.id = $1
	`, req.StaffID).Scan(&currentRoleID, &currentSalary, &currentRoleName, &staffName,
		&currentBranchID, &currentDepartmentID, &currentBranchName, &dateJoined)

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

	// Determine new branch and department IDs
	var newBranchID, newDepartmentID interface{}
	if req.BranchID != nil {
		newBranchID = *req.BranchID
	} else if currentBranchID.Valid {
		newBranchID = currentBranchID.String
	}
	if req.DepartmentID != nil {
		newDepartmentID = *req.DepartmentID
	} else if currentDepartmentID.Valid {
		newDepartmentID = currentDepartmentID.String
	}

	// Insert into promotion_history with branch and department info
	var promotionID int
	err = tx.QueryRow(`
		INSERT INTO promotion_history (
			user_id,
			previous_role_id,
			new_role_id,
			previous_salary,
			new_salary,
			previous_branch_id,
			new_branch_id,
			previous_department_id,
			new_department_id,
			promotion_date,
			promoted_by,
			reason,
			created_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, CURRENT_DATE, $10, $11, CURRENT_TIMESTAMP)
		RETURNING id
	`, req.StaffID, currentRoleID,
		func() interface{} {
			if req.NewRoleID != nil {
				return *req.NewRoleID
			}
			return currentRoleID
		}(),
		currentSalary, req.NewSalary,
		func() interface{} {
			if currentBranchID.Valid {
				return currentBranchID.String
			}
			return nil
		}(),
		newBranchID,
		func() interface{} {
			if currentDepartmentID.Valid {
				return currentDepartmentID.String
			}
			return nil
		}(),
		newDepartmentID,
		promoterID, req.Reason).Scan(&promotionID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to record promotion: " + err.Error()})
		return
	}

	// Auto-add previous position to work_experience
	// This records the staff's previous role at Ace Mall
	if currentBranchName.Valid {
		startDate := ""
		if dateJoined.Valid {
			startDate = dateJoined.Time.Format("2006-01-02")
		}
		endDate := time.Now().Format("2006-01-02")

		_, err = tx.Exec(`
			INSERT INTO work_experience (id, user_id, company_name, position, start_date, end_date, role_id, branch_id, created_at, updated_at)
			VALUES (gen_random_uuid(), $1, $2, $3, $4, $5, $6, $7, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
		`, req.StaffID, "Ace Mall - "+currentBranchName.String, currentRoleName, startDate, endDate,
			currentRoleID, func() interface{} {
				if currentBranchID.Valid {
					return currentBranchID.String
				}
				return nil
			}())
		if err != nil {
			fmt.Printf("Warning: Failed to add work experience: %v\n", err)
			// Don't fail the whole promotion for this
		}
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
			COALESCE(pr.name, '') as previous_role,
			COALESCE(nr.name, '') as new_role,
			ph.previous_salary,
			ph.new_salary,
			COALESCE(ph.reason, '') as reason,
			COALESCE(u.full_name, '') as promoted_by,
			COALESCE(pb.name, '') as previous_branch,
			COALESCE(nb.name, '') as new_branch
		FROM promotion_history ph
		LEFT JOIN roles pr ON ph.previous_role_id = pr.id
		LEFT JOIN roles nr ON ph.new_role_id = nr.id
		LEFT JOIN users u ON ph.promoted_by = u.id
		LEFT JOIN branches pb ON ph.previous_branch_id = pb.id
		LEFT JOIN branches nb ON ph.new_branch_id = nb.id
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
		var previousRole, newRole, reason, promotedBy, previousBranch, newBranch string

		err := rows.Scan(&id, &promotionDate, &previousRole, &newRole,
			&previousSalary, &newSalary, &reason, &promotedBy, &previousBranch, &newBranch)
		if err != nil {
			fmt.Printf("Error scanning promotion history: %v\n", err)
			continue
		}

		increase := newSalary - previousSalary
		var increasePercent float64
		if previousSalary > 0 {
			increasePercent = float64(increase) / float64(previousSalary) * 100
		}

		// Determine promotion type
		promotionType := "Salary Increase"
		if previousRole != newRole {
			promotionType = "Promotion"
		}
		if previousBranch != newBranch && previousBranch != "" && newBranch != "" {
			if previousRole == newRole {
				promotionType = "Transfer"
			} else {
				promotionType = "Transfer & Promotion"
			}
		}

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
			"previous_branch":  previousBranch,
			"new_branch":       newBranch,
			"type":             promotionType,
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
