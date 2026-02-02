# Monitoring & Alerts System

## Overview
The Ace Mall Staff Management API includes a comprehensive monitoring and alerting system that tracks performance metrics, cache efficiency, and system health in real-time.

## Monitoring Endpoints

### 1. Metrics Endpoint
**GET** `/api/v1/metrics`

Returns comprehensive application metrics:

```json
{
  "uptime_seconds": 3600,
  "total_requests": 15420,
  "total_errors": 23,
  "error_rate_percent": 0.15,
  "avg_response_time_ms": 45,
  "requests_per_second": 4.28,
  "cache_hits": 8234,
  "cache_misses": 2156,
  "cache_hit_rate_percent": 79.25,
  "active_users": 42,
  "top_endpoints": [
    {
      "endpoint": "/api/v1/dashboard/stats",
      "count": 3245,
      "avg_duration_ms": 35,
      "error_count": 2,
      "last_accessed": "2025-12-02T15:30:00Z"
    }
  ],
  "timestamp": "2025-12-02T15:30:00Z"
}
```

### 2. Alerts Endpoint
**GET** `/api/v1/alerts`

Returns active performance alerts:

```json
{
  "alerts": [
    {
      "level": "warning",
      "message": "Elevated average response time",
      "value": 350.5,
      "threshold": 300.0,
      "timestamp": "2025-12-02T15:30:00Z"
    }
  ],
  "count": 1
}
```

### 3. Health Status Endpoint
**GET** `/api/v1/health/status`

Returns overall system health:

```json
{
  "status": "healthy",
  "metrics": { /* full metrics */ },
  "alerts": [ /* active alerts */ ]
}
```

**Status Values:**
- `healthy` - No critical issues
- `degraded` - Warning alerts present
- `critical` - Critical alerts present

### 4. Cache Stats Endpoint
**GET** `/api/v1/cache/stats`

Returns Redis cache statistics:

```json
{
  "enabled": true,
  "total_keys": 1245,
  "info": "# Stats\ntotal_connections_received:5234..."
}
```

## Alert Levels

### Critical Alerts
Triggered when:
- Error rate > 5%
- Average response time > 500ms
- System requires immediate attention

### Warning Alerts
Triggered when:
- Error rate > 2%
- Average response time > 300ms
- Cache hit rate < 50%
- Endpoint response time > 1000ms

### Info Alerts
General information and recommendations

## Metrics Tracked

### Request Metrics
- **Total Requests**: Cumulative request count since startup
- **Error Count**: Number of failed requests (4xx, 5xx)
- **Error Rate**: Percentage of failed requests
- **Requests per Second**: Current throughput

### Response Time Metrics
- **Average Response Time**: Mean response time across all requests
- **Per-Endpoint Metrics**: Individual endpoint performance
- **Min/Max Response Times**: Performance bounds

### Cache Metrics
- **Cache Hits**: Number of requests served from cache
- **Cache Misses**: Number of requests requiring database query
- **Cache Hit Rate**: Percentage of requests served from cache
- **Total Cache Keys**: Number of cached items

### User Metrics
- **Active Users**: Users active in last 15 minutes
- **User Activity**: Tracks user engagement

## Monitoring Best Practices

### 1. Regular Health Checks
```bash
# Check every 5 minutes
*/5 * * * * curl -s http://localhost:8080/api/v1/health/status | jq .status
```

### 2. Alert Monitoring
```bash
# Check for critical alerts
curl -s http://localhost:8080/api/v1/alerts | jq '.alerts[] | select(.level=="critical")'
```

### 3. Performance Tracking
```bash
# Monitor average response time
curl -s http://localhost:8080/api/v1/metrics | jq .avg_response_time_ms
```

### 4. Cache Efficiency
```bash
# Check cache hit rate
curl -s http://localhost:8080/api/v1/metrics | jq .cache_hit_rate_percent
```

## Integration with External Tools

### Prometheus Integration
Add to `prometheus.yml`:
```yaml
scrape_configs:
  - job_name: 'ace-mall-api'
    metrics_path: '/api/v1/metrics'
    static_configs:
      - targets: ['localhost:8080']
```

### Grafana Dashboard
Create dashboard with panels for:
- Request rate over time
- Error rate trend
- Average response time
- Cache hit rate
- Active users

### Alertmanager Rules
```yaml
groups:
  - name: ace_mall_alerts
    rules:
      - alert: HighErrorRate
        expr: error_rate_percent > 5
        for: 5m
        annotations:
          summary: "High error rate detected"
          
      - alert: SlowResponseTime
        expr: avg_response_time_ms > 500
        for: 5m
        annotations:
          summary: "Slow response times"
```

## Performance Thresholds

### Response Time Targets
- **Login**: < 500ms
- **Dashboard**: < 200ms (with cache)
- **Notifications**: < 300ms
- **Reviews**: < 400ms
- **Schedule**: < 350ms

### Cache Targets
- **Hit Rate**: > 70%
- **TTL Settings**:
  - Notifications: 5 minutes
  - Schedule: 15 minutes
  - Reviews: 30 minutes
  - Dashboard: 10 minutes

### Error Rate Targets
- **Normal Operation**: < 1%
- **Acceptable**: < 2%
- **Warning**: 2-5%
- **Critical**: > 5%

## Troubleshooting Guide

### High Error Rate
1. Check application logs
2. Verify database connectivity
3. Check authentication issues
4. Review recent deployments

### Slow Response Times
1. Check database query performance
2. Verify Redis is running
3. Review slow endpoint logs
4. Check server resources (CPU, memory)

### Low Cache Hit Rate
1. Verify Redis connection
2. Check cache TTL settings
3. Review cache invalidation frequency
4. Monitor cache key patterns

### High Memory Usage
1. Check Redis memory usage
2. Review cache key count
3. Adjust TTL values
4. Implement cache size limits

## Monitoring Dashboard Example

```bash
#!/bin/bash
# monitoring-dashboard.sh

echo "=== Ace Mall API Monitoring Dashboard ==="
echo ""

# Health Status
STATUS=$(curl -s http://localhost:8080/api/v1/health/status | jq -r .status)
echo "Health Status: $STATUS"
echo ""

# Metrics
METRICS=$(curl -s http://localhost:8080/api/v1/metrics)
echo "Uptime: $(echo $METRICS | jq -r .uptime_seconds)s"
echo "Total Requests: $(echo $METRICS | jq -r .total_requests)"
echo "Error Rate: $(echo $METRICS | jq -r .error_rate_percent)%"
echo "Avg Response: $(echo $METRICS | jq -r .avg_response_time_ms)ms"
echo "Cache Hit Rate: $(echo $METRICS | jq -r .cache_hit_rate_percent)%"
echo "Active Users: $(echo $METRICS | jq -r .active_users)"
echo ""

# Alerts
ALERT_COUNT=$(curl -s http://localhost:8080/api/v1/alerts | jq -r .count)
echo "Active Alerts: $ALERT_COUNT"

if [ "$ALERT_COUNT" -gt 0 ]; then
    echo ""
    echo "=== Active Alerts ==="
    curl -s http://localhost:8080/api/v1/alerts | jq -r '.alerts[] | "\(.level | ascii_upcase): \(.message) (value: \(.value), threshold: \(.threshold))"'
fi
```

## Automated Alerting

### Email Alerts
```bash
#!/bin/bash
# check-alerts.sh

ALERTS=$(curl -s http://localhost:8080/api/v1/alerts)
CRITICAL_COUNT=$(echo $ALERTS | jq '[.alerts[] | select(.level=="critical")] | length')

if [ "$CRITICAL_COUNT" -gt 0 ]; then
    echo "Critical alerts detected!" | mail -s "Ace Mall API Alert" admin@acemall.com
fi
```

### Slack Integration
```bash
#!/bin/bash
# slack-alert.sh

WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
ALERTS=$(curl -s http://localhost:8080/api/v1/alerts | jq -r '.alerts[] | select(.level=="critical") | .message')

if [ ! -z "$ALERTS" ]; then
    curl -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"🚨 Critical Alert: $ALERTS\"}" \
        $WEBHOOK_URL
fi
```

## Metrics Retention

- **In-Memory Metrics**: Reset on server restart
- **Historical Data**: Export to time-series database
- **Recommended**: Use Prometheus + Grafana for long-term storage

## Security Considerations

1. **Protect monitoring endpoints** in production
2. **Implement authentication** for sensitive metrics
3. **Rate limit** monitoring endpoints
4. **Sanitize** error messages in alerts
5. **Encrypt** alert notifications

## Next Steps

1. Set up automated monitoring checks
2. Configure alert notifications
3. Create Grafana dashboards
4. Implement log aggregation
5. Set up distributed tracing
