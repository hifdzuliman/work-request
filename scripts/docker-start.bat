@echo off
echo 🐳 Starting Work Request Management System...

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

REM Check if required files exist
echo 🔍 Checking required files...

if not exist "docker-compose.yml" (
    echo ❌ docker-compose.yml not found!
    pause
    exit /b 1
)

if not exist "backend\go.mod" (
    echo ❌ backend\go.mod not found!
    pause
    exit /b 1
)

if not exist "backend\go.sum" (
    echo ❌ backend\go.sum not found!
    echo 🔧 Running Go modules fix script...
    call scripts\fix-go-modules.bat
)

if not exist "frontend\package.json" (
    echo ❌ frontend\package.json not found!
    pause
    exit /b 1
)

echo ✅ All required files found!

REM Stop any existing containers
echo 🛑 Stopping existing containers...
docker-compose down

REM Remove any dangling images
echo 🧹 Cleaning up Docker images...
docker system prune -f

REM Build images
echo 🔨 Building Docker images...
docker-compose build --no-cache

REM Start services
echo 🚀 Starting services...
docker-compose up -d

REM Wait for services to be ready
echo ⏳ Waiting for services to be ready...
timeout /t 10 /nobreak >nul

REM Check service status
echo 📊 Checking service status...
docker-compose ps

echo.
echo 🎉 Services started successfully!
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
pause
