package handlers

import (
	"ace-mall-backend/config"
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

	// Prepare values for logging
	newRoleIDForInsert := currentRoleID
	if req.NewRoleID != nil {
		newRoleIDForInsert = *req.NewRoleID
	}

	previousBranchIDForInsert := interface{}(nil)
	if currentBranchID.Valid {
		previousBranchIDForInsert = currentBranchID.String
	}

	previousDeptIDForInsert := interface{}(nil)
	if currentDepartmentID.Valid {
		previousDeptIDForInsert = currentDepartmentID.String
	}

	fmt.Printf("📝 Inserting promotion history: staff=%s, prev_role=%s, new_role=%s, prev_branch=%v, new_branch=%v\n",
		req.StaffID, currentRoleID, newRoleIDForInsert, previousBranchIDForInsert, newBranchID)

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
	`, req.StaffID, currentRoleID, newRoleIDForInsert,
		currentSalary, req.NewSalary,
		previousBranchIDForInsert,
		newBranchID,
		previousDeptIDForInsert,
		newDepartmentID,
		promoterID, req.Reason).Scan(&promotionID)

	if err != nil {
		fmt.Printf("❌ Failed to insert promotion history: %v\n", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to record promotion: " + err.Error()})
		return
	}

	fmt.Printf("✅ Promotion history inserted with ID: %d\n", promotionID)

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
			fmt.Printf("Warning: Failed to add previous work experience: %v\n", err)
			// Don't fail the whole promotion for this
		}
	}

	// Get new role and branch names for current position work experience
	var newRoleName, newBranchName string
	if req.NewRoleID != nil {
		db.QueryRow("SELECT name FROM roles WHERE id = $1", *req.NewRoleID).Scan(&newRoleName)
	} else {
		newRoleName = currentRoleName // Keeping same role
	}

	if req.BranchID != nil {
		db.QueryRow("SELECT name FROM branches WHERE id = $1", *req.BranchID).Scan(&newBranchName)
	} else if currentBranchName.Valid {
		newBranchName = currentBranchName.String
	}

	// Add NEW/CURRENT position to work_experience with NULL end_date (ongoing)
	if newBranchName != "" {
		_, err = tx.Exec(`
			INSERT INTO work_experience (id, user_id, company_name, position, start_date, end_date, role_id, branch_id, created_at, updated_at)
			VALUES (gen_random_uuid(), $1, $2, $3, $4, NULL, $5, $6, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
		`, req.StaffID, "Ace Mall - "+newBranchName, newRoleName, time.Now().Format("2006-01-02"),
			func() interface{} {
				if req.NewRoleID != nil {
					return *req.NewRoleID
				}
				return currentRoleID
			}(),
			func() interface{} {
				if req.BranchID != nil {
					return *req.BranchID
				}
				if currentBranchID.Valid {
					return currentBranchID.String
				}
				return nil
			}())
		if err != nil {
			fmt.Printf("Warning: Failed to add current work experience: %v\n", err)
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

	// Create notification for staff
	var promoterName string
	db.QueryRow("SELECT full_name FROM users WHERE id = $1", promoterID).Scan(&promoterName)

	notificationTitle := "Promotion Notification"
	notificationMessage := promoterName + " has "
	if req.NewRoleID != nil {
		notificationMessage += "promoted you to " + newRoleName
	} else if req.BranchID != nil {
		notificationMessage += "transferred you to " + newBranchName
	} else {
		notificationMessage += "given you a salary increase"
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

	fmt.Printf("📊 GetPromotionHistory called for staff_id: %s\n", staffID)

	// First check how many records exist for this user
	var count int
	db.QueryRow("SELECT COUNT(*) FROM promotion_history WHERE user_id = $1", staffID).Scan(&count)
	fmt.Printf("📊 Found %d promotion records for user_id: %s\n", count, staffID)

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
		ORDER BY ph.promotion_date DESC, ph.id DESC
	`

	rows, err := db.Query(query, staffID)
	if err != nil {
		fmt.Printf("❌ Error querying promotion history: %v\n", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch promotion history"})
		return
	}
	defer rows.Close()

	promotions := []map[string]interface{}{}
	for rows.Next() {
		var id int
		var previousSalary, newSalary float64
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
			increasePercent = (increase / previousSalary) * 100
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

// GetAllPromotions returns all promotion history (for HR/CEO/Chairman)
func GetAllPromotions(c *gin.Context) {
	db := config.DB
	userID := c.GetString("user_id")

	// Verify user has permission (HR, CEO, Chairman)
	var roleName, roleCategory string
	err := db.QueryRow(`
		SELECT r.name, r.category
		FROM users u
		INNER JOIN roles r ON u.role_id = r.id
		WHERE u.id = $1
	`, userID).Scan(&roleName, &roleCategory)

	if err != nil || !isAuthorizedToPromote(roleName, roleCategory) {
		c.JSON(http.StatusForbidden, gin.H{"error": "Insufficient permissions"})
		return
	}

	query := `
		SELECT 
			ph.id,
			ph.user_id,
			COALESCE(u.full_name, '') as staff_name,
			ph.promotion_date,
			COALESCE(pr.name, '') as previous_role,
			COALESCE(nr.name, '') as new_role,
			ph.previous_salary,
			ph.new_salary,
			COALESCE(ph.reason, '') as reason,
			COALESCE(promoter.full_name, '') as promoted_by,
			COALESCE(pb.name, '') as previous_branch,
			COALESCE(nb.name, '') as new_branch
		FROM promotion_history ph
		LEFT JOIN users u ON ph.user_id = u.id
		LEFT JOIN roles pr ON ph.previous_role_id = pr.id
		LEFT JOIN roles nr ON ph.new_role_id = nr.id
		LEFT JOIN users promoter ON ph.promoted_by = promoter.id
		LEFT JOIN branches pb ON ph.previous_branch_id = pb.id
		LEFT JOIN branches nb ON ph.new_branch_id = nb.id
		ORDER BY ph.promotion_date DESC, ph.id DESC
	`

	rows, err := db.Query(query)
	if err != nil {
		fmt.Printf("❌ Error querying all promotions: %v\n", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch promotions"})
		return
	}
	defer rows.Close()

	promotions := []map[string]interface{}{}
	for rows.Next() {
		var id int
		var userID string
		var staffName string
		var previousSalary, newSalary float64
		var promotionDate time.Time
		var previousRole, newRole, reason, promotedBy, previousBranch, newBranch string

		err := rows.Scan(&id, &userID, &staffName, &promotionDate, &previousRole, &newRole,
			&previousSalary, &newSalary, &reason, &promotedBy, &previousBranch, &newBranch)
		if err != nil {
			fmt.Printf("Error scanning promotion: %v\n", err)
			continue
		}

		increase := newSalary - previousSalary
		var increasePercent float64
		if previousSalary > 0 {
			increasePercent = (increase / previousSalary) * 100
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
			"user_id":          userID,
			"staff_name":       staffName,
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

	c.JSON(http.StatusOK, gin.H{"promotions": promotions})
}

// DeletePromotion allows HR/CEO to delete a promotion history record
func DeletePromotion(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	requesterID := c.GetString("user_id")
	promotionID := c.Param("promotion_id")

	// Verify requester has permission (HR, CEO, Chairman)
	var roleName string
	err := db.QueryRow(`
		SELECT r.name
		FROM users u
		INNER JOIN roles r ON u.role_id = r.id
		WHERE u.id = $1
	`, requesterID).Scan(&roleName)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify permissions"})
		return
	}

	// Only HR, CEO, and Chairman can delete promotions
	if roleName != "Human Resource" && roleName != "Chief Executive Officer" && roleName != "Chairman" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only HR, CEO, or Chairman can delete promotion records"})
		return
	}

	// Delete the promotion record
	result, err := db.Exec(`DELETE FROM promotion_history WHERE id = $1`, promotionID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete promotion record"})
		return
	}

	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Promotion record not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Promotion record deleted successfully"})
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
