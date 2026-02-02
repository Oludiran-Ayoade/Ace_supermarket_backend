package handlers

import (
	"ace-mall-backend/monitoring"
	"net/http"

	"github.com/gin-gonic/gin"
)

// GetMetrics returns current application metrics
func GetMetrics(c *gin.Context) {
	metrics := monitoring.GetMetrics()
	c.JSON(http.StatusOK, metrics)
}

// GetAlerts returns current performance alerts
func GetAlerts(c *gin.Context) {
	alerts := monitoring.GetAlerts()

	c.JSON(http.StatusOK, gin.H{
		"alerts": alerts,
		"count":  len(alerts),
	})
}

// GetHealthStatus returns comprehensive health status
func GetHealthStatus(c *gin.Context) {
	metrics := monitoring.GetMetrics()
	alerts := monitoring.GetAlerts()

	// Determine overall health
	health := "healthy"
	for _, alert := range alerts {
		if alert.Level == "critical" {
			health = "critical"
			break
		} else if alert.Level == "warning" && health == "healthy" {
			health = "degraded"
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  health,
		"metrics": metrics,
		"alerts":  alerts,
	})
}
