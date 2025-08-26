@echo off
echo Starting Web Work Request Backend...
echo.
echo Make sure you have:
echo 1. PostgreSQL running
echo 2. Database 'web_work_request' created
echo 3. config.env file configured
echo.
echo Starting server...
go run main.go
pause
