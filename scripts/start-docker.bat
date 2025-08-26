@echo off
echo 🐳 Starting Work Request Management System...
echo =============================================

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker is not running. Please start Docker first.
    pause
    exit /b 1
)

REM Check if Docker Compose is available
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker Compose is not installed or not in PATH.
    pause
    exit /b 1
)

echo ✅ Docker environment check passed

REM Stop existing services
echo 🛑 Stopping existing services...
docker-compose down >nul 2>&1

REM Remove existing volumes to start fresh
echo 🧹 Removing existing volumes...
docker-compose down -v >nul 2>&1

REM Clean up Docker system
echo 🧹 Cleaning up Docker system...
docker system prune -f

REM Start services step by step
echo 🚀 Starting PostgreSQL...
docker-compose up -d postgres

echo ⏳ Waiting for PostgreSQL to be ready...
timeout /t 30 /nobreak >nul

REM Check PostgreSQL health
echo 🔍 Checking PostgreSQL health...
docker-compose exec -T postgres pg_isready -U work_request_user -d work_request_db >nul 2>&1
if errorlevel 1 (
    echo ❌ PostgreSQL health check failed
    echo 📋 PostgreSQL logs:
    docker-compose logs postgres
    pause
    exit /b 1
) else (
    echo ✅ PostgreSQL is healthy
)

echo 🚀 Starting Backend...
docker-compose up -d backend

echo ⏳ Waiting for Backend to be ready...
timeout /t 20 /nobreak >nul

REM Check Backend health
echo 🔍 Checking Backend health...
docker-compose exec -T backend wget -qO- http://localhost:8080/health >nul 2>&1
if errorlevel 1 (
    echo ❌ Backend health check failed
    echo 📋 Backend logs:
    docker-compose logs backend
    pause
    exit /b 1
) else (
    echo ✅ Backend is healthy
)

echo 🚀 Starting Frontend...
docker-compose up -d frontend

echo ⏳ Waiting for Frontend to be ready...
timeout /t 15 /nobreak >nul

REM Check Frontend health
echo 🔍 Checking Frontend health...
docker-compose exec -T frontend curl -f http://localhost/health >nul 2>&1
if errorlevel 1 (
    echo ❌ Frontend health check failed
    echo 📋 Frontend logs:
    docker-compose logs frontend
) else (
    echo ✅ Frontend is healthy
)

echo 🚀 Starting Redis...
docker-compose up -d redis

echo 🚀 Starting Nginx...
docker-compose up -d nginx

REM Final status check
echo.
echo 📊 Final service status:
docker-compose ps

echo.
echo 🎉 Services started successfully!
echo.
echo 📱 Access your application:
echo    Frontend: http://localhost:3000
echo    Backend API: http://localhost:8080
echo    PostgreSQL: localhost:5432
echo    Redis: localhost:6379
echo    Nginx: http://localhost:80
echo.
echo 🔑 Default admin credentials: admin/admin123
echo.
echo 📋 Useful commands:
echo    View logs: docker-compose logs -f
echo    Stop services: docker-compose down
echo    Restart services: docker-compose restart
echo    Check status: docker-compose ps
echo.
echo 🔧 Troubleshooting:
echo    Check logs: docker-compose logs -f [service_name]
echo    Rebuild: docker-compose build --no-cache
echo    Complete reset: docker-compose down -v ^&^& docker system prune -a
echo.
pause
