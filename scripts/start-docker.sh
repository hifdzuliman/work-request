#!/bin/bash

echo "🐳 Starting Work Request Management System..."
echo "============================================="

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

echo "✅ Docker environment check passed"

# Stop existing services
echo "🛑 Stopping existing services..."
docker-compose down 2>/dev/null || true

# Remove existing volumes to start fresh
echo "🧹 Removing existing volumes..."
docker-compose down -v 2>/dev/null || true

# Clean up Docker system
echo "🧹 Cleaning up Docker system..."
docker system prune -f

# Start services step by step
echo "🚀 Starting PostgreSQL..."
docker-compose up -d postgres

echo "⏳ Waiting for PostgreSQL to be ready..."
sleep 30

# Check PostgreSQL health
echo "🔍 Checking PostgreSQL health..."
if docker-compose exec -T postgres pg_isready -U work_request_user -d work_request_db >/dev/null 2>&1; then
    echo "✅ PostgreSQL is healthy"
else
    echo "❌ PostgreSQL health check failed"
    echo "📋 PostgreSQL logs:"
    docker-compose logs postgres
    exit 1
fi

echo "🚀 Starting Backend..."
docker-compose up -d backend

echo "⏳ Waiting for Backend to be ready..."
sleep 20

# Check Backend health
echo "🔍 Checking Backend health..."
if docker-compose exec -T backend wget -qO- http://localhost:8080/health >/dev/null 2>&1; then
    echo "✅ Backend is healthy"
else
    echo "❌ Backend health check failed"
    echo "📋 Backend logs:"
    docker-compose logs backend
    exit 1
fi

echo "🚀 Starting Frontend..."
docker-compose up -d frontend

echo "⏳ Waiting for Frontend to be ready..."
sleep 15

# Check Frontend health
echo "🔍 Checking Frontend health..."
if docker-compose exec -T frontend curl -f http://localhost/health >/dev/null 2>&1; then
    echo "✅ Frontend is healthy"
else
    echo "❌ Frontend health check failed"
    echo "📋 Frontend logs:"
    docker-compose logs frontend
fi

echo "🚀 Starting Redis..."
docker-compose up -d redis

echo "🚀 Starting Nginx..."
docker-compose up -d nginx

# Final status check
echo ""
echo "📊 Final service status:"
docker-compose ps

echo ""
echo "🎉 Services started successfully!"
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
echo "   Complete reset: docker-compose down -v && docker system prune -a"
