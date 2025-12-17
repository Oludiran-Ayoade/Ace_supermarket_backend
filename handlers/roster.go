package handlers

import (
	"ace-mall-backend/models"
	"database/sql"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// CreateRoster creates a new weekly roster (Floor Managers only)
func CreateRoster(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	userID := c.GetString("user_id")

	// Verify user is a floor manager
	var roleName string
	var departmentID, branchID sql.NullString
	err := db.QueryRow(`
		SELECT r.name, u.department_id, u.branch_id
		FROM users u
		INNER JOIN roles r ON u.role_id = r.id
		WHERE u.id = $1
	`, userID).Scan(&roleName, &departmentID, &branchID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify user role"})
		return
	}

	// Check if role name contains "Floor Manager" (handles all department-specific floor managers)
	isFloorManager := false
	if roleName == "Floor Manager" {
		isFloorManager = true
	} else {
		// Check for department-specific floor managers like "Floor Manager (Lounge)"
		if len(roleName) >= 13 && roleName[:13] == "Floor Manager" {
			isFloorManager = true
		}
	}

	if !isFloorManager {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only floor managers can create rosters"})
		return
	}

	var req models.CreateRosterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Parse dates
	weekStart, err := time.Parse("2006-01-02", req.WeekStartDate)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid week_start_date format"})
		return
	}

	weekEnd, err := time.Parse("2006-01-02", req.WeekEndDate)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid week_end_date format"})
		return
	}

	// Start transaction
	tx, err := db.Begin()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to start transaction"})
		return
	}
	defer tx.Rollback()

	// Check if roster already exists for this week
	var existingRosterID string
	err = tx.QueryRow(`
		SELECT id FROM rosters 
		WHERE floor_manager_id = $1 
		AND week_start_date = $2 
		AND week_end_date = $3
	`, userID, weekStart, weekEnd).Scan(&existingRosterID)

	var rosterID string
	if err == sql.ErrNoRows {
		// No existing roster - create new one
		rosterID = uuid.New().String()
		_, err = tx.Exec(`
			INSERT INTO rosters (id, floor_manager_id, department_id, branch_id, week_start_date, week_end_date, status)
			VALUES ($1, $2, $3, $4, $5, $6, 'published')
		`, rosterID, userID, departmentID, branchID, weekStart, weekEnd)

		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create roster: " + err.Error()})
			return
		}
	} else if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to check existing roster: " + err.Error()})
		return
	} else {
		// Roster exists - use existing ID and delete old assignments
		rosterID = existingRosterID
		_, err = tx.Exec(`DELETE FROM roster_assignments WHERE roster_id = $1`, rosterID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete old assignments: " + err.Error()})
			return
		}
	}

	// Create/update assignments
	for _, assignment := range req.Assignments {
		assignmentID := uuid.New().String()
		_, err = tx.Exec(`
			INSERT INTO roster_assignments (id, roster_id, staff_id, day_of_week, shift_type, start_time, end_time, notes)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		`, assignmentID, rosterID, assignment.StaffID, assignment.DayOfWeek, assignment.ShiftType,
			assignment.StartTime, assignment.EndTime, assignment.Notes)

		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create assignment: " + err.Error()})
			return
		}

		// TODO: Send notification to staff member
	}

	if err := tx.Commit(); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to commit transaction"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message":   "Roster created successfully",
		"roster_id": rosterID,
	})
}

// GetRostersByBranchDepartment returns rosters for a specific branch and department (HR/CEO/Chairman)
func GetRostersByBranchDepartment(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	branchID := c.Query("branch_id")
	departmentID := c.Query("department_id")
	startDate := c.Query("start_date")
	history := c.Query("history") // "true" to get all historical rosters

	if branchID == "" || departmentID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "branch_id and department_id are required"})
		return
	}

	// If history mode, return all rosters
	if history == "true" {
		rows, err := db.Query(`
			SELECT r.id, r.week_start_date, r.week_end_date, r.floor_manager_id, u.full_name
			FROM rosters r
			LEFT JOIN users u ON r.floor_manager_id = u.id
			WHERE r.department_id = $1
			AND r.branch_id = $2
			ORDER BY r.week_start_date DESC
		`, departmentID, branchID)

		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch rosters"})
			return
		}
		defer rows.Close()

		var rosters []map[string]interface{}
		for rows.Next() {
			var rosterID, floorManagerID string
			var weekStart, weekEnd time.Time
			var managerName sql.NullString

			if err := rows.Scan(&rosterID, &weekStart, &weekEnd, &floorManagerID, &managerName); err != nil {
				continue
			}

			// Get assignment count
			var assignmentCount int
			db.QueryRow(`SELECT COUNT(*) FROM roster_assignments WHERE roster_id = $1`, rosterID).Scan(&assignmentCount)

			rosters = append(rosters, map[string]interface{}{
				"roster_id":        rosterID,
				"week_start":       weekStart.Format("2006-01-02"),
				"week_end":         weekEnd.Format("2006-01-02"),
				"floor_manager":    managerName.String,
				"assignment_count": assignmentCount,
			})
		}

		c.JSON(http.StatusOK, gin.H{
			"success": true,
			"rosters": rosters,
		})
		return
	}

	// Single roster mode (current week or specific date)
	var weekStart time.Time
	var err error
	if startDate != "" {
		weekStart, err = time.Parse("2006-01-02", startDate)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid start_date format. Use YYYY-MM-DD"})
			return
		}
	} else {
		now := time.Now()
		weekStart = now.AddDate(0, 0, -int(now.Weekday()-1))
	}

	// Find roster for the week
	var rosterID string
	var weekEndDate time.Time
	var floorManagerID string
	err = db.QueryRow(`
		SELECT id, week_end_date, floor_manager_id
		FROM rosters
		WHERE week_start_date = $1
		AND department_id = $2
		AND branch_id = $3
	`, weekStart, departmentID, branchID).Scan(&rosterID, &weekEndDate, &floorManagerID)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusOK, gin.H{
			"success": false,
			"message": "No roster found for this week",
			"data":    nil,
		})
		return
	} else if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch roster"})
		return
	}

	// Get floor manager name
	var managerName string
	db.QueryRow(`SELECT full_name FROM users WHERE id = $1`, floorManagerID).Scan(&managerName)

	// Get all assignments for this roster
	rows, err := db.Query(`
		SELECT 
			ra.id, ra.staff_id, ra.day_of_week, ra.shift_type,
			ra.start_time, ra.end_time, ra.notes,
			u.full_name as staff_name
		FROM roster_assignments ra
		INNER JOIN users u ON ra.staff_id = u.id
		WHERE ra.roster_id = $1
		ORDER BY ra.day_of_week, u.full_name
	`, rosterID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch assignments"})
		return
	}
	defer rows.Close()

	var assignments []map[string]interface{}
	for rows.Next() {
		var id, staffID, dayOfWeek, shiftType, startTime, endTime string
		var notes sql.NullString
		var staffName string

		err := rows.Scan(&id, &staffID, &dayOfWeek, &shiftType, &startTime, &endTime, &notes, &staffName)
		if err != nil {
			continue
		}

		assignments = append(assignments, map[string]interface{}{
			"id":          id,
			"staff_id":    staffID,
			"staff_name":  staffName,
			"day_of_week": dayOfWeek,
			"shift_type":  shiftType,
			"start_time":  startTime,
			"end_time":    endTime,
			"notes":       notes.String,
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": map[string]interface{}{
			"roster_id":        rosterID,
			"week_start":       weekStart.Format("2006-01-02"),
			"week_end":         weekEndDate.Format("2006-01-02"),
			"floor_manager":    managerName,
			"assignments":      assignments,
			"assignment_count": len(assignments),
		},
	})
}

// GetRosterForWeek returns roster for a specific week
func GetRosterForWeek(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	userID := c.GetString("user_id")
	startDate := c.Query("start_date")

	if startDate == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "start_date query parameter is required"})
		return
	}

	// Parse the start date
	weekStart, err := time.Parse("2006-01-02", startDate)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid start_date format. Use YYYY-MM-DD"})
		return
	}

	// Get user's department and branch
	var departmentID, branchID sql.NullString
	err = db.QueryRow(`
		SELECT department_id, branch_id FROM users WHERE id = $1
	`, userID).Scan(&departmentID, &branchID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get user info"})
		return
	}

	// Find roster for the week
	var rosterID string
	var weekEndDate time.Time
	err = db.QueryRow(`
		SELECT id, week_end_date
		FROM rosters
		WHERE floor_manager_id = $1
		AND week_start_date = $2
		AND department_id = $3
		AND branch_id = $4
	`, userID, weekStart, departmentID, branchID).Scan(&rosterID, &weekEndDate)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "No roster found for this week"})
		return
	} else if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch roster"})
		return
	}

	// Get all assignments for this roster
	rows, err := db.Query(`
		SELECT 
			ra.id, ra.staff_id, ra.day_of_week, ra.shift_type,
			ra.start_time, ra.end_time, ra.notes,
			u.full_name as staff_name
		FROM roster_assignments ra
		INNER JOIN users u ON ra.staff_id = u.id
		WHERE ra.roster_id = $1
		ORDER BY ra.day_of_week, u.full_name
	`, rosterID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch assignments"})
		return
	}
	defer rows.Close()

	var assignments []map[string]interface{}
	for rows.Next() {
		var id, staffID, dayOfWeek, shiftType, startTime, endTime string
		var notes sql.NullString
		var staffName string

		err := rows.Scan(&id, &staffID, &dayOfWeek, &shiftType, &startTime, &endTime, &notes, &staffName)
		if err != nil {
			continue
		}

		assignments = append(assignments, map[string]interface{}{
			"id":          id,
			"staff_id":    staffID,
			"staff_name":  staffName,
			"day_of_week": dayOfWeek,
			"shift_type":  shiftType,
			"start_time":  startTime,
			"end_time":    endTime,
			"notes":       notes.String,
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"roster_id":       rosterID,
		"week_start_date": weekStart,
		"week_end_date":   weekEndDate,
		"assignments":     assignments,
		"count":           len(assignments),
	})
}

// GetMyTeam returns all staff under a floor manager
func GetMyTeam(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	userID := c.GetString("user_id")

	// Verify user is a floor manager
	var roleName string
	var departmentID, branchID sql.NullString
	err := db.QueryRow(`
		SELECT r.name, u.department_id, u.branch_id
		FROM users u
		INNER JOIN roles r ON u.role_id = r.id
		WHERE u.id = $1
	`, userID).Scan(&roleName, &departmentID, &branchID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify user role"})
		return
	}

	// Check if role name contains "Floor Manager"
	isFloorManager := false
	if roleName == "Floor Manager" || (len(roleName) >= 13 && roleName[:13] == "Floor Manager") {
		isFloorManager = true
	}

	if !isFloorManager {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only floor managers can view their team"})
		return
	}

	// Get all staff in same department and branch (general staff only)
	rows, err := db.Query(`
		SELECT 
			u.id, u.full_name, u.email, u.phone_number, u.profile_image_url,
			r.name as role_name, u.date_joined, u.is_active
		FROM users u
		INNER JOIN roles r ON u.role_id = r.id
		WHERE u.department_id = $1 
		AND u.branch_id = $2
		AND r.category = 'general'
		AND u.is_active = true
		ORDER BY u.full_name
	`, departmentID, branchID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch team"})
		return
	}
	defer rows.Close()

	var team []map[string]interface{}
	for rows.Next() {
		var id, fullName, email string
		var phoneNumber, profileImageURL, roleName sql.NullString
		var dateJoined time.Time
		var isActive bool

		err := rows.Scan(&id, &fullName, &email, &phoneNumber, &profileImageURL, &roleName, &dateJoined, &isActive)
		if err != nil {
			continue
		}

		team = append(team, map[string]interface{}{
			"id":                id,
			"full_name":         fullName,
			"email":             email,
			"phone_number":      phoneNumber.String,
			"profile_image_url": profileImageURL.String,
			"role_name":         roleName.String,
			"date_joined":       dateJoined,
			"is_active":         isActive,
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"team":  team,
		"count": len(team),
	})
}

// CreateWeeklyReview creates a weekly review for a staff member
func CreateWeeklyReview(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	reviewerID := c.GetString("user_id")

	// Verify user is a floor manager
	var roleName string
	err := db.QueryRow(`
		SELECT r.name FROM users u
		INNER JOIN roles r ON u.role_id = r.id
		WHERE u.id = $1
	`, reviewerID).Scan(&roleName)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify user role"})
		return
	}

	// Check if role name contains "Floor Manager"
	isFloorManager := false
	if roleName == "Floor Manager" || (len(roleName) >= 13 && roleName[:13] == "Floor Manager") {
		isFloorManager = true
	}

	if !isFloorManager {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only floor managers can create reviews"})
		return
	}

	var req models.CreateWeeklyReviewRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Parse dates
	weekStart, err := time.Parse("2006-01-02", req.WeekStartDate)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid week_start_date format"})
		return
	}

	weekEnd, err := time.Parse("2006-01-02", req.WeekEndDate)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid week_end_date format"})
		return
	}

	// Create review
	reviewID := uuid.New().String()
	_, err = db.Exec(`
		INSERT INTO weekly_reviews (
			id, staff_id, reviewer_id, week_start_date, week_end_date,
			rating, punctuality_rating, performance_rating, attitude_rating,
			comments, strengths, areas_for_improvement
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
	`, reviewID, req.StaffID, reviewerID, weekStart, weekEnd,
		req.Rating, req.PunctualityRating, req.PerformanceRating, req.AttitudeRating,
		req.Comments, req.Strengths, req.AreasForImprovement)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create review: " + err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message":   "Review created successfully",
		"review_id": reviewID,
	})
}

// GetStaffReviews returns all reviews for a staff member
func GetStaffReviews(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	staffID := c.Param("staff_id")

	rows, err := db.Query(`
		SELECT 
			CAST(wr.id AS TEXT), wr.week_start_date, wr.week_end_date,
			COALESCE(wr.rating, 0), COALESCE(wr.punctuality_rating, 0), 
			COALESCE(wr.performance_rating, 0), COALESCE(wr.attitude_rating, 0),
			COALESCE(wr.comments, ''), COALESCE(wr.strengths, ''), COALESCE(wr.areas_for_improvement, ''),
			wr.created_at, u.full_name as reviewer_name
		FROM weekly_reviews wr
		INNER JOIN users u ON CAST(wr.reviewer_id AS TEXT) = CAST(u.id AS TEXT)
		WHERE CAST(wr.staff_id AS TEXT) = $1
		ORDER BY wr.week_start_date DESC
	`, staffID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch reviews"})
		return
	}
	defer rows.Close()

	var reviews []models.WeeklyReview
	for rows.Next() {
		var review models.WeeklyReview
		err := rows.Scan(
			&review.ID, &review.WeekStartDate, &review.WeekEndDate,
			&review.Rating, &review.PunctualityRating, &review.PerformanceRating, &review.AttitudeRating,
			&review.Comments, &review.Strengths, &review.AreasForImprovement,
			&review.CreatedAt, &review.ReviewerName,
		)
		if err != nil {
			continue
		}
		reviews = append(reviews, review)
	}

	c.JSON(http.StatusOK, gin.H{
		"reviews": reviews,
		"count":   len(reviews),
	})
}
