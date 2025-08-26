@echo off
echo 🔧 Fixing Go modules...

REM Navigate to backend directory
cd backend

REM Check if go.mod exists
if not exist "go.mod" (
    echo ❌ go.mod not found!
    exit /b 1
)

REM Check if go.sum exists
if not exist "go.sum" (
    echo ⚠️  go.sum not found, regenerating...
    del /f go.sum 2>nul
)

REM Clean Go module cache
echo 🧹 Cleaning Go module cache...
go clean -modcache

REM Download and verify dependencies
echo 📥 Downloading dependencies...
go mod download

REM Verify modules
echo ✅ Verifying modules...
go mod verify

REM Tidy modules
echo 🧹 Tidying modules...
go mod tidy

REM Check for any issues
echo 🔍 Checking for issues...
go mod why

echo ✅ Go modules fixed successfully!
echo 📋 Current dependencies:
go list -m all

cd ..
pause
