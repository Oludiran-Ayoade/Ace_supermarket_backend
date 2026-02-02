#!/bin/bash

# Monitoring Test Script for Ace Mall API
# This script tests all monitoring endpoints and displays results

BASE_URL="http://localhost:8080"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "======================================"
echo "  Ace Mall API Monitoring Test"
echo "======================================"
echo ""

# Check if server is running
echo -n "Checking if server is running... "
if curl -s "${BASE_URL}/health" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Server is running${NC}"
else
    echo -e "${RED}✗ Server is not running${NC}"
    echo "Please start the server with: go run main.go"
    exit 1
fi
echo ""

# Test Health Endpoint
echo "1. Health Check"
echo "   GET /health"
HEALTH=$(curl -s "${BASE_URL}/health")
STATUS=$(echo $HEALTH | jq -r .status)
echo "   Status: ${STATUS}"
echo ""

# Test Metrics Endpoint
echo "2. Metrics"
echo "   GET /api/v1/metrics"
METRICS=$(curl -s "${BASE_URL}/api/v1/metrics")
if [ $? -eq 0 ]; then
    echo -e "   ${GREEN}✓ Metrics endpoint working${NC}"
    echo "   Uptime: $(echo $METRICS | jq -r .uptime_seconds)s"
    echo "   Total Requests: $(echo $METRICS | jq -r .total_requests)"
    echo "   Error Rate: $(echo $METRICS | jq -r .error_rate_percent)%"
    echo "   Avg Response: $(echo $METRICS | jq -r .avg_response_time_ms)ms"
    echo "   Cache Hit Rate: $(echo $METRICS | jq -r .cache_hit_rate_percent)%"
    echo "   Active Users: $(echo $METRICS | jq -r .active_users)"
else
    echo -e "   ${RED}✗ Metrics endpoint failed${NC}"
fi
echo ""

# Test Alerts Endpoint
echo "3. Alerts"
echo "   GET /api/v1/alerts"
ALERTS=$(curl -s "${BASE_URL}/api/v1/alerts")
if [ $? -eq 0 ]; then
    ALERT_COUNT=$(echo $ALERTS | jq -r .count)
    echo -e "   ${GREEN}✓ Alerts endpoint working${NC}"
    echo "   Active Alerts: ${ALERT_COUNT}"
    
    if [ "$ALERT_COUNT" -gt 0 ]; then
        echo ""
        echo "   Alert Details:"
        echo $ALERTS | jq -r '.alerts[] | "   - [\(.level | ascii_upcase)] \(.message) (value: \(.value), threshold: \(.threshold))"'
    fi
else
    echo -e "   ${RED}✗ Alerts endpoint failed${NC}"
fi
echo ""

# Test Health Status Endpoint
echo "4. Health Status"
echo "   GET /api/v1/health/status"
HEALTH_STATUS=$(curl -s "${BASE_URL}/api/v1/health/status")
if [ $? -eq 0 ]; then
    OVERALL_STATUS=$(echo $HEALTH_STATUS | jq -r .status)
    echo -e "   ${GREEN}✓ Health status endpoint working${NC}"
    
    case $OVERALL_STATUS in
        "healthy")
            echo -e "   Overall Status: ${GREEN}${OVERALL_STATUS}${NC}"
            ;;
        "degraded")
            echo -e "   Overall Status: ${YELLOW}${OVERALL_STATUS}${NC}"
            ;;
        "critical")
            echo -e "   Overall Status: ${RED}${OVERALL_STATUS}${NC}"
            ;;
        *)
            echo "   Overall Status: ${OVERALL_STATUS}"
            ;;
    esac
else
    echo -e "   ${RED}✗ Health status endpoint failed${NC}"
fi
echo ""

# Test Cache Stats Endpoint
echo "5. Cache Statistics"
echo "   GET /api/v1/cache/stats"
CACHE_STATS=$(curl -s "${BASE_URL}/api/v1/cache/stats")
if [ $? -eq 0 ]; then
    CACHE_ENABLED=$(echo $CACHE_STATS | jq -r .enabled)
    echo -e "   ${GREEN}✓ Cache stats endpoint working${NC}"
    echo "   Cache Enabled: ${CACHE_ENABLED}"
    
    if [ "$CACHE_ENABLED" = "true" ]; then
        TOTAL_KEYS=$(echo $CACHE_STATS | jq -r .total_keys)
        echo "   Total Keys: ${TOTAL_KEYS}"
    else
        echo -e "   ${YELLOW}⚠ Redis not available - caching disabled${NC}"
    fi
else
    echo -e "   ${RED}✗ Cache stats endpoint failed${NC}"
fi
echo ""

# Summary
echo "======================================"
echo "  Test Summary"
echo "======================================"
echo ""

# Check Redis
if [ "$CACHE_ENABLED" = "true" ]; then
    echo -e "${GREEN}✓ Redis caching is enabled${NC}"
else
    echo -e "${YELLOW}⚠ Redis caching is disabled${NC}"
    echo "  To enable: Install and start Redis server"
fi

# Check alerts
if [ "$ALERT_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✓ No active alerts${NC}"
else
    echo -e "${YELLOW}⚠ ${ALERT_COUNT} active alert(s)${NC}"
fi

# Check overall health
case $OVERALL_STATUS in
    "healthy")
        echo -e "${GREEN}✓ System is healthy${NC}"
        ;;
    "degraded")
        echo -e "${YELLOW}⚠ System is degraded${NC}"
        ;;
    "critical")
        echo -e "${RED}✗ System is critical${NC}"
        ;;
esac

echo ""
echo "======================================"
echo ""
echo "For continuous monitoring, run:"
echo "  watch -n 10 './scripts/test-monitoring.sh'"
echo ""
