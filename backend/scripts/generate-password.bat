@echo off
echo Password Hash Generator for Web Work Request Backend
echo.

if "%1"=="" (
    echo Usage: generate-password.bat [password]
    echo.
    echo Examples:
    echo   generate-password.bat admin123
    echo   generate-password.bat "My Password"
    echo.
    echo Or run without arguments to generate a random password
    echo.
    pause
    exit /b
)

echo Generating hash for password: %1
echo.

cd /d "%~dp0.."
go run cmd/password/main.go -password="%1"

echo.
pause
