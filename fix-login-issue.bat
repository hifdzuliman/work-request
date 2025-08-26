@echo off
echo Fixing Login Issue...
echo.

echo 1. Creating test user in database...
cd backend
go run scripts/create-test-user.go
if %errorlevel% neq 0 (
    echo ❌ Failed to create test user
    pause
    exit /b 1
)

echo.
echo 2. Test user created successfully!
echo    Username: hifdzul
echo    Password: admin123
echo.

echo 3. Restarting backend server...
echo    Please stop the current backend server (Ctrl+C) and restart it
echo    with: cd backend && go run main.go
echo.

echo 4. Testing login with curl...
timeout /t 3 /nobreak > nul
curl -X POST http://localhost:8080/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"hifdzul\",\"password\":\"admin123\"}"

echo.
echo.
echo Login issue should now be fixed!
echo Test the login in your frontend application.
echo.
pause

