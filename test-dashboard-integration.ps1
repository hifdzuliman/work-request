# Test Dashboard Integration
Write-Host "Testing Dashboard Integration..." -ForegroundColor Green
Write-Host ""

# Test 1: Check backend health
Write-Host "1. Checking Backend Health..." -ForegroundColor Yellow
try {
    $healthResponse = Invoke-RestMethod -Uri "http://localhost:8080/health" -Method GET
    Write-Host "✅ Backend health check successful: $($healthResponse.message)" -ForegroundColor Green
} catch {
    Write-Host "❌ Backend health check failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please start the backend first: cd backend && go run main.go" -ForegroundColor Yellow
    Read-Host "Press Enter to continue..."
    exit 1
}

# Test 2: Login to get token
Write-Host ""
Write-Host "2. Testing Login..." -ForegroundColor Yellow

$loginData = @{
    username = "hifdzul"
    password = "admin123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    $token = $loginResponse.token
    Write-Host "✅ Login successful! Token obtained" -ForegroundColor Green
    Write-Host "   User: $($loginResponse.user.name) (Role: $($loginResponse.user.role))" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Cannot test dashboard without authentication" -ForegroundColor Yellow
    Read-Host "Press Enter to continue..."
    exit 1
}

# Test 3: Test Dashboard Stats endpoint
Write-Host ""
Write-Host "3. Testing Dashboard Stats Endpoint..." -ForegroundColor Yellow

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

try {
    $dashboardResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/dashboard/stats" -Method GET -Headers $headers
    
    Write-Host "✅ Dashboard stats endpoint successful!" -ForegroundColor Green
    Write-Host "   Status Code: $($dashboardResponse.StatusCode)" -ForegroundColor Cyan
    Write-Host "   Response Length: $($dashboardResponse.Content.Length) characters" -ForegroundColor Cyan
    
    # Parse response
    $dashboardData = $dashboardResponse.Content | ConvertFrom-Json
    Write-Host ""
    Write-Host "   Dashboard Statistics:" -ForegroundColor Cyan
    Write-Host "   - User ID: $($dashboardData.user_id)" -ForegroundColor Cyan
    Write-Host "   - Role: $($dashboardData.role)" -ForegroundColor Cyan
    Write-Host "   - Total Pengajuan: $($dashboardData.total_pengajuan)" -ForegroundColor Cyan
    Write-Host "   - Total Persetujuan: $($dashboardData.total_persetujuan)" -ForegroundColor Cyan
    Write-Host "   - Total Riwayat: $($dashboardData.total_riwayat)" -ForegroundColor Cyan
    Write-Host "   - Total Pengguna: $($dashboardData.total_pengguna)" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Dashboard stats endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode
        Write-Host "   Status Code: $statusCode" -ForegroundColor Red
        
        if ($statusCode -eq 401) {
            Write-Host "   This means 'Unauthorized' - check if token is valid" -ForegroundColor Yellow
        } elseif ($statusCode -eq 404) {
            Write-Host "   This means 'Not Found' - check if route is registered" -ForegroundColor Yellow
        } elseif ($statusCode -eq 500) {
            Write-Host "   This means 'Internal Server Error' - check backend logs" -ForegroundColor Yellow
        }
    }
}

# Test 4: Test CORS for Dashboard endpoint
Write-Host ""
Write-Host "4. Testing CORS for Dashboard..." -ForegroundColor Yellow

try {
    $corsHeaders = @{
        "Origin" = "http://localhost:3000"
        "Access-Control-Request-Method" = "GET"
        "Access-Control-Request-Headers" = "Authorization,Content-Type"
    }
    
    $corsResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/dashboard/stats" -Method OPTIONS -Headers $corsHeaders
    
    Write-Host "✅ CORS preflight successful!" -ForegroundColor Green
    Write-Host "   Status Code: $($corsResponse.StatusCode)" -ForegroundColor Cyan
    Write-Host "   Access-Control-Allow-Origin: $($corsResponse.Headers['Access-Control-Allow-Origin'])" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ CORS preflight failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Verify Frontend Integration
Write-Host ""
Write-Host "5. Frontend Integration Steps..." -ForegroundColor Yellow
Write-Host "   To complete dashboard integration:" -ForegroundColor Cyan
Write-Host "   1. Navigate to /dashboard in browser" -ForegroundColor Cyan
Write-Host "   2. Check Network tab for /api/dashboard/stats call" -ForegroundColor Cyan
Write-Host "   3. Verify stats are displayed correctly" -ForegroundColor Cyan
Write-Host "   4. Check for no CORS errors" -ForegroundColor Cyan

Write-Host ""
Write-Host "Dashboard Integration Test completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Expected Results:" -ForegroundColor Yellow
Write-Host "✅ Dashboard stats endpoint returns 200" -ForegroundColor Green
Write-Host "✅ Stats data is properly formatted" -ForegroundColor Green
Write-Host "✅ CORS headers are present" -ForegroundColor Green
Write-Host "✅ Frontend can display real-time data" -ForegroundColor Green
Write-Host ""
Write-Host "If you see errors:" -ForegroundColor Red
Write-Host "1. Check backend logs for errors" -ForegroundColor Yellow
Write-Host "2. Verify route registration in routes.go" -ForegroundColor Yellow
Write-Host "3. Check database connection and tables" -ForegroundColor Yellow
Write-Host "4. Verify authentication middleware" -ForegroundColor Yellow

Read-Host "Press Enter to continue..."

