package utils

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"path/filepath"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"google.golang.org/api/option"
)

var fcmClient *messaging.Client

// InitFirebase initializes Firebase Admin SDK for push notifications
func InitFirebase() error {
	// Check if Firebase credentials file exists
	credPath := os.Getenv("FIREBASE_CREDENTIALS_PATH")
	if credPath == "" {
		credPath = "firebase-credentials.json"
	}

	// Check if file exists
	if _, err := os.Stat(credPath); os.IsNotExist(err) {
		log.Println("⚠️ Firebase credentials file not found. Push notifications will be disabled.")
		log.Println("To enable push notifications:")
		log.Println("1. Download Firebase service account JSON from Firebase Console")
		log.Println("2. Save it as 'firebase-credentials.json' in the backend directory")
		log.Println("3. Or set FIREBASE_CREDENTIALS_PATH environment variable")
		return nil
	}

	// Get absolute path
	absPath, err := filepath.Abs(credPath)
	if err != nil {
		return fmt.Errorf("failed to get absolute path: %v", err)
	}

	// Initialize Firebase app
	opt := option.WithCredentialsFile(absPath)
	app, err := firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		return fmt.Errorf("failed to initialize Firebase app: %v", err)
	}

	// Get messaging client
	fcmClient, err = app.Messaging(context.Background())
	if err != nil {
		return fmt.Errorf("failed to get FCM client: %v", err)
	}

	log.Println("✅ Firebase Cloud Messaging initialized successfully")
	return nil
}

// SendPushNotification sends a push notification to a user's devices
func SendPushNotification(db *sql.DB, userID, title, body string, data map[string]string) error {
	if fcmClient == nil {
		log.Printf("⚠️ FCM client not initialized. Skipping push notification for user %s", userID)
		return nil
	}

	// Get all device tokens for the user
	rows, err := db.Query(`
		SELECT device_token, device_type 
		FROM device_tokens 
		WHERE user_id = $1
	`, userID)
	if err != nil {
		return fmt.Errorf("failed to fetch device tokens: %v", err)
	}
	defer rows.Close()

	tokens := []string{}
	for rows.Next() {
		var token, deviceType string
		if err := rows.Scan(&token, &deviceType); err != nil {
			continue
		}
		tokens = append(tokens, token)
	}

	if len(tokens) == 0 {
		log.Printf("📱 No device tokens found for user %s", userID)
		return nil
	}

	// Prepare notification data
	if data == nil {
		data = make(map[string]string)
	}
	data["click_action"] = "FLUTTER_NOTIFICATION_CLICK"

	// Create multicast message
	message := &messaging.MulticastMessage{
		Notification: &messaging.Notification{
			Title: title,
			Body:  body,
		},
		Data:   data,
		Tokens: tokens,
		Android: &messaging.AndroidConfig{
			Priority: "high",
			Notification: &messaging.AndroidNotification{
				Sound:        "default",
				ChannelID:    "ace_notifications",
				Priority:     messaging.PriorityHigh,
				DefaultSound: true,
			},
		},
		APNS: &messaging.APNSConfig{
			Payload: &messaging.APNSPayload{
				Aps: &messaging.Aps{
					Sound: "default",
					Badge: nil,
				},
			},
		},
	}

	// Send to all devices
	ctx := context.Background()
	response, err := fcmClient.SendEachForMulticast(ctx, message)
	if err != nil {
		return fmt.Errorf("failed to send push notification: %v", err)
	}

	// Log results
	log.Printf("✅ Push notification sent to %d/%d devices for user %s",
		response.SuccessCount, len(tokens), userID)

	// Remove invalid tokens
	if response.FailureCount > 0 {
		for idx, resp := range response.Responses {
			if !resp.Success && resp.Error != nil {
				// Check if token is invalid
				if messaging.IsInvalidArgument(resp.Error) ||
					messaging.IsRegistrationTokenNotRegistered(resp.Error) {
					invalidToken := tokens[idx]
					_, _ = db.Exec(`DELETE FROM device_tokens WHERE device_token = $1`, invalidToken)
					log.Printf("🗑️ Removed invalid device token: %s", invalidToken[:20]+"...")
				}
			}
		}
	}

	return nil
}

// SendPushToMultipleUsers sends push notifications to multiple users
func SendPushToMultipleUsers(db *sql.DB, userIDs []string, title, body string, data map[string]string) {
	for _, userID := range userIDs {
		if err := SendPushNotification(db, userID, title, body, data); err != nil {
			log.Printf("⚠️ Failed to send push to user %s: %v", userID, err)
		}
	}
}

// RegisterDeviceToken registers a device token for push notifications
func RegisterDeviceToken(db *sql.DB, userID, deviceToken, deviceType string) error {
	_, err := db.Exec(`
		INSERT INTO device_tokens (user_id, device_token, device_type, updated_at)
		VALUES ($1, $2, $3, CURRENT_TIMESTAMP)
		ON CONFLICT (user_id, device_token) 
		DO UPDATE SET updated_at = CURRENT_TIMESTAMP
	`, userID, deviceToken, deviceType)

	if err != nil {
		return fmt.Errorf("failed to register device token: %v", err)
	}

	log.Printf("📱 Device token registered for user %s (%s)", userID, deviceType)
	return nil
}

// UnregisterDeviceToken removes a device token
func UnregisterDeviceToken(db *sql.DB, userID, deviceToken string) error {
	_, err := db.Exec(`
		DELETE FROM device_tokens 
		WHERE user_id = $1 AND device_token = $2
	`, userID, deviceToken)

	if err != nil {
		return fmt.Errorf("failed to unregister device token: %v", err)
	}

	log.Printf("🗑️ Device token unregistered for user %s", userID)
	return nil
}

// TestPushNotification sends a test notification (for debugging)
func TestPushNotification(db *sql.DB, userID string) error {
	data := map[string]string{
		"type": "test",
	}
	return SendPushNotification(db, userID, "Test Notification", "This is a test push notification from Ace Mall", data)
}

// Helper to convert data to JSON string for logging
func dataToJSON(data map[string]string) string {
	if data == nil {
		return "{}"
	}
	jsonBytes, _ := json.Marshal(data)
	return string(jsonBytes)
}
