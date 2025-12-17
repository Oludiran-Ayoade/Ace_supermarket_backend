package handlers

import (
	"database/sql"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

// GetAllStaffReviews returns all reviews for HR/CEO to view staff performance
func GetAllStaffReviews(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)

	query := `
		SELECT 
			CAST(r.id AS TEXT) as id,
			CAST(r.staff_id AS TEXT) as staff_id,
			s.full_name as staff_name,
			sr.name as role_name,
			d.name as department_name,
			CAST(s.branch_id AS TEXT) as branch_id,
			b.name as branch_name,
			r.week_start_date,
			r.week_end_date,
			COALESCE(r.rating, 0) as overall_rating,
			COALESCE(r.attitude_rating, 0) as attitude_rating,
			COALESCE(r.punctuality_rating, 0) as punctuality_rating,
			COALESCE(r.performance_rating, 0) as performance_rating,
			COALESCE(r.comments, '') as comments,
			rev.full_name as reviewer_name
		FROM weekly_reviews r
		INNER JOIN users s ON CAST(r.staff_id AS TEXT) = CAST(s.id AS TEXT)
		INNER JOIN users rev ON CAST(r.reviewer_id AS TEXT) = CAST(rev.id AS TEXT)
		INNER JOIN roles sr ON CAST(s.role_id AS TEXT) = CAST(sr.id AS TEXT)
		LEFT JOIN departments d ON CAST(s.department_id AS TEXT) = CAST(d.id AS TEXT)
		LEFT JOIN branches b ON CAST(s.branch_id AS TEXT) = CAST(b.id AS TEXT)
		ORDER BY r.week_start_date DESC
	`

	rows, err := db.Query(query)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch reviews"})
		return
	}
	defer rows.Close()

	reviews := []map[string]interface{}{}
	for rows.Next() {
		var id, staffID, staffName, roleName, departmentName, branchID, branchName, comments, reviewerName string
		var weekStart, weekEnd time.Time
		var overallRating, attitudeRating, punctualityRating, performanceRating int

		err := rows.Scan(
			&id,
			&staffID,
			&staffName,
			&roleName,
			&departmentName,
			&branchID,
			&branchName,
			&weekStart,
			&weekEnd,
			&overallRating,
			&attitudeRating,
			&punctualityRating,
			&performanceRating,
			&comments,
			&reviewerName,
		)
		if err != nil {
			continue
		}

		reviews = append(reviews, map[string]interface{}{
			"id":                 id,
			"staff_id":           staffID,
			"staff_name":         staffName,
			"role_name":          roleName,
			"department_name":    departmentName,
			"branch_id":          branchID,
			"branch_name":        branchName,
			"week_start_date":    weekStart.Format("2006-01-02"),
			"week_end_date":      weekEnd.Format("2006-01-02"),
			"overall_rating":     overallRating,
			"rating":             overallRating,
			"attitude_rating":    attitudeRating,
			"punctuality_rating": punctualityRating,
			"performance_rating": performanceRating,
			"comments":           comments,
			"reviewer_name":      reviewerName,
		})
	}

	c.JSON(http.StatusOK, reviews)
}

// GetMyReviews returns all reviews for the authenticated staff member
func GetMyReviews(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	userID := c.GetString("user_id")

	query := `
		SELECT 
			CAST(r.id AS TEXT),
			r.week_start_date,
			r.week_end_date,
			COALESCE(r.rating, 0),
			COALESCE(r.attitude_rating, 0),
			COALESCE(r.punctuality_rating, 0),
			COALESCE(r.performance_rating, 0),
			COALESCE(r.comments, ''),
			u.full_name as reviewer_name,
			ro.name as reviewer_role
		FROM weekly_reviews r
		INNER JOIN users u ON CAST(r.reviewer_id AS TEXT) = CAST(u.id AS TEXT)
		INNER JOIN roles ro ON CAST(u.role_id AS TEXT) = CAST(ro.id AS TEXT)
		WHERE CAST(r.staff_id AS TEXT) = $1
		ORDER BY r.week_start_date DESC
	`

	rows, err := db.Query(query, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch reviews"})
		return
	}
	defer rows.Close()

	reviews := []map[string]interface{}{}
	for rows.Next() {
		var id string
		var weekStart, weekEnd time.Time
		var rating, attitudeScore, punctualityScore, performanceScore int
		var comments, reviewerName, reviewerRole string

		err := rows.Scan(
			&id,
			&weekStart,
			&weekEnd,
			&rating,
			&attitudeScore,
			&punctualityScore,
			&performanceScore,
			&comments,
			&reviewerName,
			&reviewerRole,
		)
		if err != nil {
			continue
		}

		reviews = append(reviews, map[string]interface{}{
			"id":                id,
			"date":              weekStart.Format("2006-01-02"),
			"week_start":        weekStart.Format("2006-01-02"),
			"week_end":          weekEnd.Format("2006-01-02"),
			"rating":            rating,
			"attendance_score":  attitudeScore,
			"punctuality_score": punctualityScore,
			"performance_score": performanceScore,
			"remarks":           comments,
			"reviewer_name":     reviewerName,
			"reviewer_role":     reviewerRole,
		})
	}

	c.JSON(http.StatusOK, reviews)
}

// CreateReview creates a new review for a staff member (floor manager only)
func CreateReview(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	reviewerID := c.GetString("user_id")

	var req struct {
		StaffID          string  `json:"staff_id" binding:"required"`
		RosterID         int     `json:"roster_id"`
		AttendanceScore  float64 `json:"attendance_score" binding:"required,min=1,max=5"`
		PunctualityScore float64 `json:"punctuality_score" binding:"required,min=1,max=5"`
		PerformanceScore float64 `json:"performance_score" binding:"required,min=1,max=5"`
		Remarks          string  `json:"remarks" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Verify reviewer is a floor manager
	var roleName string
	err := db.QueryRow(`
		SELECT r.name
		FROM users u
		INNER JOIN roles r ON u.role_id = r.id
		WHERE u.id = $1
	`, reviewerID).Scan(&roleName)

	if err != nil || !contains(roleName, "Floor Manager") {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only floor managers can create reviews"})
		return
	}

	// If no roster_id provided, try to get the most recent roster for this floor manager
	// But don't fail if there's no roster - reviews can be independent
	rosterID := req.RosterID
	if rosterID == 0 {
		db.QueryRow(`
			SELECT id FROM rosters
			WHERE floor_manager_id = $1
			ORDER BY week_start DESC
			LIMIT 1
		`, reviewerID).Scan(&rosterID)
		// Ignore error - roster_id can be NULL
	}

	// Calculate overall rating as average
	overallRating := int((req.AttendanceScore + req.PunctualityScore + req.PerformanceScore) / 3.0)

	// Get current week dates
	now := time.Now()
	weekStart := now.AddDate(0, 0, -int(now.Weekday()))
	weekEnd := weekStart.AddDate(0, 0, 6)

	// Insert review with optional roster_id into weekly_reviews table
	var reviewID string
	var query string

	if rosterID != 0 {
		query = `
			INSERT INTO weekly_reviews (
				staff_id,
				roster_id,
				reviewer_id,
				week_start_date,
				week_end_date,
				rating,
				punctuality_rating,
				performance_rating,
				attitude_rating,
				comments
			) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
			RETURNING id
		`
		err = db.QueryRow(
			query,
			req.StaffID,
			rosterID,
			reviewerID,
			weekStart.Format("2006-01-02"),
			weekEnd.Format("2006-01-02"),
			overallRating,
			int(req.PunctualityScore),
			int(req.PerformanceScore),
			int(req.AttendanceScore),
			req.Remarks,
		).Scan(&reviewID)
	} else {
		// Insert without roster_id
		query = `
			INSERT INTO weekly_reviews (
				staff_id,
				reviewer_id,
				week_start_date,
				week_end_date,
				rating,
				punctuality_rating,
				performance_rating,
				attitude_rating,
				comments
			) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
			RETURNING id
		`
		err = db.QueryRow(
			query,
			req.StaffID,
			reviewerID,
			weekStart.Format("2006-01-02"),
			weekEnd.Format("2006-01-02"),
			overallRating,
			int(req.PunctualityScore),
			int(req.PerformanceScore),
			int(req.AttendanceScore),
			req.Remarks,
		).Scan(&reviewID)
	}

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create review"})
		return
	}

	// Create notification for staff member
	var reviewerName string
	db.QueryRow("SELECT full_name FROM users WHERE id = $1", reviewerID).Scan(&reviewerName)

	avgRating := (req.AttendanceScore + req.PunctualityScore + req.PerformanceScore) / 3.0
	notificationTitle := "New Performance Review"
	notificationMessage := reviewerName + " has left a review for your performance (Rating: " + formatRating(avgRating) + ")"

	db.Exec(`
		INSERT INTO notifications (user_id, type, title, message)
		VALUES ($1, 'review', $2, $3)
	`, req.StaffID, notificationTitle, notificationMessage)

	c.JSON(http.StatusCreated, gin.H{
		"id":      reviewID,
		"message": "Review created successfully",
	})
}

// GetStaffReviewsForManager returns reviews created by the authenticated floor manager
func GetStaffReviewsForManager(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	managerID := c.GetString("user_id")

	query := `
		SELECT 
			r.id,
			r.review_date,
			r.attendance_score,
			r.punctuality_score,
			r.performance_score,
			r.remarks,
			u.full_name as staff_name,
			ros.week_start,
			ros.week_end
		FROM reviews r
		INNER JOIN users u ON r.staff_id = u.id
		INNER JOIN rosters ros ON r.roster_id = ros.id
		WHERE r.reviewer_id = $1
		ORDER BY r.review_date DESC
	`

	rows, err := db.Query(query, managerID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch reviews"})
		return
	}
	defer rows.Close()

	reviews := []map[string]interface{}{}
	for rows.Next() {
		var id int
		var reviewDate, weekStart, weekEnd time.Time
		var attendanceScore, punctualityScore, performanceScore float64
		var remarks, staffName string

		err := rows.Scan(
			&id,
			&reviewDate,
			&attendanceScore,
			&punctualityScore,
			&performanceScore,
			&remarks,
			&staffName,
			&weekStart,
			&weekEnd,
		)
		if err != nil {
			continue
		}

		rating := (attendanceScore + punctualityScore + performanceScore) / 3.0

		reviews = append(reviews, map[string]interface{}{
			"id":                id,
			"review_date":       reviewDate.Format("2006-01-02"),
			"rating":            rating,
			"attendance_score":  attendanceScore,
			"punctuality_score": punctualityScore,
			"performance_score": performanceScore,
			"remarks":           remarks,
			"staff_name":        staffName,
			"week_start":        weekStart.Format("2006-01-02"),
			"week_end":          weekEnd.Format("2006-01-02"),
		})
	}

	c.JSON(http.StatusOK, reviews)
}

// GetAllReviews returns all reviews for HR/Group Heads (with optional department filter)
func GetAllReviews(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	userID := c.GetString("user_id")

	// Get user's role and department
	var roleName string
	var departmentID sql.NullString
	err := db.QueryRow(`
		SELECT r.name, u.department_id
		FROM users u
		INNER JOIN roles r ON u.role_id = r.id
		WHERE u.id = $1
	`, userID).Scan(&roleName, &departmentID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify user"})
		return
	}

	// Check if user is authorized (HR, Group Head, CEO, Chairman, Auditor)
	isAuthorized := contains(roleName, "HR") || contains(roleName, "Group Head") ||
		contains(roleName, "CEO") || contains(roleName, "Chairman") || contains(roleName, "Auditor")

	if !isAuthorized {
		c.JSON(http.StatusForbidden, gin.H{"error": "Unauthorized"})
		return
	}

	// Build query based on role
	query := `
		SELECT 
			r.id,
			CAST(r.staff_id AS TEXT),
			r.review_date,
			r.attendance_score,
			r.punctuality_score,
			r.performance_score,
			COALESCE(r.remarks, ''),
			u.full_name as staff_name,
			CAST(u.department_id AS TEXT),
			COALESCE(d.name, ''),
			CAST(u.branch_id AS TEXT),
			COALESCE(b.name, ''),
			reviewer.full_name as reviewer_name,
			COALESCE(ros.week_start, CURRENT_DATE),
			COALESCE(ros.week_end, CURRENT_DATE)
		FROM reviews r
		INNER JOIN users u ON CAST(r.staff_id AS TEXT) = CAST(u.id AS TEXT)
		INNER JOIN users reviewer ON CAST(r.reviewer_id AS TEXT) = CAST(reviewer.id AS TEXT)
		LEFT JOIN rosters ros ON r.roster_id = ros.id
		LEFT JOIN departments d ON CAST(u.department_id AS TEXT) = CAST(d.id AS TEXT)
		LEFT JOIN branches b ON CAST(u.branch_id AS TEXT) = CAST(b.id AS TEXT)
	`

	// If Group Head, filter by department
	if contains(roleName, "Group Head") && departmentID.Valid {
		query += " WHERE u.department_id = $1"
		query += " ORDER BY r.review_date DESC"

		rows, err := db.Query(query, departmentID.String)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch reviews"})
			return
		}
		defer rows.Close()

		reviews := scanReviews(rows)
		c.JSON(http.StatusOK, reviews)
		return
	}

	// For HR/CEO/Chairman/Auditor, return all reviews
	query += " ORDER BY r.review_date DESC"
	rows, err := db.Query(query)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch reviews"})
		return
	}
	defer rows.Close()

	reviews := scanReviews(rows)
	c.JSON(http.StatusOK, reviews)
}

func scanReviews(rows *sql.Rows) []map[string]interface{} {
	reviews := []map[string]interface{}{}
	for rows.Next() {
		var id int
		var staffID, departmentID, branchID string
		var reviewDate, weekStart, weekEnd time.Time
		var attendanceScore, punctualityScore, performanceScore float64
		var remarks, staffName, departmentName, branchName, reviewerName string

		err := rows.Scan(
			&id,
			&staffID,
			&reviewDate,
			&attendanceScore,
			&punctualityScore,
			&performanceScore,
			&remarks,
			&staffName,
			&departmentID,
			&departmentName,
			&branchID,
			&branchName,
			&reviewerName,
			&weekStart,
			&weekEnd,
		)
		if err != nil {
			continue
		}

		rating := (attendanceScore + punctualityScore + performanceScore) / 3.0

		review := map[string]interface{}{
			"id":                id,
			"staff_id":          staffID,
			"review_date":       reviewDate.Format("2006-01-02"),
			"rating":            rating,
			"attendance_score":  attendanceScore,
			"punctuality_score": punctualityScore,
			"performance_score": performanceScore,
			"remarks":           remarks,
			"staff_name":        staffName,
			"reviewer_name":     reviewerName,
			"week_start":        weekStart.Format("2006-01-02"),
			"week_end":          weekEnd.Format("2006-01-02"),
			"department_id":     departmentID,
			"department_name":   departmentName,
			"branch_id":         branchID,
			"branch_name":       branchName,
		}

		reviews = append(reviews, review)
	}
	return reviews
}

// Helper functions
func contains(s, substr string) bool {
	return len(s) >= len(substr) && (s == substr || len(s) > len(substr) && (s[:len(substr)] == substr || s[len(s)-len(substr):] == substr || containsMiddle(s, substr)))
}

func containsMiddle(s, substr string) bool {
	for i := 0; i <= len(s)-len(substr); i++ {
		if s[i:i+len(substr)] == substr {
			return true
		}
	}
	return false
}

func formatRating(rating float64) string {
	if rating >= 4.5 {
		return "⭐⭐⭐⭐⭐"
	} else if rating >= 3.5 {
		return "⭐⭐⭐⭐"
	} else if rating >= 2.5 {
		return "⭐⭐⭐"
	} else if rating >= 1.5 {
		return "⭐⭐"
	}
	return "⭐"
}

// GetRatingsByDepartment returns ratings/reviews for staff in a specific branch and department
// Used by CEO/HR/Branch Managers to view team performance
func GetRatingsByDepartment(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	branchID := c.Query("branch_id")
	departmentID := c.Query("department_id")
	period := c.DefaultQuery("period", "month") // week, month, year

	if branchID == "" || departmentID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "branch_id and department_id are required"})
		return
	}

	// Calculate date range based on period
	var startDate time.Time
	now := time.Now()

	switch period {
	case "week":
		startDate = now.AddDate(0, 0, -7)
	case "month":
		startDate = now.AddDate(0, -1, 0)
	case "year":
		startDate = now.AddDate(-1, 0, 0)
	default:
		startDate = now.AddDate(0, -1, 0) // Default to month
	}

	// Query to get staff ratings grouped by staff member with latest comment
	query := `
		SELECT 
			u.id,
			u.full_name,
			u.employee_id,
			r.name as role_name,
			COUNT(rev.id) as review_count,
			COALESCE(AVG((rev.punctuality_rating + rev.performance_rating + rev.attitude_rating) / 3.0), 0) as avg_rating,
			COALESCE(AVG(rev.punctuality_rating), 0) as avg_attendance,
			COALESCE(AVG(rev.punctuality_rating), 0) as avg_punctuality,
			COALESCE(AVG(rev.performance_rating), 0) as avg_performance,
			MAX(rev.week_start_date) as last_review_date,
			(
				SELECT COALESCE(comments, '')
				FROM weekly_reviews
				WHERE staff_id = u.id AND week_start_date >= $1
				ORDER BY week_start_date DESC
				LIMIT 1
			) as latest_comment
		FROM users u
		INNER JOIN roles r ON u.role_id = r.id
		LEFT JOIN weekly_reviews rev ON u.id = rev.staff_id AND rev.week_start_date >= $1
		WHERE u.branch_id::text = $2 
			AND u.department_id::text = $3
			AND u.is_active = true
		GROUP BY u.id, u.full_name, u.employee_id, r.name
		ORDER BY avg_rating DESC, u.full_name ASC
	`

	rows, err := db.Query(query, startDate, branchID, departmentID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch ratings: " + err.Error()})
		return
	}
	defer rows.Close()

	ratings := []map[string]interface{}{}
	for rows.Next() {
		var userID string
		var fullName, employeeID, roleName string
		var reviewCount int
		var avgRating, avgAttendance, avgPunctuality, avgPerformance float64
		var lastReviewDate sql.NullTime
		var latestComment string

		err := rows.Scan(
			&userID,
			&fullName,
			&employeeID,
			&roleName,
			&reviewCount,
			&avgRating,
			&avgAttendance,
			&avgPunctuality,
			&avgPerformance,
			&lastReviewDate,
			&latestComment,
		)

		if err != nil {
			continue
		}

		lastReview := ""
		if lastReviewDate.Valid {
			lastReview = lastReviewDate.Time.Format("2006-01-02")
		}

		ratings = append(ratings, map[string]interface{}{
			"user_id":          userID,
			"name":             fullName,
			"employee_id":      employeeID,
			"role":             roleName,
			"review_count":     reviewCount,
			"avg_rating":       avgRating,
			"avg_attendance":   avgAttendance,
			"avg_punctuality":  avgPunctuality,
			"avg_performance":  avgPerformance,
			"last_review_date": lastReview,
			"latest_comment":   latestComment,
			"rating_stars":     formatRating(avgRating),
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"period":  period,
		"data":    ratings,
	})
}
