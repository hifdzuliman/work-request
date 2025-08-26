# Test Fixed Login Functionality
Write-Host "Testing Fixed Login Functionality..." -ForegroundColor Green
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
    
    Write-Host "✅ Login API call successful!" -ForegroundColor Green
    Write-Host "   Response structure:" -ForegroundColor Cyan
    
    if ($loginResponse.success) {
        Write-Host "   ✅ success: $($loginResponse.success)" -ForegroundColor Green
    } else {
        Write-Host "   ❌ success: $($loginResponse.success)" -ForegroundColor Red
    }
    
    if ($loginResponse.token) {
        Write-Host "   ✅ token: $($loginResponse.token.Substring(0, 20))..." -ForegroundColor Green
    } else {
        Write-Host "   ❌ token: missing" -ForegroundColor Red
    }
    
    if ($loginResponse.user) {
        Write-Host "   ✅ user: $($loginResponse.user.name) ($($loginResponse.user.role))" -ForegroundColor Green
    } else {
        Write-Host "   ❌ user: missing" -ForegroundColor Red
    }
    
    # Test frontend compatibility
    Write-Host ""
    Write-Host "3. Frontend Compatibility Check..." -ForegroundColor Yellow
    
    if ($loginResponse.success -and $loginResponse.token -and $loginResponse.user) {
        Write-Host "   ✅ Compatible with new frontend format" -ForegroundColor Green
    } elseif ($loginResponse.token -and $loginResponse.user) {
        Write-Host "   ✅ Compatible with direct response format" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Incompatible response format" -ForegroundColor Red
    }
    
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

Write-Host ""
Write-Host "4. Next Steps..." -ForegroundColor Yellow
Write-Host "   - Test login in frontend application" -ForegroundColor Cyan
Write-Host "   - Check browser console for any errors" -ForegroundColor Cyan
Write-Host "   - Verify token storage in localStorage" -ForegroundColor Cyan

Write-Host ""
Write-Host "Test completed!" -ForegroundColor Green
Read-Host "Press Enter to continue..."

