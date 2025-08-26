@echo off
echo 🔍 Testing Health Endpoints
echo ============================

REM Test Backend Health
echo [INFO] Testing Backend Health...
curl -f -X GET "http://178.128.54.249:8080/health" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Backend health endpoint failed
) else (
    echo [SUCCESS] Backend health endpoint is working
)

echo.

REM Test Frontend Health
echo [INFO] Testing Frontend Health...
curl -f -X GET "http://178.128.54.249:3000/health" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Frontend health endpoint failed
) else (
    echo [SUCCESS] Frontend health endpoint is working
)

echo.

REM Test Nginx Health
echo [INFO] Testing Nginx Health...
curl -f -X GET "http://178.128.54.249/health" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Nginx health endpoint failed
) else (
    echo [SUCCESS] Nginx health endpoint is working
)

echo.

REM Test PostgreSQL Health
echo [INFO] Testing PostgreSQL Health...
docker-compose exec -T postgres pg_isready -U work_request_user -d work_request_db >nul 2>&1
if errorlevel 1 (
    echo [ERROR] PostgreSQL health check failed
) else (
    echo [SUCCESS] PostgreSQL is healthy
)

echo.

REM Test Redis Health
echo [INFO] Testing Redis Health...
docker-compose exec -T redis redis-cli ping >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Redis health check failed
) else (
    echo [SUCCESS] Redis is healthy
)

echo.
echo 🎯 Health Check Summary:
echo ========================
echo Backend:   http://178.128.54.249:8080/health
echo Frontend:  http://178.128.54.249:3000/health
echo Nginx:     http://178.128.54.249/health
echo PostgreSQL: Container health check
echo Redis:     Container health check
echo.
pause
