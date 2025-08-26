#!/bin/bash

echo "🔄 Complete Docker Reset and Rebuild"
echo "===================================="

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

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check Docker status
print_status "Checking Docker status..."
if ! docker info >/dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker first."
    exit 1
fi
print_success "Docker is running"

# Complete cleanup
print_status "Performing complete cleanup..."

print_status "Stopping all containers..."
docker-compose down 2>/dev/null || true

print_status "Removing all containers..."
docker-compose down --rmi all --volumes --remove-orphans 2>/dev/null || true

print_status "Removing all images..."
docker rmi $(docker images -q) 2>/dev/null || true

print_status "Removing all volumes..."
docker volume prune -f

print_status "Removing all networks..."
docker network prune -f

print_status "Cleaning Docker system..."
docker system prune -a --volumes -f

print_success "Cleanup completed"

# Check required files
print_status "Checking required files..."
required_files=(
    "docker-compose.yml"
    "backend/go.mod"
    "backend/go.sum"
    "backend/config.env"
    "frontend/package.json"
    "scripts/init-db.sql"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        print_success "✓ $file exists"
    else
        print_error "✗ $file missing"
        exit 1
    fi
done

# Build images step by step
print_status "Building images step by step..."

print_status "Building PostgreSQL image..."
if docker-compose build postgres; then
    print_success "PostgreSQL build successful"
else
    print_error "PostgreSQL build failed"
    exit 1
fi

print_status "Building Backend image..."
if docker-compose build backend; then
    print_success "Backend build successful"
else
    print_error "Backend build failed"
    print_status "Backend build logs:"
    docker-compose build backend 2>&1 | tail -20
    exit 1
fi

print_status "Building Frontend image..."
if docker-compose build frontend; then
    print_success "Frontend build successful"
else
    print_error "Frontend build failed"
    print_status "Frontend build logs:"
    docker-compose build frontend 2>&1 | tail -20
    exit 1
fi

# Start services step by step
print_status "Starting services step by step..."

print_status "Starting PostgreSQL..."
docker-compose up -d postgres

print_status "Waiting for PostgreSQL to be ready..."
sleep 45

# Check PostgreSQL health
print_status "Checking PostgreSQL health..."
retry_count=0
max_retries=10

while [ $retry_count -lt $max_retries ]; do
    if docker-compose exec -T postgres pg_isready -U work_request_user -d work_request_db >/dev/null 2>&1; then
        print_success "PostgreSQL is healthy"
        break
    else
        retry_count=$((retry_count + 1))
        print_warning "PostgreSQL not ready yet (attempt $retry_count/$max_retries)"
        sleep 10
    fi
done

if [ $retry_count -eq $max_retries ]; then
    print_error "PostgreSQL failed to become healthy after $max_retries attempts"
    print_status "PostgreSQL logs:"
    docker-compose logs postgres
    exit 1
fi

print_status "Starting Backend..."
docker-compose up -d backend

print_status "Waiting for Backend to be ready..."
sleep 30

# Check Backend health
print_status "Checking Backend health..."
retry_count=0
max_retries=8

while [ $retry_count -lt $max_retries ]; do
    if docker-compose exec -T backend wget -qO- http://localhost:8080/health >/dev/null 2>&1; then
        print_success "Backend is healthy"
        break
    else
        retry_count=$((retry_count + 1))
        print_warning "Backend not ready yet (attempt $retry_count/$max_retries)"
        sleep 10
    fi
done

if [ $retry_count -eq $max_retries ]; then
    print_error "Backend failed to become healthy after $max_retries attempts"
    print_status "Backend logs:"
    docker-compose logs backend
    exit 1
fi

print_status "Starting Frontend..."
docker-compose up -d frontend

print_status "Waiting for Frontend to be ready..."
sleep 20

# Check Frontend health
print_status "Checking Frontend health..."
retry_count=0
max_retries=6

while [ $retry_count -lt $max_retries ]; do
    if docker-compose exec -T frontend curl -f http://localhost/health >/dev/null 2>&1; then
        print_success "Frontend is healthy"
        break
    else
        retry_count=$((retry_count + 1))
        print_warning "Frontend not ready yet (attempt $retry_count/$max_retries)"
        sleep 10
    fi
done

if [ $retry_count -eq $max_retries ]; then
    print_warning "Frontend health check failed after $max_retries attempts"
    print_status "Frontend logs:"
    docker-compose logs frontend
fi

print_status "Starting Redis..."
docker-compose up -d redis

print_status "Starting Nginx..."
docker-compose up -d nginx

# Final status check
print_status "Final service status:"
docker-compose ps

echo ""
print_success "🎉 All services started successfully!"
echo ""
echo "📱 Access your application:"
echo "   Frontend: http://localhost:3000"
echo "   Backend API: http://localhost:8080"
echo "   PostgreSQL: localhost:5432"
echo "   Redis: localhost:6379"
echo "   Nginx: http://localhost:80"
echo ""
echo "🔑 Default admin credentials: admin/admin123"
echo ""
echo "📋 Useful commands:"
echo "   View logs: docker-compose logs -f"
echo "   Stop services: docker-compose down"
echo "   Restart services: docker-compose restart"
echo "   Check status: docker-compose ps"
echo ""
echo "🔧 Troubleshooting:"
echo "   Check logs: docker-compose logs -f [service_name]"
echo "   Rebuild: docker-compose build --no-cache"
echo "   Complete reset: ./scripts/reset-and-rebuild.sh"
