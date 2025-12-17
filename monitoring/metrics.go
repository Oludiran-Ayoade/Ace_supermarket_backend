package monitoring

import (
	"sync"
	"time"
)

// Metrics holds application performance metrics
type Metrics struct {
	mu                sync.RWMutex
	RequestCount      int64
	ErrorCount        int64
	TotalResponseTime time.Duration
	CacheHits         int64
	CacheMisses       int64
	ActiveUsers       map[string]time.Time
	EndpointStats     map[string]*EndpointMetrics
	StartTime         time.Time
}

// EndpointMetrics holds metrics for specific endpoints
type EndpointMetrics struct {
	Count         int64
	TotalDuration time.Duration
	ErrorCount    int64
	LastAccessed  time.Time
}

var globalMetrics *Metrics

func init() {
	globalMetrics = &Metrics{
		ActiveUsers:   make(map[string]time.Time),
		EndpointStats: make(map[string]*EndpointMetrics),
		StartTime:     time.Now(),
	}
}

// RecordRequest records a request metric
func RecordRequest(endpoint string, duration time.Duration, isError bool) {
	globalMetrics.mu.Lock()
	defer globalMetrics.mu.Unlock()

	globalMetrics.RequestCount++
	globalMetrics.TotalResponseTime += duration

	if isError {
		globalMetrics.ErrorCount++
	}

	// Update endpoint-specific stats
	if _, exists := globalMetrics.EndpointStats[endpoint]; !exists {
		globalMetrics.EndpointStats[endpoint] = &EndpointMetrics{}
	}

	stats := globalMetrics.EndpointStats[endpoint]
	stats.Count++
	stats.TotalDuration += duration
	stats.LastAccessed = time.Now()

	if isError {
		stats.ErrorCount++
	}
}

// RecordCacheHit records a cache hit
func RecordCacheHit() {
	globalMetrics.mu.Lock()
	defer globalMetrics.mu.Unlock()
	globalMetrics.CacheHits++
}

// RecordCacheMiss records a cache miss
func RecordCacheMiss() {
	globalMetrics.mu.Lock()
	defer globalMetrics.mu.Unlock()
	globalMetrics.CacheMisses++
}

// RecordActiveUser records an active user
func RecordActiveUser(userID string) {
	globalMetrics.mu.Lock()
	defer globalMetrics.mu.Unlock()
	globalMetrics.ActiveUsers[userID] = time.Now()
}

// GetMetrics returns current metrics snapshot
func GetMetrics() map[string]interface{} {
	globalMetrics.mu.RLock()
	defer globalMetrics.mu.RUnlock()

	// Clean up inactive users (not seen in last 15 minutes)
	cutoff := time.Now().Add(-15 * time.Minute)
	activeCount := 0
	for userID, lastSeen := range globalMetrics.ActiveUsers {
		if lastSeen.After(cutoff) {
			activeCount++
		} else {
			delete(globalMetrics.ActiveUsers, userID)
		}
	}

	uptime := time.Since(globalMetrics.StartTime)
	avgResponseTime := time.Duration(0)
	if globalMetrics.RequestCount > 0 {
		avgResponseTime = globalMetrics.TotalResponseTime / time.Duration(globalMetrics.RequestCount)
	}

	cacheHitRate := 0.0
	totalCacheRequests := globalMetrics.CacheHits + globalMetrics.CacheMisses
	if totalCacheRequests > 0 {
		cacheHitRate = float64(globalMetrics.CacheHits) / float64(totalCacheRequests) * 100
	}

	errorRate := 0.0
	if globalMetrics.RequestCount > 0 {
		errorRate = float64(globalMetrics.ErrorCount) / float64(globalMetrics.RequestCount) * 100
	}

	requestsPerSecond := 0.0
	if uptime.Seconds() > 0 {
		requestsPerSecond = float64(globalMetrics.RequestCount) / uptime.Seconds()
	}

	// Get top endpoints
	topEndpoints := make([]map[string]interface{}, 0)
	for endpoint, stats := range globalMetrics.EndpointStats {
		avgDuration := time.Duration(0)
		if stats.Count > 0 {
			avgDuration = stats.TotalDuration / time.Duration(stats.Count)
		}

		topEndpoints = append(topEndpoints, map[string]interface{}{
			"endpoint":        endpoint,
			"count":           stats.Count,
			"avg_duration_ms": avgDuration.Milliseconds(),
			"error_count":     stats.ErrorCount,
			"last_accessed":   stats.LastAccessed.Format(time.RFC3339),
		})
	}

	return map[string]interface{}{
		"uptime_seconds":         uptime.Seconds(),
		"total_requests":         globalMetrics.RequestCount,
		"total_errors":           globalMetrics.ErrorCount,
		"error_rate_percent":     errorRate,
		"avg_response_time_ms":   avgResponseTime.Milliseconds(),
		"requests_per_second":    requestsPerSecond,
		"cache_hits":             globalMetrics.CacheHits,
		"cache_misses":           globalMetrics.CacheMisses,
		"cache_hit_rate_percent": cacheHitRate,
		"active_users":           activeCount,
		"top_endpoints":          topEndpoints,
		"timestamp":              time.Now().Format(time.RFC3339),
	}
}

// GetAlerts checks for performance issues and returns alerts
func GetAlerts() []Alert {
	globalMetrics.mu.RLock()
	defer globalMetrics.mu.RUnlock()

	alerts := []Alert{}

	// Check error rate
	if globalMetrics.RequestCount > 100 {
		errorRate := float64(globalMetrics.ErrorCount) / float64(globalMetrics.RequestCount) * 100
		if errorRate > 5.0 {
			alerts = append(alerts, Alert{
				Level:     "critical",
				Message:   "High error rate detected",
				Value:     errorRate,
				Threshold: 5.0,
				Timestamp: time.Now(),
			})
		} else if errorRate > 2.0 {
			alerts = append(alerts, Alert{
				Level:     "warning",
				Message:   "Elevated error rate",
				Value:     errorRate,
				Threshold: 2.0,
				Timestamp: time.Now(),
			})
		}
	}

	// Check cache hit rate
	totalCacheRequests := globalMetrics.CacheHits + globalMetrics.CacheMisses
	if totalCacheRequests > 100 {
		cacheHitRate := float64(globalMetrics.CacheHits) / float64(totalCacheRequests) * 100
		if cacheHitRate < 50.0 {
			alerts = append(alerts, Alert{
				Level:     "warning",
				Message:   "Low cache hit rate",
				Value:     cacheHitRate,
				Threshold: 50.0,
				Timestamp: time.Now(),
			})
		}
	}

	// Check average response time
	if globalMetrics.RequestCount > 0 {
		avgResponseTime := globalMetrics.TotalResponseTime / time.Duration(globalMetrics.RequestCount)
		if avgResponseTime > 500*time.Millisecond {
			alerts = append(alerts, Alert{
				Level:     "critical",
				Message:   "High average response time",
				Value:     float64(avgResponseTime.Milliseconds()),
				Threshold: 500.0,
				Timestamp: time.Now(),
			})
		} else if avgResponseTime > 300*time.Millisecond {
			alerts = append(alerts, Alert{
				Level:     "warning",
				Message:   "Elevated average response time",
				Value:     float64(avgResponseTime.Milliseconds()),
				Threshold: 300.0,
				Timestamp: time.Now(),
			})
		}
	}

	// Check for slow endpoints
	for endpoint, stats := range globalMetrics.EndpointStats {
		if stats.Count > 10 {
			avgDuration := stats.TotalDuration / time.Duration(stats.Count)
			if avgDuration > 1*time.Second {
				alerts = append(alerts, Alert{
					Level:     "warning",
					Message:   "Slow endpoint detected: " + endpoint,
					Value:     float64(avgDuration.Milliseconds()),
					Threshold: 1000.0,
					Timestamp: time.Now(),
				})
			}
		}
	}

	return alerts
}

// Alert represents a performance alert
type Alert struct {
	Level     string    `json:"level"` // "info", "warning", "critical"
	Message   string    `json:"message"`
	Value     float64   `json:"value"`
	Threshold float64   `json:"threshold"`
	Timestamp time.Time `json:"timestamp"`
}

// ResetMetrics resets all metrics (useful for testing)
func ResetMetrics() {
	globalMetrics.mu.Lock()
	defer globalMetrics.mu.Unlock()

	globalMetrics.RequestCount = 0
	globalMetrics.ErrorCount = 0
	globalMetrics.TotalResponseTime = 0
	globalMetrics.CacheHits = 0
	globalMetrics.CacheMisses = 0
	globalMetrics.ActiveUsers = make(map[string]time.Time)
	globalMetrics.EndpointStats = make(map[string]*EndpointMetrics)
	globalMetrics.StartTime = time.Now()
}
