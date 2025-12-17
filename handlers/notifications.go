package handlers

import (
	"database/sql"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

// GetUserNotifications returns all notifications for the authenticated user
func GetUserNotifications(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	userID := c.GetString("user_id")

	// Optional pagination
	limit := c.DefaultQuery("limit", "50")
	offset := c.DefaultQuery("offset", "0")

	query := `
		SELECT id, type, title, message, is_read, created_at
		FROM notifications
		WHERE user_id = $1
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3
	`

	rows, err := db.Query(query, userID, limit, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch notifications"})
		return
	}
	defer rows.Close()

	notifications := []map[string]interface{}{}
	for rows.Next() {
		var id int
		var notifType, title, message string
		var isRead bool
		var createdAt time.Time

		err := rows.Scan(&id, &notifType, &title, &message, &isRead, &createdAt)
		if err != nil {
			continue
		}

		notifications = append(notifications, map[string]interface{}{
			"id":         id,
			"type":       notifType,
			"title":      title,
			"message":    message,
			"is_read":    isRead,
			"created_at": createdAt.Format(time.RFC3339),
		})
	}

	c.JSON(http.StatusOK, notifications)
}

// MarkNotificationAsRead marks a single notification as read
func MarkNotificationAsRead(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	userID := c.GetString("user_id")
	notificationID := c.Param("id")

	query := `
		UPDATE notifications
		SET is_read = TRUE, updated_at = CURRENT_TIMESTAMP
		WHERE id = $1 AND user_id = $2
	`

	result, err := db.Exec(query, notificationID, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update notification"})
		return
	}

	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Notification not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Notification marked as read"})
}

// MarkAllNotificationsAsRead marks all notifications as read for the user
func MarkAllNotificationsAsRead(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	userID := c.GetString("user_id")

	query := `
		UPDATE notifications
		SET is_read = TRUE, updated_at = CURRENT_TIMESTAMP
		WHERE user_id = $1 AND is_read = FALSE
	`

	result, err := db.Exec(query, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update notifications"})
		return
	}

	rowsAffected, _ := result.RowsAffected()
	c.JSON(http.StatusOK, gin.H{
		"message": "All notifications marked as read",
		"count":   rowsAffected,
	})
}

// CreateNotification creates a new notification (system/manager use)
func CreateNotification(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)

	var req struct {
		UserID  int    `json:"user_id" binding:"required"`
		Type    string `json:"type" binding:"required"`
		Title   string `json:"title" binding:"required"`
		Message string `json:"message" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Validate notification type
	validTypes := map[string]bool{
		"shift_reminder":    true,
		"roster_assignment": true,
		"schedule_change":   true,
		"review":            true,
		"general":           true,
	}

	if !validTypes[req.Type] {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid notification type"})
		return
	}

	query := `
		INSERT INTO notifications (user_id, type, title, message)
		VALUES ($1, $2, $3, $4)
		RETURNING id, created_at
	`

	var notificationID int
	var createdAt time.Time
	err := db.QueryRow(query, req.UserID, req.Type, req.Title, req.Message).Scan(&notificationID, &createdAt)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create notification"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"id":         notificationID,
		"created_at": createdAt.Format(time.RFC3339),
		"message":    "Notification created successfully",
	})
}

// DeleteNotification deletes a notification
func DeleteNotification(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	userID := c.GetString("user_id")
	notificationID := c.Param("id")

	query := `DELETE FROM notifications WHERE id = $1 AND user_id = $2`

	result, err := db.Exec(query, notificationID, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete notification"})
		return
	}

	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Notification not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Notification deleted successfully"})
}

// GetUnreadCount returns the count of unread notifications
func GetUnreadCount(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	userID := c.GetString("user_id")

	var count int
	query := `SELECT COUNT(*) FROM notifications WHERE user_id = $1 AND is_read = FALSE`

	err := db.QueryRow(query, userID).Scan(&count)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get unread count"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"unread_count": count})
}

// Helper function to create roster assignment notifications
func CreateRosterAssignmentNotifications(db *sql.DB, rosterID int, staffAssignments []map[string]interface{}) error {
	// Get roster details
	var weekStart, weekEnd time.Time
	var floorManagerID int
	var floorManagerName string

	err := db.QueryRow(`
		SELECT r.week_start, r.week_end, r.floor_manager_id, u.full_name
		FROM rosters r
		JOIN users u ON r.floor_manager_id = u.id
		WHERE r.id = $1
	`, rosterID).Scan(&weekStart, &weekEnd, &floorManagerID, &floorManagerName)

	if err != nil {
		return err
	}

	// Create notifications for each staff member
	for _, assignment := range staffAssignments {
		staffID := assignment["staff_id"].(int)
		dayOfWeek := assignment["day_of_week"].(string)
		shiftType := assignment["shift_type"].(string)
		startTime := assignment["start_time"].(string)
		endTime := assignment["end_time"].(string)

		title := "New Roster Assignment"
		message := "You've been assigned to work " + dayOfWeek + " - " + shiftType + " shift (" + startTime + " - " + endTime + ") by " + floorManagerName

		_, err := db.Exec(`
			INSERT INTO notifications (user_id, type, title, message)
			VALUES ($1, 'roster_assignment', $2, $3)
		`, staffID, title, message)

		if err != nil {
			// Log error but continue with other notifications
			continue
		}
	}

	return nil
}
