# Performance Testing Guide

## Overview
This directory contains comprehensive performance tests for the Ace Mall Staff Management API.

## Prerequisites
1. Backend server must be running on `http://localhost:8080`
2. Database must be populated with test data
3. Redis must be running for cache tests
4. Test user credentials: `john@acemarket.com` / `password`

## Running Tests

### Run All Performance Tests
```bash
cd backend/tests
go test -v -timeout 30m
```

### Run Specific Test
```bash
# Login performance
go test -v -run TestLoginPerformance

# Dashboard with caching
go test -v -run TestDashboardPerformance

# Notifications endpoint
go test -v -run TestNotificationsPerformance

# Reviews endpoint
go test -v -run TestReviewsPerformance

# Schedule endpoint
go test -v -run TestSchedulePerformance

# Mixed load test (30 seconds)
go test -v -run TestConcurrentMixedLoad
```

## Test Scenarios

### 1. Login Performance Test
- **Concurrent Users**: 50
- **Requests per User**: 10
- **Total Requests**: 500
- **Expected Avg Response**: < 500ms
- **Expected Success Rate**: > 90%

### 2. Dashboard Performance Test (with cache)
- **Concurrent Users**: 100
- **Requests per User**: 20
- **Total Requests**: 2,000
- **Expected Avg Response**: < 200ms (cached)
- **Expected Cache Hit Rate**: > 50%

### 3. Notifications Performance Test
- **Concurrent Users**: 75
- **Requests per User**: 15
- **Total Requests**: 1,125
- **Expected Avg Response**: < 300ms

### 4. Reviews Performance Test
- **Concurrent Users**: 60
- **Requests per User**: 12
- **Total Requests**: 720
- **Expected Avg Response**: < 400ms

### 5. Schedule Performance Test
- **Concurrent Users**: 80
- **Requests per User**: 10
- **Total Requests**: 800
- **Expected Avg Response**: < 350ms

### 6. Mixed Load Test
- **Duration**: 30 seconds
- **Concurrent Users**: 50
- **Endpoints**: Dashboard, Notifications, Reviews, Schedule, Unread Count
- **Expected Success Rate**: > 95%

## Metrics Collected

Each test provides:
- **Total Requests**: Number of requests sent
- **Successful Requests**: Requests with 200 status
- **Failed Requests**: Requests with errors
- **Total Duration**: Time to complete all requests
- **Average Response Time**: Mean response time
- **Min/Max Response Time**: Fastest and slowest requests
- **Requests per Second**: Throughput
- **Cache Hit Rate**: Percentage of cached responses (where applicable)

## Performance Benchmarks

### Acceptable Performance
- Average response time < 500ms
- Error rate < 5%
- Cache hit rate > 50% (for cached endpoints)
- Success rate > 95%

### Good Performance
- Average response time < 200ms
- Error rate < 2%
- Cache hit rate > 70%
- Success rate > 98%

### Excellent Performance
- Average response time < 100ms
- Error rate < 1%
- Cache hit rate > 85%
- Success rate > 99%

## Troubleshooting

### High Response Times
1. Check database query performance
2. Verify Redis is running
3. Check for slow endpoints in metrics
4. Review database indexes

### Low Cache Hit Rate
1. Verify Redis is connected
2. Check cache TTL settings
3. Ensure cache middleware is active
4. Review cache invalidation logic

### High Error Rate
1. Check server logs
2. Verify database connection
3. Check authentication tokens
4. Review error responses

## Monitoring During Tests

While tests are running, monitor:
```bash
# Check metrics
curl http://localhost:8080/api/v1/metrics

# Check alerts
curl http://localhost:8080/api/v1/alerts

# Check health status
curl http://localhost:8080/api/v1/health/status

# Check cache stats
curl http://localhost:8080/api/v1/cache/stats
```

## Continuous Testing

For continuous performance monitoring:
```bash
# Run tests every hour
watch -n 3600 'go test -v -run TestConcurrentMixedLoad'
```

## Results Interpretation

### Sample Output
```
=== Dashboard Stats (with cache) Performance Metrics ===
Total Requests: 2000
Successful: 1998 (99.90%)
Failed: 2 (0.10%)
Total Duration: 8.5s
Avg Response Time: 42ms
Min Response Time: 15ms
Max Response Time: 250ms
Requests/sec: 235.29
Cache Hit Rate: 87.50%
```

This indicates:
- ✅ Excellent success rate (99.90%)
- ✅ Fast average response (42ms)
- ✅ High cache efficiency (87.50%)
- ✅ Good throughput (235 req/s)

## Best Practices

1. **Run tests during off-peak hours** to avoid affecting production
2. **Warm up the cache** before running cache-dependent tests
3. **Monitor server resources** (CPU, memory, disk) during tests
4. **Compare results over time** to detect performance degradation
5. **Test with realistic data volumes** matching production

## Integration with CI/CD

Add to your CI/CD pipeline:
```yaml
# .github/workflows/performance.yml
- name: Run Performance Tests
  run: |
    cd backend/tests
    go test -v -timeout 30m -run TestLoginPerformance
    go test -v -timeout 30m -run TestDashboardPerformance
```
