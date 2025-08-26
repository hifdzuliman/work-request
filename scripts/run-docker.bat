@echo off
setlocal enabledelayedexpansion

REM Comprehensive Docker runner script for Work Request Management System
echo 🐳 Work Request Management System - Docker Runner
echo ================================================

REM Check prerequisites
echo [INFO] Checking prerequisites...

REM Check if Docker exists
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not installed or not in PATH
    pause
    exit /b 1
)

REM Check if Docker Compose exists
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker Compose is not installed or not in PATH
    pause
    exit /b 1
)

REM Check if Docker daemon is running
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker daemon is not running. Please start Docker first.
    pause
    exit /b 1
)

echo [SUCCESS] Prerequisites check passed

REM Check required files
echo [INFO] Checking required files...

set "required_files=docker-compose.yml backend\go.mod backend\go.sum frontend\package.json scripts\init-db.sql"

for %%f in (%required_files%) do (
    if not exist "%%f" (
        echo [ERROR] Required file not found: %%f
        pause
        exit /b 1
    )
)

echo [SUCCESS] All required files found

REM Check Go modules
echo [INFO] Verifying Go modules...
cd backend

if not exist "go.sum" (
    echo [WARNING] go.sum not found, regenerating...
    go clean -modcache
    go mod download
    go mod verify
    go mod tidy
) else (
    go mod verify
    go mod tidy
)

cd ..
echo [SUCCESS] Go modules verified

REM Stop existing services
echo [INFO] Stopping existing services...
docker-compose down >nul 2>&1

REM Clean up Docker system
echo [INFO] Cleaning up Docker system...
docker system prune -f

REM Build images
echo [INFO] Building Docker images...
docker-compose build --no-cache

REM Start services
echo [INFO] Starting services...
docker-compose up -d

REM Wait for services to be ready
echo [INFO] Waiting for services to be ready...
timeout /t 5 /nobreak >nul

REM Check service status
echo [INFO] Checking service status...
docker-compose ps

REM Wait and check PostgreSQL
echo [INFO] Waiting for PostgreSQL to be ready...
:wait_postgres
timeout /t 2 /nobreak >nul
docker-compose exec -T postgres pg_isready -U work_request_user -d work_request_db >nul 2>&1
if errorlevel 1 (
    echo [INFO] PostgreSQL not ready yet, waiting...
    goto wait_postgres
)
echo [SUCCESS] PostgreSQL is ready

REM Wait and check Backend
echo [INFO] Waiting for Backend to be ready...
:wait_backend
timeout /t 2 /nobreak >nul
docker-compose exec -T backend wget -qO- http://localhost:8080/health >nul 2>&1
if errorlevel 1 (
    echo [INFO] Backend not ready yet, waiting...
    goto wait_backend
)
echo [SUCCESS] Backend is ready

REM Wait and check Frontend
echo [INFO] Waiting for Frontend to be ready...
:wait_frontend
timeout /t 2 /nobreak >nul
docker-compose exec -T frontend curl -f http://localhost/health >nul 2>&1
if errorlevel 1 (
    echo [INFO] Frontend not ready yet, waiting...
    goto wait_frontend
)
echo [SUCCESS] Frontend is ready

REM Final status check
echo [INFO] Final service status:
docker-compose ps

echo.
echo [SUCCESS] 🎉 All services started successfully!
echo.
echo 📱 Access your application:
echo    Frontend: http://localhost:3000
echo    Backend API: http://localhost:8080
echo    PostgreSQL: localhost:5432
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
