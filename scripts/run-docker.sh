#!/bin/bash

# Comprehensive Docker runner script for Work Request Management System
set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check file exists
file_exists() {
    [ -f "$1" ]
}

# Function to check directory exists
dir_exists() {
    [ -d "$1" ]
}

# Function to wait for service to be ready
wait_for_service() {
    local service=$1
    local max_attempts=30
    local attempt=1
    
    print_status "Waiting for $service to be ready..."
    
    while [ $attempt -le $max_attempts ]; do
        if docker-compose exec -T "$service" sh -c "exit 0" 2>/dev/null; then
            print_success "$service is ready!"
            return 0
        fi
        
        print_status "Attempt $attempt/$max_attempts - $service not ready yet..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    print_error "$service failed to start within expected time"
    return 1
}

# Function to check service health
check_service_health() {
    local service=$1
    local health_check=$2
    
    print_status "Checking health of $service..."
    
    if docker-compose exec -T "$service" sh -c "$health_check" >/dev/null 2>&1; then
        print_success "$service is healthy"
        return 0
    else
        print_error "$service health check failed"
        return 1
    fi
}

# Main execution
main() {
    echo "🐳 Work Request Management System - Docker Runner"
    echo "================================================"
    
    # Check prerequisites
    print_status "Checking prerequisites..."
    
    if ! command_exists docker; then
        print_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    if ! command_exists docker-compose; then
        print_error "Docker Compose is not installed or not in PATH"
        exit 1
    fi
    
    # Check if Docker daemon is running
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker daemon is not running. Please start Docker first."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
    
    # Check required files
    print_status "Checking required files..."
    
    local required_files=(
        "docker-compose.yml"
        "backend/go.mod"
        "backend/go.sum"
        "frontend/package.json"
        "scripts/init-db.sql"
    )
    
    for file in "${required_files[@]}"; do
        if ! file_exists "$file"; then
            print_error "Required file not found: $file"
            exit 1
        fi
    done
    
    print_success "All required files found"
    
    # Check Go modules
    print_status "Verifying Go modules..."
    cd backend
    
    if ! file_exists "go.sum"; then
        print_warning "go.sum not found, regenerating..."
        go clean -modcache
        go mod download
        go mod verify
        go mod tidy
    else
        go mod verify
        go mod tidy
    fi
    
    cd ..
    print_success "Go modules verified"
    
    # Stop existing services
    print_status "Stopping existing services..."
    docker-compose down 2>/dev/null || true
    
    # Clean up Docker system
    print_status "Cleaning up Docker system..."
    docker system prune -f
    
    # Build images
    print_status "Building Docker images..."
    docker-compose build --no-cache
    
    # Start services
    print_status "Starting services..."
    docker-compose up -d
    
    # Wait for services to be ready
    print_status "Waiting for services to be ready..."
    sleep 5
    
    # Check service status
    print_status "Checking service status..."
    docker-compose ps
    
    # Wait for PostgreSQL
    if wait_for_service "postgres"; then
        # Check PostgreSQL health
        check_service_health "postgres" "pg_isready -U work_request_user -d work_request_db"
    fi
    
    # Wait for backend
    if wait_for_service "backend"; then
        # Check backend health
        check_service_health "backend" "wget -qO- http://localhost:8080/health"
    fi
    
    # Wait for frontend
    if wait_for_service "frontend"; then
        # Check frontend health
        check_service_health "frontend" "curl -f http://localhost/health"
    fi
    
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
    echo "   Complete reset: docker-compose down -v && docker system prune -a"
}

# Error handling
trap 'print_error "Script failed at line $LINENO. Check the logs above for details."' ERR

# Run main function
main "$@"
