@echo off
echo 🔄 Complete Docker Reset and Rebuild
echo ====================================

REM Check Docker status
echo [INFO] Checking Docker status...
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not running. Please start Docker first.
    pause
    exit /b 1
)
echo [SUCCESS] Docker is running

REM Complete cleanup
echo [INFO] Performing complete cleanup...

echo [INFO] Stopping all containers...
docker-compose down >nul 2>&1

echo [INFO] Removing all containers...
docker-compose down --rmi all --volumes --remove-orphans >nul 2>&1

echo [INFO] Removing all images...
for /f "tokens=*" %%i in ('docker images -q') do docker rmi %%i >nul 2>&1

echo [INFO] Removing all volumes...
docker volume prune -f

echo [INFO] Removing all networks...
docker network prune -f

echo [INFO] Cleaning Docker system...
docker system prune -a --volumes -f

echo [SUCCESS] Cleanup completed

REM Check required files
echo [INFO] Checking required files...
set "required_files=docker-compose.yml backend\go.mod backend\go.sum backend\config.env frontend\package.json scripts\init-db.sql"

for %%f in (%required_files%) do (
    if not exist "%%f" (
        echo [ERROR] Required file missing: %%f
        pause
        exit /b 1
    ) else (
        echo [SUCCESS] ✓ %%f exists
    )
)

REM Build images step by step
echo [INFO] Building images step by step...

echo [INFO] Building PostgreSQL image...
docker-compose build postgres
if errorlevel 1 (
    echo [ERROR] PostgreSQL build failed
    pause
    exit /b 1
)
echo [SUCCESS] PostgreSQL build successful

echo [INFO] Building Backend image...
docker-compose build backend
if errorlevel 1 (
    echo [ERROR] Backend build failed
    echo [INFO] Backend build logs (last 20 lines):
    docker-compose build backend 2>&1 | tail -20
    pause
    exit /b 1
)
echo [SUCCESS] Backend build successful

echo [INFO] Building Frontend image...
docker-compose build frontend
if errorlevel 1 (
    echo [ERROR] Frontend build failed
    echo [INFO] Frontend build logs (last 20 lines):
    docker-compose build frontend 2>&1 | tail -20
    pause
    exit /b 1
)
echo [SUCCESS] Frontend build successful

REM Start services step by step
echo [INFO] Starting services step by step...

echo [INFO] Starting PostgreSQL...
docker-compose up -d postgres

echo [INFO] Waiting for PostgreSQL to be ready...
timeout /t 45 /nobreak >nul

REM Check PostgreSQL health
echo [INFO] Checking PostgreSQL health...
set "retry_count=0"
set "max_retries=10"

:check_postgres
docker-compose exec -T postgres pg_isready -U work_request_user -d work_request_db >nul 2>&1
if errorlevel 1 (
    set /a retry_count+=1
    if !retry_count! lss !max_retries! (
        echo [WARNING] PostgreSQL not ready yet (attempt !retry_count!/!max_retries!)
        timeout /t 10 /nobreak >nul
        goto check_postgres
    ) else (
        echo [ERROR] PostgreSQL failed to become healthy after !max_retries! attempts
        echo [INFO] PostgreSQL logs:
        docker-compose logs postgres
        pause
        exit /b 1
    )
) else (
    echo [SUCCESS] PostgreSQL is healthy
)

echo [INFO] Starting Backend...
docker-compose up -d backend

echo [INFO] Waiting for Backend to be ready...
timeout /t 30 /nobreak >nul

REM Check Backend health
echo [INFO] Checking Backend health...
set "retry_count=0"
set "max_retries=8"

:check_backend
docker-compose exec -T backend wget -qO- http://localhost:8080/health >nul 2>&1
if errorlevel 1 (
    set /a retry_count+=1
    if !retry_count! lss !max_retries! (
        echo [WARNING] Backend not ready yet (attempt !retry_count!/!max_retries!)
        timeout /t 10 /nobreak >nul
        goto check_backend
    ) else (
        echo [ERROR] Backend failed to become healthy after !max_retries! attempts
        echo [INFO] Backend logs:
        docker-compose logs backend
        pause
        exit /b 1
    )
) else (
    echo [SUCCESS] Backend is healthy
)

echo [INFO] Starting Frontend...
docker-compose up -d frontend

echo [INFO] Waiting for Frontend to be ready...
timeout /t 20 /nobreak >nul

REM Check Frontend health
echo [INFO] Checking Frontend health...
set "retry_count=0"
set "max_retries=6"

:check_frontend
docker-compose exec -T frontend curl -f http://localhost/health >nul 2>&1
if errorlevel 1 (
    set /a retry_count+=1
    if !retry_count! lss !max_retries! (
        echo [WARNING] Frontend not ready yet (attempt !retry_count!/!max_retries!)
        timeout /t 10 /nobreak >nul
        goto check_frontend
    ) else (
        echo [WARNING] Frontend health check failed after !max_retries! attempts
        echo [INFO] Frontend logs:
        docker-compose logs frontend
    )
) else (
    echo [SUCCESS] Frontend is healthy
)

echo [INFO] Starting Redis...
docker-compose up -d redis

echo [INFO] Starting Nginx...
docker-compose up -d nginx

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
echo    Complete reset: scripts\reset-and-rebuild.bat
echo.
pause
