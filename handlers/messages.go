package handlers

import (
	"ace-mall-backend/utils"
	"database/sql"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
)

// SendMessage allows admin to send messages to all staff or specific branch
func SendMessage(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	userID := c.GetString("user_id")

	// Verify user role and get department if group head
	var roleName string
	var userDepartmentID sql.NullString
	err := db.QueryRow(`
		SELECT r.name, COALESCE(CAST(u.department_id AS TEXT), '') FROM users u
		INNER JOIN roles r ON u.role_id = r.id
		WHERE u.id = $1
	`, userID).Scan(&roleName, &userDepartmentID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify user role"})
		return
	}

	// Check if user has admin privileges (top admins, managers, or group heads)
	// Use contains check to handle variations in role names from database
	isTopAdmin := strings.Contains(roleName, "Executive") || // Chief Executive Officer
		strings.Contains(roleName, "Chairman") || // Chairman (if exists)
		strings.Contains(roleName, "Operating") || // Chief Operating Officer
		strings.Contains(roleName, "HR") || // HR Administrator
		strings.Contains(roleName, "Human Resource") || // Human Resource
		strings.Contains(roleName, "Auditor") || // Auditor
		strings.Contains(roleName, "Branch Manager") || // Branch Manager
		strings.Contains(roleName, "Operations Manager") || // Operations Manager (SuperMarket/Lounge)
		strings.Contains(roleName, "Floor Manager") || // Floor Manager (SuperMarket/Lounge/Eatery)
		strings.Contains(roleName, "Facility Manager") || // Facility Manager 1/2
		strings.Contains(roleName, "Compliance") || // Compliance Officer 1, Assistant Compliance Officer
		strings.Contains(roleName, "Store Manager") || // Store Manager (Eatery)
		strings.Contains(roleName, "Manager (") || // Manager (Cinema/Casino/Saloon/Photo Studio/Arcade & Kiddies Park)
		strings.Contains(roleName, "Supervisor") // Supervisor (Eatery/Lounge)

	// Check if user is a Group Head (can message their department)
	isGroupHead := strings.Contains(roleName, "Group Head") // Group Head (SuperMarket/Eatery/Lounge/Fun & Arcade/Compliance/Facility Management)

	if !isTopAdmin && !isGroupHead {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only administrators and group heads can send messages"})
		return
	}

	var req struct {
		Title            string  `json:"title" binding:"required"`
		Content          string  `json:"content" binding:"required"`
		TargetType       string  `json:"target_type" binding:"required"` // 'all', 'branch', or 'department'
		TargetBranchID   *string `json:"target_branch_id"`
		TargetDepartment *string `json:"target_department_id"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Validate target type
	if req.TargetType != "all" && req.TargetType != "branch" && req.TargetType != "department" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "target_type must be 'all', 'branch', or 'department'"})
		return
	}

	// Group heads can only message their department
	if isGroupHead && !isTopAdmin {
		if req.TargetType != "department" {
			c.JSON(http.StatusForbidden, gin.H{"error": "Group heads can only send messages to their department"})
			return
		}
		// Force department to be their own department
		if userDepartmentID.Valid && userDepartmentID.String != "" {
			req.TargetDepartment = &userDepartmentID.String
		} else {
			c.JSON(http.StatusForbidden, gin.H{"error": "You are not assigned to a department"})
			return
		}
	}

	if req.TargetType == "branch" && req.TargetBranchID == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "target_branch_id is required when target_type is 'branch'"})
		return
	}

	if req.TargetType == "department" && req.TargetDepartment == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "target_department_id is required when target_type is 'department'"})
		return
	}

	// Messages expire after 1 week
	expiresAt := time.Now().Add(7 * 24 * time.Hour)

	// Create message
	var messageID string
	err = db.QueryRow(`
		INSERT INTO messages (sender_id, title, content, target_type, target_branch_id, expires_at)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id
	`, userID, req.Title, req.Content, req.TargetType, req.TargetBranchID, expiresAt).Scan(&messageID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create message"})
		return
	}

	// Get sender details for email
	var senderName, senderRole string
	db.QueryRow(`
		SELECT u.full_name, r.name FROM users u
		LEFT JOIN roles r ON u.role_id = r.id
		WHERE u.id = $1
	`, userID).Scan(&senderName, &senderRole)

	// Get target users (exclude the sender)
	var query string
	var args []interface{}

	if req.TargetType == "all" {
		query = `SELECT id, email, full_name FROM users WHERE id != $1 AND is_terminated = false`
		args = []interface{}{userID}
	} else if req.TargetType == "branch" {
		query = `SELECT id, email, full_name FROM users WHERE branch_id = $1 AND id != $2 AND is_terminated = false`
		args = []interface{}{req.TargetBranchID, userID}
	} else {
		// department
		query = `SELECT id, email, full_name FROM users WHERE department_id = $1 AND id != $2 AND is_terminated = false`
		args = []interface{}{req.TargetDepartment, userID}
	}

	rows, err := db.Query(query, args...)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch target users"})
		return
	}
	defer rows.Close()

	// Create notifications for each user (expire after 1 week for messages)
	notificationExpiresAt := time.Now().Add(7 * 24 * time.Hour)
	emailsSent := 0

	for rows.Next() {
		var targetUserID, targetEmail, targetName string
		if err := rows.Scan(&targetUserID, &targetEmail, &targetName); err != nil {
			continue
		}

		// Create notification in database
		_, _ = db.Exec(`
			INSERT INTO notifications (user_id, title, message, type, message_id, expires_at)
			VALUES ($1, $2, $3, 'message', $4, $5)
		`, targetUserID, req.Title, req.Content, messageID, notificationExpiresAt)

		// Send push notification
		pushData := map[string]string{
			"type":       "admin_message",
			"message_id": messageID,
			"sender":     senderName,
		}
		_ = utils.SendPushNotification(db, targetUserID, req.Title, req.Content, pushData)

		// Send email notification
		emailErr := utils.SendAdminNotification(targetEmail, targetName, senderName, senderRole, req.Title, req.Content)
		if emailErr == nil {
			emailsSent++
		} else {
			fmt.Printf("⚠️ Failed to send notification email to %s: %v\n", targetEmail, emailErr)
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"message":    "Message sent successfully",
		"message_id": messageID,
	})
}

// GetMyNotifications returns all active notifications for the authenticated user
func GetMyNotifications(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	userID := c.GetString("user_id")

	query := `
		SELECT 
			CAST(n.id AS TEXT),
			n.title,
			n.message,
			n.type,
			n.is_read,
			n.created_at,
			n.expires_at
		FROM notifications n
		WHERE n.user_id = $1
		AND n.expires_at > CURRENT_TIMESTAMP
		ORDER BY n.created_at DESC
	`

	rows, err := db.Query(query, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch notifications"})
		return
	}
	defer rows.Close()

	notifications := []map[string]interface{}{}
	for rows.Next() {
		var id, title, message, notifType string
		var isRead bool
		var createdAt, expiresAt time.Time

		err := rows.Scan(&id, &title, &message, &notifType, &isRead, &createdAt, &expiresAt)
		if err != nil {
			continue
		}

		notifications = append(notifications, map[string]interface{}{
			"id":         id,
			"title":      title,
			"message":    message,
			"type":       notifType,
			"is_read":    isRead,
			"created_at": createdAt.Format("2006-01-02 15:04:05"),
			"expires_at": expiresAt.Format("2006-01-02 15:04:05"),
		})
	}

	c.JSON(http.StatusOK, notifications)
}

// CleanupExpiredNotifications removes expired notifications and messages
func CleanupExpiredNotifications(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)

	// Delete expired notifications
	_, err := db.Exec(`DELETE FROM notifications WHERE expires_at < CURRENT_TIMESTAMP`)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to cleanup notifications"})
		return
	}

	// Delete expired messages
	_, err = db.Exec(`DELETE FROM messages WHERE expires_at < CURRENT_TIMESTAMP`)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to cleanup messages"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Cleanup completed"})
}

// GetSentMessages returns all messages sent by the authenticated admin
func GetSentMessages(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	userID := c.GetString("user_id")

	query := `
		SELECT 
			CAST(m.id AS TEXT),
			m.title,
			m.content,
			m.target_type,
			m.target_branch_id,
			b.name as branch_name,
			m.created_at,
			m.expires_at,
			m.is_active
		FROM messages m
		LEFT JOIN branches b ON m.target_branch_id = b.id
		WHERE m.sender_id = $1
		ORDER BY m.created_at DESC
	`

	rows, err := db.Query(query, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch messages"})
		return
	}
	defer rows.Close()

	messages := []map[string]interface{}{}
	for rows.Next() {
		var id, title, content, targetType string
		var targetBranchID sql.NullInt64
		var branchName sql.NullString
		var createdAt, expiresAt time.Time
		var isActive bool

		err := rows.Scan(&id, &title, &content, &targetType, &targetBranchID, &branchName, &createdAt, &expiresAt, &isActive)
		if err != nil {
			continue
		}

		msg := map[string]interface{}{
			"id":          id,
			"title":       title,
			"content":     content,
			"target_type": targetType,
			"created_at":  createdAt.Format("2006-01-02 15:04:05"),
			"expires_at":  expiresAt.Format("2006-01-02 15:04:05"),
			"is_active":   isActive,
		}

		if targetBranchID.Valid {
			msg["target_branch_id"] = targetBranchID.Int64
		}
		if branchName.Valid {
			msg["branch_name"] = branchName.String
		}

		messages = append(messages, msg)
	}

	c.JSON(http.StatusOK, messages)
}
