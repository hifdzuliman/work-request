#!/bin/bash

echo "🔍 Testing Health Endpoints"
echo "============================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Test Backend Health
print_status "Testing Backend Health..."
if curl -f -X GET "http://178.128.54.249:8080/health" 2>/dev/null; then
    print_success "Backend health endpoint is working"
else
    print_error "Backend health endpoint failed"
fi

echo ""

# Test Frontend Health
print_status "Testing Frontend Health..."
if curl -f -X GET "http://178.128.54.249:3000/health" 2>/dev/null; then
    print_success "Frontend health endpoint is working"
else
    print_error "Frontend health endpoint failed"
fi

echo ""

# Test Nginx Health
print_status "Testing Nginx Health..."
if curl -f -X GET "http://178.128.54.249/health" 2>/dev/null; then
    print_success "Nginx health endpoint is working"
else
    print_error "Nginx health endpoint failed"
fi

echo ""

# Test PostgreSQL Health
print_status "Testing PostgreSQL Health..."
if docker-compose exec -T postgres pg_isready -U work_request_user -d work_request_db >/dev/null 2>&1; then
    print_success "PostgreSQL is healthy"
else
    print_error "PostgreSQL health check failed"
fi

echo ""

# Test Redis Health
print_status "Testing Redis Health..."
if docker-compose exec -T redis redis-cli ping >/dev/null 2>&1; then
    print_success "Redis is healthy"
else
    print_error "Redis health check failed"
fi

echo ""
echo "🎯 Health Check Summary:"
echo "========================"
echo "Backend:   http://178.128.54.249:8080/health"
echo "Frontend:  http://178.128.54.249:3000/health"
echo "Nginx:     http://178.128.54.249/health"
echo "PostgreSQL: Container health check"
echo "Redis:     Container health check"
