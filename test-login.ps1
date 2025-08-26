# Test Login Functionality
Write-Host "Testing Login Functionality..." -ForegroundColor Green
Write-Host ""

# Test 1: Health Check
Write-Host "1. Testing Backend Health..." -ForegroundColor Yellow
try {
    $healthResponse = Invoke-RestMethod -Uri "http://localhost:8080/health" -Method GET
    Write-Host "✅ Backend is running: $($healthResponse.message)" -ForegroundColor Green
} catch {
    Write-Host "❌ Backend health check failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please make sure backend is running on port 8080" -ForegroundColor Yellow
    Read-Host "Press Enter to continue..."
    exit 1
}

# Test 2: Login with test credentials
Write-Host ""
Write-Host "2. Testing Login API..." -ForegroundColor Yellow

$loginData = @{
    username = "hifdzul"
    password = "admin123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    Write-Host "✅ Login successful!" -ForegroundColor Green
    Write-Host "   Token: $($loginResponse.token.Substring(0, 20))..." -ForegroundColor Cyan
    Write-Host "   User: $($loginResponse.user.name)" -ForegroundColor Cyan
    Write-Host "   Role: $($loginResponse.user.role)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode
        Write-Host "   Status Code: $statusCode" -ForegroundColor Red
        
        if ($statusCode -eq 401) {
            Write-Host "   This means 'Unauthorized' - check if user exists in database" -ForegroundColor Yellow
        }
    }
}

# Test 3: Check if user exists in database
Write-Host ""
Write-Host "3. Database Check..." -ForegroundColor Yellow
Write-Host "   If login failed, you may need to create the test user first:" -ForegroundColor Yellow
Write-Host "   Run: cd backend && go run scripts/create-test-user.go" -ForegroundColor Cyan

Write-Host ""
Write-Host "Test completed!" -ForegroundColor Green
Read-Host "Press Enter to continue..."

