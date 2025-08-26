@echo off
echo Testing Frontend-Backend Integration...
echo.

echo 1. Checking if backend is running...
curl -s http://localhost:8080/health > nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Backend is running on port 8080
) else (
    echo ❌ Backend is not running on port 8080
    echo Please start the backend first: cd backend && go run main.go
    pause
    exit /b 1
)

echo.
echo 2. Checking if frontend is running...
curl -s http://localhost:3000 > nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Frontend is running on port 3000
) else (
    echo ❌ Frontend is not running on port 3000
    echo Please start the frontend first: cd frontend && npm start
    pause
    exit /b 1
)

echo.
echo 3. Testing API endpoint...
curl -s http://localhost:8080/api/health
if %errorlevel% equ 0 (
    echo ✅ API endpoint is accessible
) else (
    echo ❌ API endpoint is not accessible
)

echo.
echo 4. Testing frontend-backend communication...
echo Opening integration test page in browser...
start http://localhost:3000/integration-test

echo.
echo Integration test completed!
echo Check the browser for detailed test results.
echo.
pause

