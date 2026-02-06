package handlers

import (
	"database/sql"
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// TerminateStaffRequest represents the request body for terminating staff
type TerminateStaffRequest struct {
	TerminationType string  `json:"termination_type" binding:"required"` // 'terminated', 'resigned', 'retired', 'contract_ended'
	Reason          string  `json:"reason" binding:"required"`
	LastWorkingDay  *string `json:"last_working_day"`
	ClearanceNotes  *string `json:"clearance_notes"`
}

// TerminateStaff moves a staff member to the departed_staff table and deactivates their account
func TerminateStaff(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	staffID := c.Param("user_id")

	var req TerminateStaffRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Get current user (HR performing the termination)
	hrUserID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	// Get HR user details
	var hrName, hrRole string
	err := db.QueryRow(`
		SELECT u.full_name, r.name 
		FROM users u 
		LEFT JOIN roles r ON u.role_id = r.id 
		WHERE u.id = $1
	`, hrUserID).Scan(&hrName, &hrRole)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get HR user details"})
		return
	}

	// Get staff details to archive
	var (
		fullName, email                                  string
		employeeID, roleName, departmentName, branchName sql.NullString
		finalSalary                                      sql.NullFloat64
		dateJoined                                       sql.NullTime
		isTerminated                                     bool
	)

	err = db.QueryRow(`
		SELECT 
			u.full_name, u.email, u.employee_id, u.current_salary, u.is_terminated,
			u.date_joined,
			r.name as role_name,
			d.name as department_name,
			b.name as branch_name
		FROM users u
		LEFT JOIN roles r ON u.role_id = r.id
		LEFT JOIN departments d ON u.department_id = d.id
		LEFT JOIN branches b ON u.branch_id = b.id
		WHERE u.id = $1
	`, staffID).Scan(
		&fullName, &email, &employeeID, &finalSalary, &isTerminated,
		&dateJoined,
		&roleName, &departmentName, &branchName,
	)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "Staff member not found"})
		return
	} else if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch staff details"})
		return
	}

	// Check if already terminated
	if isTerminated {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Staff member is already terminated"})
		return
	}

	// Start transaction
	tx, err := db.Begin()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to start transaction"})
		return
	}
	defer tx.Rollback()

	// Parse last working day
	var lastWorkingDay *time.Time
	if req.LastWorkingDay != nil && *req.LastWorkingDay != "" {
		parsed, err := time.Parse("2006-01-02", *req.LastWorkingDay)
		if err == nil {
			lastWorkingDay = &parsed
		}
	}

	// Insert into terminated_staff table
	terminatedID := uuid.New().String()
	_, err = tx.Exec(`
		INSERT INTO terminated_staff (
			id, user_id, full_name, email, employee_id, role_name, 
			department_name, branch_name, termination_type, termination_reason,
			terminated_by, terminated_by_name, terminated_by_role,
			last_working_day, final_salary, clearance_notes, date_joined,
			termination_date, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20)
	`,
		terminatedID, staffID, fullName, email,
		employeeID, roleName, departmentName, branchName,
		req.TerminationType, req.Reason,
		hrUserID, hrName, hrRole,
		lastWorkingDay, finalSalary, req.ClearanceNotes, dateJoined,
		time.Now(), time.Now(), time.Now(),
	)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to archive staff record: " + err.Error()})
		return
	}

	// Update users table - set is_active to false and is_terminated to true
	_, err = tx.Exec(`
		UPDATE users 
		SET is_active = false, is_terminated = true, updated_at = $1 
		WHERE id = $2
	`, time.Now(), staffID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to deactivate staff account"})
		return
	}

	// Commit transaction
	if err := tx.Commit(); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to complete termination"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":          "Staff member terminated successfully",
		"terminated_id":    terminatedID,
		"staff_id":         staffID,
		"terminated_by":    hrName,
		"termination_date": time.Now(),
	})
}

// RestoreStaff reactivates a terminated staff member
func RestoreStaff(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	staffID := c.Param("user_id")

	// Start transaction
	tx, err := db.Begin()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to start transaction"})
		return
	}
	defer tx.Rollback()

	// Update users table
	result, err := tx.Exec(`
		UPDATE users 
		SET is_active = true, is_terminated = false, updated_at = $1 
		WHERE id = $2 AND is_terminated = true
	`, time.Now(), staffID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to restore staff account"})
		return
	}

	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Staff member not found or not terminated"})
		return
	}

	// Delete from terminated_staff table (optional - keep for history)
	// We'll keep the record but could add a 'restored' flag if needed

	// Commit transaction
	if err := tx.Commit(); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to complete restoration"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":     "Staff member restored successfully",
		"staff_id":    staffID,
		"restored_at": time.Now(),
	})
}

// GetDepartedStaff returns all terminated/departed staff
func GetDepartedStaff(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)

	// Get optional filters
	terminationType := c.Query("type")
	branch := c.Query("branch")
	department := c.Query("department")

	query := `
		SELECT 
			id, user_id, full_name, email, employee_id, role_name,
			department_name, branch_name, termination_type, termination_reason,
			terminated_by_name, terminated_by_role, termination_date,
			last_working_day, final_salary, clearance_status, clearance_notes,
			date_joined
		FROM terminated_staff
		WHERE 1=1
	`

	args := []interface{}{}
	argCount := 1

	if terminationType != "" {
		query += fmt.Sprintf(` AND termination_type = $%d`, argCount)
		args = append(args, terminationType)
		argCount++
	}

	if branch != "" {
		query += fmt.Sprintf(` AND branch_name = $%d`, argCount)
		args = append(args, branch)
		argCount++
	}

	if department != "" {
		query += fmt.Sprintf(` AND department_name = $%d`, argCount)
		args = append(args, department)
		argCount++
	}

	query += ` ORDER BY termination_date DESC`

	rows, err := db.Query(query, args...)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch departed staff"})
		return
	}
	defer rows.Close()

	var departedStaff []map[string]interface{}
	for rows.Next() {
		var (
			id, userID, fullName, email                      string
			employeeID, roleName, departmentName, branchName sql.NullString
			terminationType, terminationReason               string
			terminatedByName, terminatedByRole               string
			terminationDate                                  time.Time
			lastWorkingDay                                   sql.NullTime
			finalSalary                                      sql.NullFloat64
			clearanceStatus                                  sql.NullString
			clearanceNotes                                   sql.NullString
			dateJoined                                       sql.NullTime
		)

		err := rows.Scan(
			&id, &userID, &fullName, &email, &employeeID, &roleName,
			&departmentName, &branchName, &terminationType, &terminationReason,
			&terminatedByName, &terminatedByRole, &terminationDate,
			&lastWorkingDay, &finalSalary, &clearanceStatus, &clearanceNotes,
			&dateJoined,
		)

		if err != nil {
			continue
		}

		staff := map[string]interface{}{
			"id":                 id,
			"user_id":            userID,
			"full_name":          fullName,
			"email":              email,
			"termination_type":   terminationType,
			"termination_reason": terminationReason,
			"terminated_by_name": terminatedByName,
			"terminated_by_role": terminatedByRole,
			"termination_date":   terminationDate,
		}

		if dateJoined.Valid {
			staff["date_joined"] = dateJoined.Time
		}

		if employeeID.Valid {
			staff["employee_id"] = employeeID.String
		}
		if roleName.Valid {
			staff["role_name"] = roleName.String
		}
		if departmentName.Valid {
			staff["department_name"] = departmentName.String
		}
		if branchName.Valid {
			staff["branch_name"] = branchName.String
		}
		if lastWorkingDay.Valid {
			staff["last_working_day"] = lastWorkingDay.Time
		}
		if finalSalary.Valid {
			staff["final_salary"] = finalSalary.Float64
		}
		if clearanceStatus.Valid {
			staff["clearance_status"] = clearanceStatus.String
		}
		if clearanceNotes.Valid {
			staff["clearance_notes"] = clearanceNotes.String
		}

		departedStaff = append(departedStaff, staff)
	}

	c.JSON(http.StatusOK, gin.H{
		"departed_staff": departedStaff,
		"count":          len(departedStaff),
	})
}
