package handlers

import (
	"database/sql"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// TerminateStaffRequest represents the request body for terminating staff
type TerminateStaffRequest struct {
	UserID            string  `json:"user_id" binding:"required"`
	TerminationType   string  `json:"termination_type" binding:"required"` // terminated, resigned, retired, contract_ended
	TerminationReason string  `json:"termination_reason" binding:"required"`
	LastWorkingDay    string  `json:"last_working_day"`
	FinalSalary       float64 `json:"final_salary"`
	ClearanceNotes    string  `json:"clearance_notes"`
}

// TerminateStaff handles staff termination (HR/COO only)
func TerminateStaff(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	currentUserID := c.GetString("user_id")

	// Verify user is HR, COO, CEO, or Chairman
	var roleName string
	err := db.QueryRow(`
		SELECT r.name FROM users u
		INNER JOIN roles r ON u.role_id = r.id
		WHERE u.id = $1
	`, currentUserID).Scan(&roleName)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify user role: " + err.Error()})
		return
	}

	// Only HR, COO, CEO, and Chairman can terminate staff
	roleNameLower := strings.ToLower(roleName)
	hasPermission := strings.Contains(roleNameLower, "hr") ||
		strings.Contains(roleNameLower, "human resource") ||
		strings.Contains(roleNameLower, "coo") ||
		strings.Contains(roleNameLower, "chief operating") ||
		strings.Contains(roleNameLower, "ceo") ||
		strings.Contains(roleNameLower, "chief executive") ||
		strings.Contains(roleNameLower, "chairman")

	if !hasPermission {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only HR, COO, CEO, or Chairman can terminate staff. Your role: " + roleName})
		return
	}

	var req TerminateStaffRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request: " + err.Error()})
		return
	}

	// Validate termination type
	validTypes := map[string]bool{
		"terminated":     true,
		"resigned":       true,
		"retired":        true,
		"contract_ended": true,
	}
	if !validTypes[req.TerminationType] {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid termination type"})
		return
	}

	// Get staff details before termination
	var staffDetails struct {
		FullName       string
		Email          string
		EmployeeID     sql.NullString
		RoleName       string
		DepartmentName sql.NullString
		BranchName     sql.NullString
	}

	err = db.QueryRow(`
		SELECT 
			u.full_name,
			u.email,
			u.employee_id,
			r.name as role_name,
			d.name as department_name,
			b.name as branch_name
		FROM users u
		INNER JOIN roles r ON u.role_id = r.id
		LEFT JOIN departments d ON u.department_id = d.id
		LEFT JOIN branches b ON u.branch_id = b.id
		WHERE u.id = $1 AND u.is_active = true
	`, req.UserID).Scan(
		&staffDetails.FullName,
		&staffDetails.Email,
		&staffDetails.EmployeeID,
		&staffDetails.RoleName,
		&staffDetails.DepartmentName,
		&staffDetails.BranchName,
	)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "Staff member not found or already terminated"})
		return
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch staff details: " + err.Error()})
		return
	}

	// Get current user details
	var currentUserDetails struct {
		FullName string
		RoleName string
	}
	err = db.QueryRow(`
		SELECT u.full_name, r.name
		FROM users u
		INNER JOIN roles r ON u.role_id = r.id
		WHERE u.id = $1
	`, currentUserID).Scan(&currentUserDetails.FullName, &currentUserDetails.RoleName)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch current user details"})
		return
	}

	// Begin transaction
	tx, err := db.Begin()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to start transaction"})
		return
	}
	defer tx.Rollback()

	// Parse last working day
	var lastWorkingDay sql.NullTime
	if req.LastWorkingDay != "" {
		parsedDate, err := time.Parse("2006-01-02", req.LastWorkingDay)
		if err == nil {
			lastWorkingDay = sql.NullTime{Time: parsedDate, Valid: true}
		}
	}

	// Insert into terminated_staff table
	terminationID := uuid.New().String()
	_, err = tx.Exec(`
		INSERT INTO terminated_staff (
			id, user_id, full_name, email, employee_id, role_name, 
			department_name, branch_name, termination_type, termination_reason,
			terminated_by, terminated_by_name, terminated_by_role,
			last_working_day, final_salary, clearance_notes
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16)
	`,
		terminationID,
		req.UserID,
		staffDetails.FullName,
		staffDetails.Email,
		staffDetails.EmployeeID,
		staffDetails.RoleName,
		staffDetails.DepartmentName,
		staffDetails.BranchName,
		req.TerminationType,
		req.TerminationReason,
		currentUserID,
		currentUserDetails.FullName,
		currentUserDetails.RoleName,
		lastWorkingDay,
		req.FinalSalary,
		req.ClearanceNotes,
	)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to record termination: " + err.Error()})
		return
	}

	// Mark user as inactive
	_, err = tx.Exec(`UPDATE users SET is_active = false WHERE id = $1`, req.UserID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to deactivate user"})
		return
	}

	// Remove from active rosters (future rosters only)
	// Use a simpler approach with explicit UUID casting
	_, err = tx.Exec(`
		DELETE FROM roster_assignments 
		WHERE staff_id = $1::uuid 
		AND roster_id IN (
			SELECT id FROM rosters WHERE week_start_date > CURRENT_DATE
		)
	`, req.UserID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to remove from rosters: " + err.Error()})
		return
	}

	// Commit transaction
	if err := tx.Commit(); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to commit termination"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":        "Staff member terminated successfully",
		"termination_id": terminationID,
		"staff_name":     staffDetails.FullName,
	})
}

// GetTerminatedStaff returns list of terminated staff (Admin only)
func GetTerminatedStaff(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	currentUserID := c.GetString("user_id")

	// Verify user is admin (CEO, COO, HR, Chairman, Auditor)
	var roleName string
	err := db.QueryRow(`
		SELECT r.name FROM users u
		INNER JOIN roles r ON u.role_id = r.id
		WHERE u.id = $1
	`, currentUserID).Scan(&roleName)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify user role"})
		return
	}

	// Only top admin officers can view terminated staff
	roleNameLower := strings.ToLower(roleName)
	isAdmin := strings.Contains(roleNameLower, "ceo") ||
		strings.Contains(roleNameLower, "chief executive") ||
		strings.Contains(roleNameLower, "coo") ||
		strings.Contains(roleNameLower, "chief operating") ||
		strings.Contains(roleNameLower, "hr") ||
		strings.Contains(roleNameLower, "human resource") ||
		strings.Contains(roleNameLower, "chairman") ||
		strings.Contains(roleNameLower, "auditor")

	if !isAdmin {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only top admin officers can view terminated staff"})
		return
	}

	// Get query parameters for filtering
	terminationType := c.Query("type")
	department := c.Query("department")
	branch := c.Query("branch")
	searchQuery := c.Query("search")

	// Build query
	query := `
		SELECT 
			id, user_id, full_name, email, employee_id, role_name,
			department_name, branch_name, termination_type, termination_reason,
			termination_date, terminated_by_name, terminated_by_role,
			last_working_day, final_salary, clearance_status, clearance_notes
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

	if department != "" {
		query += fmt.Sprintf(` AND department_name = $%d`, argCount)
		args = append(args, department)
		argCount++
	}

	if branch != "" {
		query += fmt.Sprintf(` AND branch_name = $%d`, argCount)
		args = append(args, branch)
		argCount++
	}

	if searchQuery != "" {
		query += fmt.Sprintf(` AND (full_name ILIKE $%d OR email ILIKE $%d)`, argCount, argCount)
		args = append(args, "%"+searchQuery+"%")
		argCount++
	}

	query += ` ORDER BY termination_date DESC`

	rows, err := db.Query(query, args...)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch terminated staff"})
		return
	}
	defer rows.Close()

	terminatedStaff := []map[string]interface{}{}
	for rows.Next() {
		var staff struct {
			ID                string
			UserID            string
			FullName          string
			Email             string
			EmployeeID        sql.NullString
			RoleName          string
			DepartmentName    sql.NullString
			BranchName        sql.NullString
			TerminationType   string
			TerminationReason string
			TerminationDate   time.Time
			TerminatedByName  string
			TerminatedByRole  string
			LastWorkingDay    sql.NullTime
			FinalSalary       sql.NullFloat64
			ClearanceStatus   string
			ClearanceNotes    sql.NullString
		}

		err := rows.Scan(
			&staff.ID, &staff.UserID, &staff.FullName, &staff.Email,
			&staff.EmployeeID, &staff.RoleName, &staff.DepartmentName,
			&staff.BranchName, &staff.TerminationType, &staff.TerminationReason,
			&staff.TerminationDate, &staff.TerminatedByName, &staff.TerminatedByRole,
			&staff.LastWorkingDay, &staff.FinalSalary, &staff.ClearanceStatus,
			&staff.ClearanceNotes,
		)

		if err != nil {
			continue
		}

		staffMap := map[string]interface{}{
			"id":                 staff.ID,
			"user_id":            staff.UserID,
			"full_name":          staff.FullName,
			"email":              staff.Email,
			"employee_id":        staff.EmployeeID.String,
			"role_name":          staff.RoleName,
			"department_name":    staff.DepartmentName.String,
			"branch_name":        staff.BranchName.String,
			"termination_type":   staff.TerminationType,
			"termination_reason": staff.TerminationReason,
			"termination_date":   staff.TerminationDate.Format("2006-01-02"),
			"terminated_by_name": staff.TerminatedByName,
			"terminated_by_role": staff.TerminatedByRole,
			"clearance_status":   staff.ClearanceStatus,
		}

		if staff.LastWorkingDay.Valid {
			staffMap["last_working_day"] = staff.LastWorkingDay.Time.Format("2006-01-02")
		}
		if staff.FinalSalary.Valid {
			staffMap["final_salary"] = staff.FinalSalary.Float64
		}
		if staff.ClearanceNotes.Valid {
			staffMap["clearance_notes"] = staff.ClearanceNotes.String
		}

		terminatedStaff = append(terminatedStaff, staffMap)
	}

	c.JSON(http.StatusOK, gin.H{
		"terminated_staff": terminatedStaff,
		"total":            len(terminatedStaff),
	})
}

// UpdateClearanceStatus updates the clearance status of terminated staff
func UpdateClearanceStatus(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	currentUserID := c.GetString("user_id")
	terminationID := c.Param("id")

	// Verify user is admin
	var roleName string
	err := db.QueryRow(`
		SELECT r.name FROM users u
		INNER JOIN roles r ON u.role_id = r.id
		WHERE u.id = $1
	`, currentUserID).Scan(&roleName)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify user role"})
		return
	}

	isAdmin := strings.Contains(roleName, "CEO") ||
		strings.Contains(roleName, "COO") ||
		strings.Contains(roleName, "HR") ||
		strings.Contains(roleName, "Human Resource")

	if !isAdmin {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only HR, COO, or CEO can update clearance status"})
		return
	}

	var req struct {
		ClearanceStatus string `json:"clearance_status" binding:"required"`
		ClearanceNotes  string `json:"clearance_notes"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Validate clearance status
	validStatuses := map[string]bool{
		"pending": true,
		"cleared": true,
		"issues":  true,
	}
	if !validStatuses[req.ClearanceStatus] {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid clearance status"})
		return
	}

	_, err = db.Exec(`
		UPDATE terminated_staff 
		SET clearance_status = $1, clearance_notes = $2, updated_at = CURRENT_TIMESTAMP
		WHERE id = $3
	`, req.ClearanceStatus, req.ClearanceNotes, terminationID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update clearance status"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Clearance status updated successfully"})
}
