package handlers

import (
	"database/sql"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

// GetMyAssignments returns roster assignments for the authenticated staff member
func GetMyAssignments(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	userID := c.GetString("user_id")
	weekStart := c.Query("week_start")

	if weekStart == "" {
		// Default to current week
		now := time.Now()
		weekday := int(now.Weekday())
		if weekday == 0 {
			weekday = 7 // Sunday
		}
		currentWeekStart := now.AddDate(0, 0, -(weekday - 1))
		weekStart = currentWeekStart.Format("2006-01-02")
	}

	query := `
		SELECT 
			ra.day_of_week,
			ra.shift_type,
			TO_CHAR(ra.start_time, 'HH24:MI') as start_time,
			TO_CHAR(ra.end_time, 'HH24:MI') as end_time,
			'scheduled' as status,
			r.week_start_date,
			r.week_end_date
		FROM roster_assignments ra
		INNER JOIN rosters r ON ra.roster_id = r.id
		WHERE ra.staff_id = $1 
		AND r.week_start_date = $2
		ORDER BY 
			CASE ra.day_of_week
				WHEN 'monday' THEN 1
				WHEN 'tuesday' THEN 2
				WHEN 'wednesday' THEN 3
				WHEN 'thursday' THEN 4
				WHEN 'friday' THEN 5
				WHEN 'saturday' THEN 6
				WHEN 'sunday' THEN 7
			END
	`

	rows, err := db.Query(query, userID, weekStart)
	if err != nil {
		// Log the actual error for debugging
		println("Schedule query error:", err.Error())
		println("UserID:", userID, "WeekStart:", weekStart)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch schedule", "details": err.Error()})
		return
	}
	defer rows.Close()

	assignments := []map[string]interface{}{}
	weekStartDate, _ := time.Parse("2006-01-02", weekStart)

	for rows.Next() {
		var dayOfWeek, shiftType, status string
		var startTime, endTime string
		var rosterWeekStart, rosterWeekEnd time.Time

		err := rows.Scan(
			&dayOfWeek,
			&shiftType,
			&startTime,
			&endTime,
			&status,
			&rosterWeekStart,
			&rosterWeekEnd,
		)
		if err != nil {
			continue
		}

		// Calculate the actual date for this day
		dayOffset := getDayOffset(dayOfWeek)
		actualDate := weekStartDate.AddDate(0, 0, dayOffset)

		assignments = append(assignments, map[string]interface{}{
			"day":        dayOfWeek,
			"date":       actualDate.Format("Jan 02"),
			"shift_type": shiftType,
			"start_time": startTime,
			"end_time":   endTime,
			"status":     status,
		})
	}

	// If no assignments found, return empty schedule for the week
	if len(assignments) == 0 {
		// Return all days as "Off"
		days := []string{"monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"}
		for i, day := range days {
			actualDate := weekStartDate.AddDate(0, 0, i)
			assignments = append(assignments, map[string]interface{}{
				"day":        day,
				"date":       actualDate.Format("Jan 02"),
				"shift_type": "off",
				"start_time": nil,
				"end_time":   nil,
				"status":     "off",
			})
		}
	}

	c.JSON(http.StatusOK, assignments)
}

// GetMyUpcomingShifts returns upcoming shifts for the authenticated staff member
func GetMyUpcomingShifts(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	userID := c.GetString("user_id")
	limit := c.DefaultQuery("limit", "10")

	query := `
		SELECT 
			ra.day_of_week,
			ra.shift_type,
			TO_CHAR(ra.start_time, 'HH24:MI') as start_time,
			TO_CHAR(ra.end_time, 'HH24:MI') as end_time,
			r.week_start_date,
			r.week_end_date
		FROM roster_assignments ra
		INNER JOIN rosters r ON ra.roster_id = r.id
		WHERE ra.staff_id = $1 
		AND r.week_start_date >= CURRENT_DATE
		AND ra.shift_type != 'off'
		ORDER BY r.week_start_date, 
			CASE ra.day_of_week
				WHEN 'monday' THEN 1
				WHEN 'tuesday' THEN 2
				WHEN 'wednesday' THEN 3
				WHEN 'thursday' THEN 4
				WHEN 'friday' THEN 5
				WHEN 'saturday' THEN 6
				WHEN 'sunday' THEN 7
			END
		LIMIT $2
	`

	rows, err := db.Query(query, userID, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch upcoming shifts"})
		return
	}
	defer rows.Close()

	shifts := []map[string]interface{}{}
	for rows.Next() {
		var dayOfWeek, shiftType, startTime, endTime string
		var weekStart, weekEnd time.Time

		err := rows.Scan(
			&dayOfWeek,
			&shiftType,
			&startTime,
			&endTime,
			&weekStart,
			&weekEnd,
		)
		if err != nil {
			continue
		}

		// Calculate actual shift date
		dayOffset := getDayOffset(dayOfWeek)
		shiftDate := weekStart.AddDate(0, 0, dayOffset)

		shifts = append(shifts, map[string]interface{}{
			"date":       shiftDate.Format("2006-01-02"),
			"day":        dayOfWeek,
			"shift_type": shiftType,
			"start_time": startTime,
			"end_time":   endTime,
			"week_start": weekStart.Format("2006-01-02"),
			"week_end":   weekEnd.Format("2006-01-02"),
		})
	}

	c.JSON(http.StatusOK, shifts)
}

// Helper function to get day offset from Monday
func getDayOffset(day string) int {
	switch day {
	case "monday":
		return 0
	case "tuesday":
		return 1
	case "wednesday":
		return 2
	case "thursday":
		return 3
	case "friday":
		return 4
	case "saturday":
		return 5
	case "sunday":
		return 6
	default:
		return 0
	}
}
