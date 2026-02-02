package middleware

import (
	"ace-mall-backend/config"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
)

// CacheMiddleware caches GET requests
func CacheMiddleware(duration time.Duration) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Only cache GET requests
		if c.Request.Method != "GET" {
			c.Next()
			return
		}

		// Check if caching is enabled
		cacheEnabled := os.Getenv("CACHE_ENABLED")
		if cacheEnabled != "true" || config.RedisClient == nil {
			c.Next()
			return
		}

		// Generate cache key from URL and user ID
		userID := c.GetString("user_id")
		cacheKey := fmt.Sprintf("cache:%s:%s", userID, c.Request.URL.Path)
		if c.Request.URL.RawQuery != "" {
			cacheKey += ":" + c.Request.URL.RawQuery
		}

		// Try to get from cache
		cachedData, err := config.GetCache(cacheKey)
		if err == nil && cachedData != "" {
			// Cache hit
			var response map[string]interface{}
			if err := json.Unmarshal([]byte(cachedData), &response); err == nil {
				c.Header("X-Cache", "HIT")
				c.JSON(http.StatusOK, response)
				c.Abort()
				return
			}
		}

		// Cache miss - continue to handler
		c.Header("X-Cache", "MISS")

		// Create a custom response writer to capture the response
		blw := &bodyLogWriter{body: []byte{}, ResponseWriter: c.Writer}
		c.Writer = blw

		c.Next()

		// Cache the response if status is 200
		if c.Writer.Status() == http.StatusOK && len(blw.body) > 0 {
			config.SetCache(cacheKey, string(blw.body), duration)
		}
	}
}

// bodyLogWriter captures response body
type bodyLogWriter struct {
	gin.ResponseWriter
	body []byte
}

func (w *bodyLogWriter) Write(b []byte) (int, error) {
	w.body = append(w.body, b...)
	return w.ResponseWriter.Write(b)
}

// InvalidateUserCache invalidates all cache for a specific user
func InvalidateUserCache(userID string) error {
	if config.RedisClient == nil {
		return nil
	}
	pattern := fmt.Sprintf("cache:%s:*", userID)
	return config.InvalidateCachePattern(pattern)
}

// InvalidateCache invalidates specific cache key
func InvalidateCache(key string) error {
	if config.RedisClient == nil {
		return nil
	}
	return config.DeleteCache(key)
}

// GetCacheStats returns cache statistics
func GetCacheStats(c *gin.Context) {
	if config.RedisClient == nil {
		c.JSON(http.StatusOK, gin.H{
			"enabled": false,
			"message": "Redis not available",
		})
		return
	}

	// Get Redis info
	info, err := config.RedisClient.Info(c, "stats").Result()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get cache stats"})
		return
	}

	// Get key count
	var cursor uint64
	var keys []string
	for {
		var scanKeys []string
		var err error
		scanKeys, cursor, err = config.RedisClient.Scan(c, cursor, "cache:*", 100).Result()
		if err != nil {
			break
		}
		keys = append(keys, scanKeys...)
		if cursor == 0 {
			break
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"enabled":    true,
		"total_keys": len(keys),
		"info":       info,
	})
}

// CacheInvalidationMiddleware invalidates cache on data modifications
func CacheInvalidationMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Next()

		// Only invalidate on successful mutations
		if c.Request.Method == "GET" || c.Writer.Status() >= 400 {
			return
		}

		userID := c.GetString("user_id")
		path := c.Request.URL.Path

		// Invalidate based on endpoint
		switch {
		case contains(path, "/profile"):
			InvalidateUserCache(userID)
			InvalidateCache(fmt.Sprintf("user:%s:profile", userID))

		case contains(path, "/reviews"):
			InvalidateUserCache(userID)
			// Also invalidate staff member's cache if reviewing them
			if staffID := c.Param("staff_id"); staffID != "" {
				InvalidateUserCache(staffID)
			}

		case contains(path, "/roster"):
			InvalidateUserCache(userID)
			InvalidateCache("roster:*")

		case contains(path, "/notifications"):
			InvalidateUserCache(userID)

		case contains(path, "/shifts"):
			InvalidateUserCache(userID)
		}
	}
}

func contains(s, substr string) bool {
	return len(s) >= len(substr) && (s == substr || len(s) > len(substr) && containsMiddle(s, substr))
}

func containsMiddle(s, substr string) bool {
	for i := 0; i <= len(s)-len(substr); i++ {
		if s[i:i+len(substr)] == substr {
			return true
		}
	}
	return false
}

// GetDefaultTTL returns the default cache TTL from environment
func GetDefaultTTL() time.Duration {
	ttlStr := os.Getenv("CACHE_DEFAULT_TTL")
	if ttlStr == "" {
		return 15 * time.Minute
	}
	ttl, err := strconv.Atoi(ttlStr)
	if err != nil {
		return 15 * time.Minute
	}
	return time.Duration(ttl) * time.Second
}
