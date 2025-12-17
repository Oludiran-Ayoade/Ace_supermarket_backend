package monitoring

import (
	"time"

	"github.com/gin-gonic/gin"
)

// MetricsMiddleware records request metrics
func MetricsMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()
		path := c.Request.URL.Path

		// Record active user
		if userID := c.GetString("user_id"); userID != "" {
			RecordActiveUser(userID)
		}

		// Process request
		c.Next()

		// Record metrics
		duration := time.Since(start)
		isError := c.Writer.Status() >= 400

		RecordRequest(path, duration, isError)

		// Record cache metrics
		if cacheHeader := c.Writer.Header().Get("X-Cache"); cacheHeader != "" {
			if cacheHeader == "HIT" {
				RecordCacheHit()
			} else if cacheHeader == "MISS" {
				RecordCacheMiss()
			}
		}
	}
}
