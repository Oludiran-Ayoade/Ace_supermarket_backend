package scheduler

import (
	"ace-mall-backend/utils"
	"database/sql"
	"log"
	"time"
)

// ShiftNotificationScheduler handles sending notifications before shifts
type ShiftNotificationScheduler struct {
	db       *sql.DB
	ticker   *time.Ticker
	stopChan chan bool
}

// NewShiftNotificationScheduler creates a new scheduler
func NewShiftNotificationScheduler(db *sql.DB) *ShiftNotificationScheduler {
	return &ShiftNotificationScheduler{
		db:       db,
		stopChan: make(chan bool),
	}
}

// Start begins the scheduler that checks every minute
func (s *ShiftNotificationScheduler) Start() {
	s.ticker = time.NewTicker(1 * time.Minute)
	go func() {
		// Run immediately on start
		s.checkAndSendNotifications()

		for {
			select {
			case <-s.ticker.C:
				s.checkAndSendNotifications()
			case <-s.stopChan:
				s.ticker.Stop()
				return
			}
		}
	}()
	log.Println("✅ Shift notification scheduler started (checks every minute)")
}

// Stop stops the scheduler
func (s *ShiftNotificationScheduler) Stop() {
	s.stopChan <- true
	log.Println("⏹️ Shift notification scheduler stopped")
}

// checkAndSendNotifications checks for upcoming shifts and sends notifications
func (s *ShiftNotificationScheduler) checkAndSendNotifications() {
	now := time.Now()
	currentDay := now.Weekday().String()

	// Map Go's weekday to database enum (lowercase)
	dayMap := map[string]string{
		"Monday":    "monday",
		"Tuesday":   "tuesday",
		"Wednesday": "wednesday",
		"Thursday":  "thursday",
		"Friday":    "friday",
		"Saturday":  "saturday",
		"Sunday":    "sunday",
	}
	dbDay := dayMap[currentDay]

	// Calculate the time window: shifts starting between 25-35 minutes from now
	// This gives a 10-minute window to catch shifts that should get a 30-min notification
	minTime := now.Add(25 * time.Minute).Format("15:04")
	maxTime := now.Add(35 * time.Minute).Format("15:04")

	// Get current week's start date (Monday)
	weekday := int(now.Weekday())
	if weekday == 0 {
		weekday = 7
	}
	weekStart := now.AddDate(0, 0, -(weekday - 1)).Format("2006-01-02")

	// Query for staff with shifts starting in ~30 minutes who haven't been notified today
	query := `
		SELECT DISTINCT 
			ra.staff_id,
			u.full_name,
			ra.shift_type,
			TO_CHAR(ra.start_time, 'HH24:MI') as start_time,
			TO_CHAR(ra.end_time, 'HH24:MI') as end_time,
			d.name as department_name,
			b.name as branch_name
		FROM roster_assignments ra
		INNER JOIN rosters r ON ra.roster_id = r.id
		INNER JOIN users u ON ra.staff_id = u.id
		LEFT JOIN departments d ON u.department_id = d.id
		LEFT JOIN branches b ON u.branch_id = b.id
		WHERE ra.day_of_week = $1
		AND r.week_start_date = $2
		AND ra.shift_type IN ('day', 'afternoon', 'night')
		AND TO_CHAR(ra.start_time, 'HH24:MI') >= $3
		AND TO_CHAR(ra.start_time, 'HH24:MI') <= $4
		AND NOT EXISTS (
			SELECT 1 FROM notifications n 
			WHERE n.user_id = ra.staff_id 
			AND n.type = 'shift_reminder'
			AND DATE(n.created_at) = CURRENT_DATE
			AND n.message LIKE '%' || TO_CHAR(ra.start_time, 'HH24:MI') || '%'
		)
	`

	rows, err := s.db.Query(query, dbDay, weekStart, minTime, maxTime)
	if err != nil {
		log.Printf("⚠️ Error checking upcoming shifts: %v", err)
		return
	}
	defer rows.Close()

	notificationCount := 0
	for rows.Next() {
		var staffID, fullName, shiftType, startTime, endTime string
		var departmentName, branchName sql.NullString

		err := rows.Scan(&staffID, &fullName, &shiftType, &startTime, &endTime, &departmentName, &branchName)
		if err != nil {
			log.Printf("⚠️ Error scanning shift row: %v", err)
			continue
		}

		// Create notification
		title := "⏰ Shift Reminder"
		message := "Your " + getShiftDisplayName(shiftType) + " (" + startTime + " - " + endTime + ") starts in 30 minutes!"
		if departmentName.Valid {
			message += " Department: " + departmentName.String
		}

		_, err = s.db.Exec(`
			INSERT INTO notifications (user_id, title, message, type, is_read, created_at, updated_at)
			VALUES ($1, $2, $3, 'shift_reminder', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
		`, staffID, title, message)

		if err != nil {
			log.Printf("⚠️ Error creating shift notification for %s: %v", fullName, err)
			continue
		}

		// Send push notification
		pushData := map[string]string{
			"type":       "shift_reminder",
			"shift_type": shiftType,
			"start_time": startTime,
			"end_time":   endTime,
		}
		if departmentName.Valid {
			pushData["department"] = departmentName.String
		}
		if branchName.Valid {
			pushData["branch"] = branchName.String
		}
		_ = utils.SendPushNotification(s.db, staffID, title, message, pushData)

		notificationCount++
		log.Printf("📢 Shift notification sent to %s for %s shift at %s", fullName, shiftType, startTime)
	}

	if notificationCount > 0 {
		log.Printf("✅ Sent %d shift reminder notifications", notificationCount)
	}
}

// getShiftDisplayName returns a human-readable shift name
func getShiftDisplayName(shiftType string) string {
	switch shiftType {
	case "morning", "day":
		return "Morning Shift"
	case "afternoon":
		return "Afternoon Shift"
	case "evening":
		return "Evening Shift"
	case "night":
		return "Night Shift"
	default:
		return shiftType + " Shift"
	}
}
