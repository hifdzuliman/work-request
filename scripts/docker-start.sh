#!/bin/bash

# Script to safely start Docker services
echo "🐳 Starting Work Request Management System..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed or not in PATH."
    exit 1
fi

# Check if required files exist
echo "🔍 Checking required files..."

if [ ! -f "docker-compose.yml" ]; then
    echo "❌ docker-compose.yml not found!"
    exit 1
fi

if [ ! -f "backend/go.mod" ]; then
    echo "❌ backend/go.mod not found!"
    exit 1
fi

if [ ! -f "backend/go.sum" ]; then
    echo "❌ backend/go.sum not found!"
    echo "🔧 Running Go modules fix script..."
    ./scripts/fix-go-modules.sh
fi

if [ ! -f "frontend/package.json" ]; then
    echo "❌ frontend/package.json not found!"
    exit 1
fi

echo "✅ All required files found!"

# Stop any existing containers
echo "🛑 Stopping existing containers..."
docker-compose down

# Remove any dangling images
echo "🧹 Cleaning up Docker images..."
docker system prune -f

# Build images
echo "🔨 Building Docker images..."
docker-compose build --no-cache

# Start services
echo "🚀 Starting services..."
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check service status
echo "📊 Checking service status..."
docker-compose ps

# Check service health
echo "🏥 Checking service health..."
echo "PostgreSQL:"
docker-compose exec -T postgres pg_isready -U work_request_user -d work_request_db || echo "❌ PostgreSQL not ready"

echo "Backend:"
docker-compose exec -T backend wget -qO- http://localhost:8080/health || echo "❌ Backend not ready"

echo "Frontend:"
docker-compose exec -T frontend curl -f http://localhost/health || echo "❌ Frontend not ready"

echo ""
echo "🎉 Services started successfully!"
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
