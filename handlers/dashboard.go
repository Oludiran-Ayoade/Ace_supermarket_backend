package handlers

import (
	"database/sql"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

// GetDashboardStats returns dashboard statistics for the authenticated user
func GetDashboardStats(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	userID := c.GetString("user_id")

	// Get user role
	var roleName string
	err := db.QueryRow(`
		SELECT r.name FROM users u
		INNER JOIN roles r ON u.role_id = r.id
		WHERE u.id = $1
	`, userID).Scan(&roleName)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get user role"})
		return
	}

	// Return stats based on role
	if strings.Contains(roleName, "Floor Manager") || strings.Contains(roleName, "Manager (") ||
		strings.Contains(roleName, "Compliance Officer") || strings.Contains(roleName, "Facility Manager") {
		getFloorManagerStats(c, db, userID)
	} else if roleName == "senior_admin" || strings.Contains(roleName, "HR") || strings.Contains(roleName, "Human Resource") {
		getHRStats(c, db, userID)
	} else if roleName == "admin" || strings.Contains(roleName, "Branch Manager") || strings.Contains(roleName, "Operations Manager") {
		getBranchManagerStats(c, db, userID)
	} else if roleName == "super_admin" || strings.Contains(roleName, "CEO") || strings.Contains(roleName, "Chief Executive") {
		getCEOStats(c, db, userID)
	} else if strings.Contains(roleName, "COO") || strings.Contains(roleName, "Chief Operating") {
		getCOOStats(c, db, userID)
	} else if strings.Contains(roleName, "Auditor") {
		getAuditorStats(c, db, userID)
	} else {
		// General staff (including Store Managers)
		getGeneralStaffStats(c, db, userID)
	}
}

// Floor Manager Dashboard Stats
func getFloorManagerStats(c *gin.Context, db *sql.DB, userID string) {
	stats := make(map[string]interface{})

	// Check if this is a sub-department manager
	var subDeptID sql.NullString
	db.QueryRow(`SELECT sub_department_id FROM users WHERE id = $1`, userID).Scan(&subDeptID)

	// Get team members count (all staff in department/sub-department)
	var teamCount int
	if subDeptID.Valid && subDeptID.String != "" {
		// Sub-department manager - only count staff in their sub-department
		db.QueryRow(`
			SELECT COUNT(*) FROM users
			WHERE department_id = (SELECT department_id FROM users WHERE id = $1)
			AND branch_id = (SELECT branch_id FROM users WHERE id = $1)
			AND sub_department_id = (SELECT sub_department_id FROM users WHERE id = $1)
			AND id != $1
		`, userID).Scan(&teamCount)
	} else {
		// Regular floor manager - count all staff in department
		db.QueryRow(`
			SELECT COUNT(*) FROM users
			WHERE department_id = (SELECT department_id FROM users WHERE id = $1)
			AND branch_id = (SELECT branch_id FROM users WHERE id = $1)
			AND id != $1
		`, userID).Scan(&teamCount)
	}
	stats["team_members"] = teamCount
	// All staff are considered active
	stats["active_staff"] = teamCount

	// Get active rosters count (current and future weeks)
	var activeRosters int
	db.QueryRow(`
		SELECT COUNT(*) FROM rosters
		WHERE floor_manager_id = $1
		AND week_end_date >= CURRENT_DATE
	`, userID).Scan(&activeRosters)
	stats["active_rosters"] = activeRosters

	// Get pending reviews count (staff without reviews this week in weekly_reviews table)
	var pendingReviews int
	if subDeptID.Valid && subDeptID.String != "" {
		// Sub-department manager - only count staff in their sub-department
		db.QueryRow(`
			SELECT COUNT(DISTINCT u.id)
			FROM users u
			WHERE u.department_id = (SELECT department_id FROM users WHERE id = $1)
			AND u.branch_id = (SELECT branch_id FROM users WHERE id = $1)
			AND u.sub_department_id = (SELECT sub_department_id FROM users WHERE id = $1)
			AND u.id != $1
			AND NOT EXISTS (
				SELECT 1 FROM weekly_reviews wr
				WHERE CAST(wr.staff_id AS TEXT) = CAST(u.id AS TEXT)
				AND wr.week_start_date >= date_trunc('week', CURRENT_DATE)::date
			)
		`, userID).Scan(&pendingReviews)
	} else {
		// Regular floor manager
		db.QueryRow(`
			SELECT COUNT(DISTINCT u.id)
			FROM users u
			WHERE u.department_id = (SELECT department_id FROM users WHERE id = $1)
			AND u.branch_id = (SELECT branch_id FROM users WHERE id = $1)
			AND u.id != $1
			AND NOT EXISTS (
				SELECT 1 FROM weekly_reviews wr
				WHERE CAST(wr.staff_id AS TEXT) = CAST(u.id AS TEXT)
				AND wr.week_start_date >= date_trunc('week', CURRENT_DATE)::date
			)
		`, userID).Scan(&pendingReviews)
	}
	stats["pending_reviews"] = pendingReviews

	// Get this week's reviews count
	var weekReviews int
	db.QueryRow(`
		SELECT COUNT(*) FROM weekly_reviews
		WHERE CAST(reviewer_id AS TEXT) = $1
		AND week_start_date >= date_trunc('week', CURRENT_DATE)::date
	`, userID).Scan(&weekReviews)
	stats["week_reviews"] = weekReviews

	// Get average team rating this month
	var avgRating float64
	db.QueryRow(`
		SELECT COALESCE(AVG((rating)), 0)
		FROM weekly_reviews
		WHERE CAST(reviewer_id AS TEXT) = $1
		AND week_start_date >= date_trunc('month', CURRENT_DATE)::date
	`, userID).Scan(&avgRating)
	stats["avg_team_rating"] = avgRating

	// Get upcoming shifts count
	var upcomingShifts int
	db.QueryRow(`
		SELECT COUNT(*) FROM roster_assignments ra
		INNER JOIN rosters r ON ra.roster_id = r.id
		WHERE CAST(r.floor_manager_id AS TEXT) = $1
		AND r.week_start_date >= CURRENT_DATE
		AND ra.shift_type != 'off'
	`, userID).Scan(&upcomingShifts)
	stats["upcoming_shifts"] = upcomingShifts

	c.JSON(http.StatusOK, stats)
}

// HR Dashboard Stats
func getHRStats(c *gin.Context, db *sql.DB, userID string) {
	stats := make(map[string]interface{})

	// Total staff count
	var totalStaff int
	db.QueryRow(`SELECT COUNT(*) FROM users WHERE role_id != 1`).Scan(&totalStaff)
	stats["total_staff"] = totalStaff

	// Active staff (logged in last 30 days)
	var activeStaff int
	db.QueryRow(`
		SELECT COUNT(*) FROM users
		WHERE last_login >= CURRENT_DATE - INTERVAL '30 days'
		AND role_id != 1
	`).Scan(&activeStaff)
	stats["active_staff"] = activeStaff

	// New hires this month
	var newHires int
	db.QueryRow(`
		SELECT COUNT(*) FROM users
		WHERE created_at >= date_trunc('month', CURRENT_DATE)
	`).Scan(&newHires)
	stats["new_hires"] = newHires

	// Pending documents
	var pendingDocs int
	db.QueryRow(`
		SELECT COUNT(*) FROM users
		WHERE (profile_picture IS NULL OR profile_picture = '')
		AND role_id != 1
	`).Scan(&pendingDocs)
	stats["pending_documents"] = pendingDocs

	// Departments count
	var deptCount int
	db.QueryRow(`SELECT COUNT(*) FROM departments`).Scan(&deptCount)
	stats["departments"] = deptCount

	// Branches count
	var branchCount int
	db.QueryRow(`SELECT COUNT(*) FROM branches`).Scan(&branchCount)
	stats["branches"] = branchCount

	// Average rating across all staff
	var avgRating float64
	db.QueryRow(`
		SELECT COALESCE(AVG((attendance_score + punctuality_score + performance_score) / 3), 0)
		FROM reviews
		WHERE created_at >= date_trunc('month', CURRENT_DATE)
	`).Scan(&avgRating)
	stats["avg_rating"] = avgRating

	c.JSON(http.StatusOK, stats)
}

// Branch Manager Dashboard Stats
func getBranchManagerStats(c *gin.Context, db *sql.DB, userID string) {
	stats := make(map[string]interface{})

	// Get branch ID
	var branchID int
	db.QueryRow(`SELECT branch_id FROM users WHERE id = $1`, userID).Scan(&branchID)

	// Branch staff count
	var branchStaff int
	db.QueryRow(`
		SELECT COUNT(*) FROM users
		WHERE branch_id = $1 AND id != $2
	`, branchID, userID).Scan(&branchStaff)
	stats["branch_staff"] = branchStaff

	// Active rosters
	var activeRosters int
	db.QueryRow(`
		SELECT COUNT(*) FROM rosters r
		INNER JOIN users u ON r.floor_manager_id = u.id
		WHERE u.branch_id = $1
		AND r.week_end >= CURRENT_DATE
	`, branchID).Scan(&activeRosters)
	stats["active_rosters"] = activeRosters

	// Departments in branch
	var deptCount int
	db.QueryRow(`
		SELECT COUNT(DISTINCT department_id) FROM users
		WHERE branch_id = $1
	`, branchID).Scan(&deptCount)
	stats["departments"] = deptCount

	// This month's reviews
	var monthReviews int
	db.QueryRow(`
		SELECT COUNT(*) FROM reviews r
		INNER JOIN users u ON r.staff_id = u.id
		WHERE u.branch_id = $1
		AND r.created_at >= date_trunc('month', CURRENT_DATE)
	`, branchID).Scan(&monthReviews)
	stats["month_reviews"] = monthReviews

	// Average branch rating
	var avgRating float64
	db.QueryRow(`
		SELECT COALESCE(AVG((r.attendance_score + r.punctuality_score + r.performance_score) / 3), 0)
		FROM reviews r
		INNER JOIN users u ON r.staff_id = u.id
		WHERE u.branch_id = $1
		AND r.created_at >= date_trunc('month', CURRENT_DATE)
	`, branchID).Scan(&avgRating)
	stats["avg_rating"] = avgRating

	c.JSON(http.StatusOK, stats)
}

// CEO Dashboard Stats - Strategic Overview
func getCEOStats(c *gin.Context, db *sql.DB, userID string) {
	stats := make(map[string]interface{})

	// Total employees
	var totalEmployees int
	db.QueryRow(`SELECT COUNT(*) FROM users WHERE role_id != 1`).Scan(&totalEmployees)
	stats["total_employees"] = totalEmployees

	// All staff are active
	stats["active_staff"] = totalEmployees

	// Total branches
	var totalBranches int
	db.QueryRow(`SELECT COUNT(*) FROM branches`).Scan(&totalBranches)
	stats["total_branches"] = totalBranches

	// Total departments
	var totalDepartments int
	db.QueryRow(`SELECT COUNT(*) FROM departments`).Scan(&totalDepartments)
	stats["total_departments"] = totalDepartments

	// Active rosters company-wide
	var activeRosters int
	db.QueryRow(`
		SELECT COUNT(*) FROM rosters
		WHERE week_end_date >= CURRENT_DATE
	`).Scan(&activeRosters)
	stats["active_rosters"] = activeRosters

	// This month's reviews company-wide
	var monthReviews int
	db.QueryRow(`
		SELECT COUNT(*) FROM weekly_reviews
		WHERE week_start_date >= date_trunc('month', CURRENT_DATE)::date
	`).Scan(&monthReviews)
	stats["month_reviews"] = monthReviews

	// Company-wide average rating
	var avgRating float64
	db.QueryRow(`
		SELECT COALESCE(AVG(rating), 0)
		FROM weekly_reviews
		WHERE week_start_date >= date_trunc('month', CURRENT_DATE)::date
	`).Scan(&avgRating)
	stats["company_avg_rating"] = avgRating

	// Top performing branch
	var topBranch string
	db.QueryRow(`
		SELECT b.name
		FROM branches b
		INNER JOIN users u ON b.id = u.branch_id
		INNER JOIN weekly_reviews wr ON CAST(u.id AS TEXT) = CAST(wr.staff_id AS TEXT)
		WHERE wr.week_start_date >= date_trunc('month', CURRENT_DATE)::date
		GROUP BY b.id, b.name
		ORDER BY AVG(wr.rating) DESC
		LIMIT 1
	`).Scan(&topBranch)
	stats["top_branch"] = topBranch

	// Total revenue (placeholder - would come from sales/finance system)
	stats["revenue_status"] = "Available in Finance Module"

	c.JSON(http.StatusOK, stats)
}

// COO Dashboard Stats - Operations Overview
func getCOOStats(c *gin.Context, db *sql.DB, userID string) {
	stats := make(map[string]interface{})

	// Total operational staff
	var operationalStaff int
	db.QueryRow(`
		SELECT COUNT(*) FROM users u
		INNER JOIN roles r ON u.role_id = r.id
		WHERE r.name NOT LIKE '%CEO%' AND r.name NOT LIKE '%Chairman%'
	`).Scan(&operationalStaff)
	stats["operational_staff"] = operationalStaff

	// Active branches
	var activeBranches int
	db.QueryRow(`SELECT COUNT(*) FROM branches`).Scan(&activeBranches)
	stats["active_branches"] = activeBranches

	// Current week rosters
	var currentWeekRosters int
	db.QueryRow(`
		SELECT COUNT(*) FROM rosters
		WHERE week_start <= CURRENT_DATE AND week_end >= CURRENT_DATE
	`).Scan(&currentWeekRosters)
	stats["current_week_rosters"] = currentWeekRosters

	// Pending roster assignments
	var pendingAssignments int
	db.QueryRow(`
		SELECT COUNT(*) FROM roster_assignments ra
		INNER JOIN rosters r ON ra.roster_id = r.id
		WHERE r.week_start >= CURRENT_DATE
		AND ra.attendance_status = 'pending'
	`).Scan(&pendingAssignments)
	stats["pending_assignments"] = pendingAssignments

	// This week's attendance rate
	var attendanceRate float64
	db.QueryRow(`
		SELECT COALESCE(
			(COUNT(CASE WHEN ra.attendance_status = 'present' THEN 1 END)::float / 
			NULLIF(COUNT(*), 0)) * 100, 0)
		FROM roster_assignments ra
		INNER JOIN rosters r ON ra.roster_id = r.id
		WHERE r.week_start <= CURRENT_DATE AND r.week_end >= CURRENT_DATE
		AND ra.shift_type != 'off'
	`).Scan(&attendanceRate)
	stats["attendance_rate"] = attendanceRate

	// Departments needing attention (low performance)
	var lowPerformingDepts int
	db.QueryRow(`
		SELECT COUNT(DISTINCT d.id)
		FROM departments d
		INNER JOIN users u ON d.id = u.department_id
		INNER JOIN reviews r ON u.id = r.staff_id
		WHERE r.created_at >= date_trunc('month', CURRENT_DATE)
		GROUP BY d.id
		HAVING AVG((r.attendance_score + r.punctuality_score + r.performance_score) / 3) < 3.0
	`).Scan(&lowPerformingDepts)
	stats["departments_needing_attention"] = lowPerformingDepts

	// Branch performance summary
	type BranchPerf struct {
		Name   string  `json:"name"`
		Rating float64 `json:"rating"`
	}
	rows, _ := db.Query(`
		SELECT b.name, COALESCE(AVG((r.attendance_score + r.punctuality_score + r.performance_score) / 3), 0) as avg_rating
		FROM branches b
		LEFT JOIN users u ON b.id = u.branch_id
		LEFT JOIN reviews r ON u.id = r.staff_id AND r.created_at >= date_trunc('month', CURRENT_DATE)
		GROUP BY b.id, b.name
		ORDER BY avg_rating DESC
		LIMIT 5
	`)
	defer rows.Close()

	branchPerformance := []BranchPerf{}
	for rows.Next() {
		var bp BranchPerf
		rows.Scan(&bp.Name, &bp.Rating)
		branchPerformance = append(branchPerformance, bp)
	}
	stats["branch_performance"] = branchPerformance

	c.JSON(http.StatusOK, stats)
}

// Auditor Dashboard Stats - Compliance & Financial Oversight
func getAuditorStats(c *gin.Context, db *sql.DB, userID string) {
	stats := make(map[string]interface{})

	// Total staff under audit
	var totalStaff int
	db.QueryRow(`SELECT COUNT(*) FROM users WHERE role_id != 1`).Scan(&totalStaff)
	stats["total_staff"] = totalStaff

	// Total branches
	var totalBranches int
	db.QueryRow(`SELECT COUNT(*) FROM branches`).Scan(&totalBranches)
	stats["total_branches"] = totalBranches

	// Reviews completed this month
	var reviewsCompleted int
	db.QueryRow(`
		SELECT COUNT(*) FROM reviews
		WHERE created_at >= date_trunc('month', CURRENT_DATE)
	`).Scan(&reviewsCompleted)
	stats["reviews_completed"] = reviewsCompleted

	// Staff with incomplete documentation
	var incompleteDocuments int
	db.QueryRow(`
		SELECT COUNT(*) FROM users
		WHERE (profile_picture IS NULL OR profile_picture = '')
		AND role_id != 1
	`).Scan(&incompleteDocuments)
	stats["incomplete_documents"] = incompleteDocuments

	// Attendance compliance rate
	var complianceRate float64
	db.QueryRow(`
		SELECT COALESCE(
			(COUNT(CASE WHEN ra.attendance_status = 'present' THEN 1 END)::float / 
			NULLIF(COUNT(*), 0)) * 100, 0)
		FROM roster_assignments ra
		INNER JOIN rosters r ON ra.roster_id = r.id
		WHERE r.created_at >= date_trunc('month', CURRENT_DATE)
		AND ra.shift_type != 'off'
	`).Scan(&complianceRate)
	stats["attendance_compliance"] = complianceRate

	// Low-rated staff (potential issues)
	var lowRatedStaff int
	db.QueryRow(`
		SELECT COUNT(DISTINCT r.staff_id)
		FROM reviews r
		WHERE r.created_at >= date_trunc('month', CURRENT_DATE)
		GROUP BY r.staff_id
		HAVING AVG((r.attendance_score + r.punctuality_score + r.performance_score) / 3) < 2.5
	`).Scan(&lowRatedStaff)
	stats["staff_needing_review"] = lowRatedStaff

	// Departments audit status
	type DeptAudit struct {
		Name       string  `json:"name"`
		StaffCount int     `json:"staff_count"`
		AvgRating  float64 `json:"avg_rating"`
	}
	rows, _ := db.Query(`
		SELECT d.name, COUNT(DISTINCT u.id) as staff_count,
		       COALESCE(AVG((r.attendance_score + r.punctuality_score + r.performance_score) / 3), 0) as avg_rating
		FROM departments d
		LEFT JOIN users u ON d.id = u.department_id
		LEFT JOIN reviews r ON u.id = r.staff_id AND r.created_at >= date_trunc('month', CURRENT_DATE)
		GROUP BY d.id, d.name
		ORDER BY avg_rating ASC
		LIMIT 5
	`)
	defer rows.Close()

	deptAudits := []DeptAudit{}
	for rows.Next() {
		var da DeptAudit
		rows.Scan(&da.Name, &da.StaffCount, &da.AvgRating)
		deptAudits = append(deptAudits, da)
	}
	stats["department_audits"] = deptAudits

	// Compliance alerts
	stats["compliance_status"] = "All systems operational"
	if incompleteDocuments > 10 {
		stats["compliance_status"] = "Document compliance needs attention"
	}

	c.JSON(http.StatusOK, stats)
}

// General Staff Dashboard Stats
func getGeneralStaffStats(c *gin.Context, db *sql.DB, userID string) {
	stats := make(map[string]interface{})

	// My reviews count
	var reviewsCount int
	db.QueryRow(`
		SELECT COUNT(*) FROM reviews WHERE staff_id = $1
	`, userID).Scan(&reviewsCount)
	stats["total_reviews"] = reviewsCount

	// My average rating
	var avgRating float64
	db.QueryRow(`
		SELECT COALESCE(AVG((attendance_score + punctuality_score + performance_score) / 3), 0)
		FROM reviews WHERE staff_id = $1
	`, userID).Scan(&avgRating)
	stats["avg_rating"] = avgRating

	// Upcoming shifts count
	var upcomingShifts int
	db.QueryRow(`
		SELECT COUNT(*) FROM roster_assignments ra
		INNER JOIN rosters r ON ra.roster_id = r.id
		WHERE ra.staff_id = $1
		AND r.week_start >= CURRENT_DATE
		AND ra.shift_type != 'off'
	`, userID).Scan(&upcomingShifts)
	stats["upcoming_shifts"] = upcomingShifts

	// Unread notifications
	var unreadNotifications int
	db.QueryRow(`
		SELECT COUNT(*) FROM notifications
		WHERE user_id = $1 AND is_read = FALSE
	`, userID).Scan(&unreadNotifications)
	stats["unread_notifications"] = unreadNotifications

	// This month's reviews
	var monthReviews int
	db.QueryRow(`
		SELECT COUNT(*) FROM reviews
		WHERE staff_id = $1
		AND created_at >= date_trunc('month', CURRENT_DATE)
	`, userID).Scan(&monthReviews)
	stats["month_reviews"] = monthReviews

	// Last review date
	var lastReviewDate sql.NullTime
	db.QueryRow(`
		SELECT MAX(created_at) FROM reviews WHERE staff_id = $1
	`, userID).Scan(&lastReviewDate)

	if lastReviewDate.Valid {
		stats["last_review_date"] = lastReviewDate.Time.Format("2006-01-02")
	} else {
		stats["last_review_date"] = nil
	}

	c.JSON(http.StatusOK, stats)
}
