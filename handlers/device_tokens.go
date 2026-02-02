package handlers

import (
	"ace-mall-backend/utils"
	"database/sql"
	"net/http"

	"github.com/gin-gonic/gin"
)

// RegisterDeviceTokenRequest represents the request body for device token registration
type RegisterDeviceTokenRequest struct {
	DeviceToken string `json:"device_token" binding:"required"`
	DeviceType  string `json:"device_type" binding:"required,oneof=ios android web"`
}

// RegisterDeviceToken registers a device token for push notifications
func RegisterDeviceToken(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	userID := c.GetString("user_id")

	var req RegisterDeviceTokenRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err := utils.RegisterDeviceToken(db, userID, req.DeviceToken, req.DeviceType)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to register device token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Device token registered successfully",
	})
}

// UnregisterDeviceToken removes a device token
func UnregisterDeviceToken(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	userID := c.GetString("user_id")

	var req struct {
		DeviceToken string `json:"device_token" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err := utils.UnregisterDeviceToken(db, userID, req.DeviceToken)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to unregister device token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Device token unregistered successfully",
	})
}

// TestPushNotification sends a test push notification (for debugging)
func TestPushNotification(c *gin.Context) {
	db := c.MustGet("db").(*sql.DB)
	userID := c.GetString("user_id")

	err := utils.TestPushNotification(db, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to send test notification"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Test notification sent successfully",
	})
}
