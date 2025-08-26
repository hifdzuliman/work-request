#!/bin/bash

echo "🔨 Building and Running Services Manually"
echo "=========================================="

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

# Function to check if container exists
container_exists() {
    docker ps -a --format "table {{.Names}}" | grep -q "^$1$"
}

# Function to check if image exists
image_exists() {
    docker images --format "table {{.Repository}}" | grep -q "^$1$"
}

# Function to stop and remove container
cleanup_container() {
    local container_name=$1
    if container_exists "$container_name"; then
        print_status "Stopping and removing container: $container_name"
        docker stop "$container_name" 2>/dev/null || true
        docker rm "$container_name" 2>/dev/null || true
    fi
}

# Function to remove image
cleanup_image() {
    local image_name=$1
    if image_exists "$image_name"; then
        print_status "Removing image: $image_name"
        docker rmi "$image_name" 2>/dev/null || true
    fi
}

# Cleanup existing containers and images
print_status "Cleaning up existing containers and images..."

cleanup_container "work-request-backend"
cleanup_container "work-request-frontend"
cleanup_container "work-request-postgres"
cleanup_container "work-request-redis"
cleanup_container "work-request-nginx"

cleanup_image "work-request-backend"
cleanup_image "work-request-frontend"

# Build Backend
print_status "Building Backend image..."
if docker build -t work-request-backend ./backend; then
    print_success "Backend image built successfully"
else
    print_error "Backend build failed"
    exit 1
fi

# Build Frontend
print_status "Building Frontend image..."
if docker build -t work-request-frontend ./frontend; then
    print_success "Frontend image built successfully"
else
    print_error "Frontend build failed"
    exit 1
fi

# Create network if not exists
print_status "Creating network..."
docker network create work-request_work-request-network 2>/dev/null || true

# Start PostgreSQL
print_status "Starting PostgreSQL..."
if docker run -d \
    --name work-request-postgres \
    --network work-request_work-request-network \
    -e POSTGRES_DB=work_request_db \
    -e POSTGRES_USER=work_request_user \
    -e POSTGRES_PASSWORD=work_request_password \
    -e POSTGRES_INITDB_ARGS="--encoding=UTF-8 --lc-collate=C --lc-ctype=C" \
    -v postgres_data:/var/lib/postgresql/data \
    -v "$(pwd)/scripts/init-db.sql:/docker-entrypoint-initdb.d/init-db.sql" \
    -p 5432:5432 \
    postgres:15-alpine; then
    print_success "PostgreSQL started successfully"
else
    print_error "PostgreSQL failed to start"
    exit 1
fi

# Wait for PostgreSQL to be ready
print_status "Waiting for PostgreSQL to be ready..."
sleep 10

# Start Backend
print_status "Starting Backend..."
if docker run -d \
    --name work-request-backend \
    --network work-request_work-request-network \
    -e SERVER_PORT=8080 \
    -e SERVER_HOST=178.128.54.249 \
    -e DB_HOST=work-request-postgres \
    -e DB_PORT=5432 \
    -e DB_USER=work_request_user \
    -e DB_PASSWORD=work_request_password \
    -e DB_NAME=work_request_db \
    -e DB_SSL_MODE=disable \
    -e JWT_SECRET=your_super_secret_jwt_key_change_in_production \
    -e JWT_EXPIRY=24h \
    -e CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:80,http://frontend:80,http://178.128.54.249:3000 \
    -p 8080:8080 \
    work-request-backend; then
    print_success "Backend started successfully"
else
    print_error "Backend failed to start"
    exit 1
fi

# Wait for Backend to be ready
print_status "Waiting for Backend to be ready..."
sleep 10

# Start Frontend
print_status "Starting Frontend..."
if docker run -d \
    --name work-request-frontend \
    --network work-request_work-request-network \
    -e REACT_APP_API_BASE_URL=http://178.128.54.249:8080/api \
    -e REACT_APP_ENABLE_NOTIFICATIONS=true \
    -e REACT_APP_ENABLE_EXPORT=true \
    -e REACT_APP_ENABLE_FILTERS=true \
    -p 3000:80 \
    work-request-frontend; then
    print_success "Frontend started successfully"
else
    print_error "Frontend failed to start"
    exit 1
fi

# Start Redis
print_status "Starting Redis..."
if docker run -d \
    --name work-request-redis \
    --network work-request_work-request-network \
    -v redis_data:/data \
    -p 6379:6379 \
    redis:7-alpine redis-server --appendonly yes; then
    print_success "Redis started successfully"
else
    print_error "Redis failed to start"
fi

# Start Nginx
print_status "Starting Nginx..."
if docker run -d \
    --name work-request-nginx \
    --network work-request_work-request-network \
    -v "$(pwd)/nginx/nginx-simple.conf:/etc/nginx/nginx.conf:ro" \
    -p 80:80 \
    -p 443:443 \
    nginx:alpine; then
    print_success "Nginx started successfully"
else
    print_error "Nginx failed to start"
fi

# Final status check
print_status "Final container status:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
print_success "🎉 All services started successfully!"
echo ""
echo "📱 Access your application:"
echo "   Frontend: http://178.128.54.249:3000"
echo "   Backend API: http://178.128.54.249:8080"
echo "   PostgreSQL: 178.128.54.249:5432"
echo "   Redis: 178.128.54.249:6379"
echo "   Nginx: http://178.128.54.249:80"
echo ""
echo "🔑 Default admin credentials: admin/admin123"
echo ""
echo "📋 Useful commands:"
echo "   View logs: docker logs -f [container_name]"
echo "   Stop services: docker stop [container_name]"
echo "   Restart services: docker restart [container_name]"
echo "   Check status: docker ps"
