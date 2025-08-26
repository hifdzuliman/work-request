@echo off
echo Starting Web Work Request Application...
echo.

echo Starting Backend Server...
start "Backend Server" cmd /k "cd backend && go run main.go"

echo Waiting for backend to start...
timeout /t 5 /nobreak > nul

echo Starting Frontend Development Server...
start "Frontend Server" cmd /k "cd frontend && npm start"

echo.
echo Both servers are starting...
echo Backend: http://localhost:8080
echo Frontend: http://localhost:3000
echo Integration Test: http://localhost:3000/integration-test
echo.
echo Press any key to close this window...
pause > nul

