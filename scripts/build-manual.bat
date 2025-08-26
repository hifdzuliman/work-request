@echo off
echo 🔨 Building and Running Services Manually
echo ==========================================

REM Cleanup existing containers and images
echo [INFO] Cleaning up existing containers and images...

REM Stop and remove containers
docker stop work-request-backend work-request-frontend work-request-postgres work-request-redis work-request-nginx 2>nul
docker rm work-request-backend work-request-frontend work-request-postgres work-request-redis work-request-nginx 2>nul

REM Remove images
docker rmi work-request-backend work-request-frontend 2>nul

REM Build Backend
echo [INFO] Building Backend image...
docker build -t work-request-backend ./backend
if errorlevel 1 (
    echo [ERROR] Backend build failed
    pause
    exit /b 1
)
echo [SUCCESS] Backend image built successfully

REM Build Frontend
echo [INFO] Building Frontend image...
docker build -t work-request-frontend ./frontend
if errorlevel 1 (
    echo [ERROR] Frontend build failed
    pause
    exit /b 1
)
echo [SUCCESS] Frontend image built successfully

REM Create network if not exists
echo [INFO] Creating network...
docker network create work-request_work-request-network 2>nul

REM Start PostgreSQL
echo [INFO] Starting PostgreSQL...
docker run -d --name work-request-postgres --network work-request_work-request-network -e POSTGRES_DB=work_request_db -e POSTGRES_USER=work_request_user -e POSTGRES_PASSWORD=work_request_password -e POSTGRES_INITDB_ARGS="--encoding=UTF-8 --lc-collate=C --lc-ctype=C" -v postgres_data:/var/lib/postgresql/data -v "%cd%/scripts/init-db.sql:/docker-entrypoint-initdb.d/init-db.sql" -p 5432:5432 postgres:15-alpine
if errorlevel 1 (
    echo [ERROR] PostgreSQL failed to start
    pause
    exit /b 1
)
echo [SUCCESS] PostgreSQL started successfully

REM Wait for PostgreSQL to be ready
echo [INFO] Waiting for PostgreSQL to be ready...
timeout /t 30 /nobreak >nul

REM Check PostgreSQL health
echo [INFO] Checking PostgreSQL health...
set "retry_count=0"
set "max_retries=10"

:check_postgres
docker exec work-request-postgres pg_isready -U work_request_user -d work_request_db >nul 2>&1
if errorlevel 1 (
    set /a retry_count+=1
    if !retry_count! lss !max_retries! (
        echo [INFO] PostgreSQL not ready yet (attempt !retry_count!/!max_retries!)
        timeout /t 10 /nobreak >nul
        goto check_postgres
    ) else (
        echo [ERROR] PostgreSQL failed to become healthy
        pause
        exit /b 1
    )
) else (
    echo [SUCCESS] PostgreSQL is healthy
)

REM Start Backend
echo [INFO] Starting Backend...
docker run -d --name work-request-backend --network work-request_work-request-network -e SERVER_PORT=8080 -e SERVER_HOST=178.128.54.249 -e DB_HOST=work-request-postgres -e DB_PORT=5432 -e DB_USER=work_request_user -e DB_PASSWORD=work_request_password -e DB_NAME=work_request_db -e DB_SSL_MODE=disable -e JWT_SECRET=your_super_secret_jwt_key_change_in_production -e JWT_EXPIRY=24h -e CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:80,http://frontend:80,http://178.128.54.249:3000 -p 8080:8080 work-request-backend
if errorlevel 1 (
    echo [ERROR] Backend failed to start
    pause
    exit /b 1
)
echo [SUCCESS] Backend started successfully

REM Wait for Backend to be ready
echo [INFO] Waiting for Backend to be ready...
timeout /t 20 /nobreak >nul

REM Check Backend health
echo [INFO] Checking Backend health...
set "retry_count=0"
set "max_retries=8"

:check_backend
curl -f -X GET "http://178.128.54.249:8080/health" >nul 2>&1
if errorlevel 1 (
    set /a retry_count+=1
    if !retry_count! lss !max_retries! (
        echo [INFO] Backend not ready yet (attempt !retry_count!/!max_retries!)
        timeout /t 10 /nobreak >nul
        goto check_backend
    ) else (
        echo [ERROR] Backend failed to become healthy
        pause
        exit /b 1
    )
) else (
    echo [SUCCESS] Backend is healthy
)

REM Start Frontend
echo [INFO] Starting Frontend...
docker run -d --name work-request-frontend --network work-request_work-request-network -e REACT_APP_API_BASE_URL=http://178.128.54.249:8080/api -e REACT_APP_ENABLE_NOTIFICATIONS=true -e REACT_APP_ENABLE_EXPORT=true -e REACT_APP_ENABLE_FILTERS=true -p 3000:80 work-request-frontend
if errorlevel 1 (
    echo [ERROR] Frontend failed to start
    pause
    exit /b 1
)
echo [SUCCESS] Frontend started successfully

REM Start Redis
echo [INFO] Starting Redis...
docker run -d --name work-request-redis --network work-request_work-request-network -v redis_data:/data -p 6379:6379 redis:7-alpine redis-server --appendonly yes
if errorlevel 1 (
    echo [ERROR] Redis failed to start
) else (
    echo [SUCCESS] Redis started successfully
)

REM Start Nginx
echo [INFO] Starting Nginx...
docker run -d --name work-request-nginx --network work-request_work-request-network -v "%cd%/nginx/nginx.conf:/etc/nginx/nginx.conf:ro" -v "%cd%/nginx/conf.d:/etc/nginx/conf.d:ro" -p 80:80 -p 443:443 nginx:alpine
if errorlevel 1 (
    echo [ERROR] Nginx failed to start
) else (
    echo [SUCCESS] Nginx started successfully
)

REM Final status check
echo [INFO] Final container status:
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo.
echo [SUCCESS] 🎉 All services started successfully!
echo.
echo 📱 Access your application:
echo    Frontend: http://178.128.54.249:3000
echo    Backend API: http://178.128.54.249:8080
echo    PostgreSQL: localhost:5432
echo    Redis: localhost:6379
echo    Nginx: http://178.128.54.249:80
echo.
echo 🔑 Default admin credentials: admin/admin123
echo.
echo 📋 Useful commands:
echo    View logs: docker logs -f [container_name]
echo    Stop services: docker stop [container_name]
echo    Restart services: docker restart [container_name]
echo    Check status: docker ps
echo.
pause
