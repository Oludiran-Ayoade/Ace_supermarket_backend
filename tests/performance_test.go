package tests

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"sync"
	"testing"
	"time"
)

const (
	baseURL = "http://localhost:8080"
)

// PerformanceMetrics holds test results
type PerformanceMetrics struct {
	TotalRequests   int
	SuccessfulReqs  int
	FailedReqs      int
	TotalDuration   time.Duration
	AvgResponseTime time.Duration
	MinResponseTime time.Duration
	MaxResponseTime time.Duration
	RequestsPerSec  float64
	CacheHitRate    float64
}

// TestLogin performs load testing on login endpoint
func TestLoginPerformance(t *testing.T) {
	concurrentUsers := 50
	requestsPerUser := 10

	metrics := loadTest(concurrentUsers, requestsPerUser, func() (*http.Response, time.Duration, error) {
		start := time.Now()

		payload := map[string]string{
			"email":    "john@acemarket.com",
			"password": "password",
		}

		jsonData, _ := json.Marshal(payload)
		resp, err := http.Post(baseURL+"/api/v1/auth/login", "application/json", bytes.NewBuffer(jsonData))

		duration := time.Since(start)
		return resp, duration, err
	})

	printMetrics("Login Endpoint", metrics)

	// Assertions
	if metrics.AvgResponseTime > 500*time.Millisecond {
		t.Errorf("Average response time too high: %v", metrics.AvgResponseTime)
	}

	if metrics.SuccessfulReqs < (concurrentUsers*requestsPerUser)*90/100 {
		t.Errorf("Success rate too low: %d/%d", metrics.SuccessfulReqs, metrics.TotalRequests)
	}
}

// TestDashboardPerformance tests dashboard endpoint with caching
func TestDashboardPerformance(t *testing.T) {
	token := getAuthToken(t)
	concurrentUsers := 100
	requestsPerUser := 20

	metrics := loadTest(concurrentUsers, requestsPerUser, func() (*http.Response, time.Duration, error) {
		start := time.Now()

		req, _ := http.NewRequest("GET", baseURL+"/api/v1/dashboard/stats", nil)
		req.Header.Set("Authorization", "Bearer "+token)

		client := &http.Client{}
		resp, err := client.Do(req)

		duration := time.Since(start)
		return resp, duration, err
	})

	printMetrics("Dashboard Stats (with cache)", metrics)

	// With caching, should be very fast
	if metrics.AvgResponseTime > 200*time.Millisecond {
		t.Errorf("Average response time too high with cache: %v", metrics.AvgResponseTime)
	}

	// Cache hit rate should be high after first request
	if metrics.CacheHitRate < 0.5 {
		t.Logf("Warning: Cache hit rate is low: %.2f%%", metrics.CacheHitRate*100)
	}
}

// TestNotificationsPerformance tests notifications endpoint
func TestNotificationsPerformance(t *testing.T) {
	token := getAuthToken(t)
	concurrentUsers := 75
	requestsPerUser := 15

	metrics := loadTest(concurrentUsers, requestsPerUser, func() (*http.Response, time.Duration, error) {
		start := time.Now()

		req, _ := http.NewRequest("GET", baseURL+"/api/v1/notifications", nil)
		req.Header.Set("Authorization", "Bearer "+token)

		client := &http.Client{}
		resp, err := client.Do(req)

		duration := time.Since(start)
		return resp, duration, err
	})

	printMetrics("Notifications Endpoint", metrics)

	if metrics.AvgResponseTime > 300*time.Millisecond {
		t.Errorf("Average response time too high: %v", metrics.AvgResponseTime)
	}
}

// TestReviewsPerformance tests reviews endpoint
func TestReviewsPerformance(t *testing.T) {
	token := getAuthToken(t)
	concurrentUsers := 60
	requestsPerUser := 12

	metrics := loadTest(concurrentUsers, requestsPerUser, func() (*http.Response, time.Duration, error) {
		start := time.Now()

		req, _ := http.NewRequest("GET", baseURL+"/api/v1/reviews/my-reviews", nil)
		req.Header.Set("Authorization", "Bearer "+token)

		client := &http.Client{}
		resp, err := client.Do(req)

		duration := time.Since(start)
		return resp, duration, err
	})

	printMetrics("My Reviews Endpoint", metrics)

	if metrics.AvgResponseTime > 400*time.Millisecond {
		t.Errorf("Average response time too high: %v", metrics.AvgResponseTime)
	}
}

// TestSchedulePerformance tests schedule endpoint
func TestSchedulePerformance(t *testing.T) {
	token := getAuthToken(t)
	concurrentUsers := 80
	requestsPerUser := 10

	metrics := loadTest(concurrentUsers, requestsPerUser, func() (*http.Response, time.Duration, error) {
		start := time.Now()

		req, _ := http.NewRequest("GET", baseURL+"/api/v1/roster/my-assignments", nil)
		req.Header.Set("Authorization", "Bearer "+token)

		client := &http.Client{}
		resp, err := client.Do(req)

		duration := time.Since(start)
		return resp, duration, err
	})

	printMetrics("My Schedule Endpoint", metrics)

	if metrics.AvgResponseTime > 350*time.Millisecond {
		t.Errorf("Average response time too high: %v", metrics.AvgResponseTime)
	}
}

// TestConcurrentMixedLoad simulates real-world mixed traffic
func TestConcurrentMixedLoad(t *testing.T) {
	token := getAuthToken(t)
	duration := 30 * time.Second
	concurrentUsers := 50

	endpoints := []string{
		"/api/v1/dashboard/stats",
		"/api/v1/notifications",
		"/api/v1/reviews/my-reviews",
		"/api/v1/roster/my-assignments",
		"/api/v1/notifications/unread-count",
	}

	var wg sync.WaitGroup
	startTime := time.Now()
	totalRequests := 0
	successfulRequests := 0
	var mu sync.Mutex

	for i := 0; i < concurrentUsers; i++ {
		wg.Add(1)
		go func(userID int) {
			defer wg.Done()

			for time.Since(startTime) < duration {
				endpoint := endpoints[userID%len(endpoints)]

				req, _ := http.NewRequest("GET", baseURL+endpoint, nil)
				req.Header.Set("Authorization", "Bearer "+token)

				client := &http.Client{Timeout: 5 * time.Second}
				resp, err := client.Do(req)

				mu.Lock()
				totalRequests++
				if err == nil && resp.StatusCode == 200 {
					successfulRequests++
				}
				if resp != nil {
					resp.Body.Close()
				}
				mu.Unlock()

				time.Sleep(100 * time.Millisecond) // Simulate user think time
			}
		}(i)
	}

	wg.Wait()

	fmt.Printf("\n=== Mixed Load Test Results ===\n")
	fmt.Printf("Duration: %v\n", duration)
	fmt.Printf("Concurrent Users: %d\n", concurrentUsers)
	fmt.Printf("Total Requests: %d\n", totalRequests)
	fmt.Printf("Successful: %d\n", successfulRequests)
	fmt.Printf("Failed: %d\n", totalRequests-successfulRequests)
	fmt.Printf("Success Rate: %.2f%%\n", float64(successfulRequests)/float64(totalRequests)*100)
	fmt.Printf("Requests/sec: %.2f\n", float64(totalRequests)/duration.Seconds())

	if float64(successfulRequests)/float64(totalRequests) < 0.95 {
		t.Errorf("Success rate too low: %.2f%%", float64(successfulRequests)/float64(totalRequests)*100)
	}
}

// Helper function to perform load test
func loadTest(concurrentUsers, requestsPerUser int, requestFunc func() (*http.Response, time.Duration, error)) PerformanceMetrics {
	var wg sync.WaitGroup
	var mu sync.Mutex

	metrics := PerformanceMetrics{
		MinResponseTime: time.Hour, // Initialize with high value
	}

	cacheHits := 0
	cacheMisses := 0

	startTime := time.Now()

	for i := 0; i < concurrentUsers; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()

			for j := 0; j < requestsPerUser; j++ {
				resp, duration, err := requestFunc()

				mu.Lock()
				metrics.TotalRequests++

				if err == nil && resp != nil {
					if resp.StatusCode == 200 {
						metrics.SuccessfulReqs++
					} else {
						metrics.FailedReqs++
					}

					// Check cache header
					if resp.Header.Get("X-Cache") == "HIT" {
						cacheHits++
					} else if resp.Header.Get("X-Cache") == "MISS" {
						cacheMisses++
					}

					resp.Body.Close()
				} else {
					metrics.FailedReqs++
				}

				if duration < metrics.MinResponseTime {
					metrics.MinResponseTime = duration
				}
				if duration > metrics.MaxResponseTime {
					metrics.MaxResponseTime = duration
				}

				mu.Unlock()
			}
		}()
	}

	wg.Wait()

	metrics.TotalDuration = time.Since(startTime)
	metrics.AvgResponseTime = metrics.TotalDuration / time.Duration(metrics.TotalRequests)
	metrics.RequestsPerSec = float64(metrics.TotalRequests) / metrics.TotalDuration.Seconds()

	if cacheHits+cacheMisses > 0 {
		metrics.CacheHitRate = float64(cacheHits) / float64(cacheHits+cacheMisses)
	}

	return metrics
}

// Helper function to get auth token
func getAuthToken(t *testing.T) string {
	payload := map[string]string{
		"email":    "john@acemarket.com",
		"password": "password",
	}

	jsonData, _ := json.Marshal(payload)
	resp, err := http.Post(baseURL+"/api/v1/auth/login", "application/json", bytes.NewBuffer(jsonData))

	if err != nil {
		t.Fatalf("Failed to login: %v", err)
	}
	defer resp.Body.Close()

	var result map[string]interface{}
	json.NewDecoder(resp.Body).Decode(&result)

	token, ok := result["token"].(string)
	if !ok {
		t.Fatalf("Failed to get token from login response")
	}

	return token
}

// Helper function to print metrics
func printMetrics(testName string, m PerformanceMetrics) {
	fmt.Printf("\n=== %s Performance Metrics ===\n", testName)
	fmt.Printf("Total Requests: %d\n", m.TotalRequests)
	fmt.Printf("Successful: %d (%.2f%%)\n", m.SuccessfulReqs, float64(m.SuccessfulReqs)/float64(m.TotalRequests)*100)
	fmt.Printf("Failed: %d (%.2f%%)\n", m.FailedReqs, float64(m.FailedReqs)/float64(m.TotalRequests)*100)
	fmt.Printf("Total Duration: %v\n", m.TotalDuration)
	fmt.Printf("Avg Response Time: %v\n", m.AvgResponseTime)
	fmt.Printf("Min Response Time: %v\n", m.MinResponseTime)
	fmt.Printf("Max Response Time: %v\n", m.MaxResponseTime)
	fmt.Printf("Requests/sec: %.2f\n", m.RequestsPerSec)
	if m.CacheHitRate > 0 {
		fmt.Printf("Cache Hit Rate: %.2f%%\n", m.CacheHitRate*100)
	}
	fmt.Println("=====================================")
}
