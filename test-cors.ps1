# Test CORS Functionality
Write-Host "Testing CORS Configuration..." -ForegroundColor Green
Write-Host ""

# Test 1: Health Check (Public endpoint)
Write-Host "1. Testing Public Endpoint (Health Check)..." -ForegroundColor Yellow
try {
    $healthResponse = Invoke-RestMethod -Uri "http://localhost:8080/health" -Method GET
    Write-Host "✅ Health check successful: $($healthResponse.message)" -ForegroundColor Green
} catch {
    Write-Host "❌ Health check failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: CORS Preflight for Users endpoint
Write-Host ""
Write-Host "2. Testing CORS Preflight Request..." -ForegroundColor Yellow
try {
    $headers = @{
        "Origin" = "http://localhost:3000"
        "Access-Control-Request-Method" = "GET"
        "Access-Control-Request-Headers" = "Authorization,Content-Type"
    }
    
    $preflightResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/users" -Method OPTIONS -Headers $headers
    
    Write-Host "✅ CORS Preflight successful!" -ForegroundColor Green
    Write-Host "   Status Code: $($preflightResponse.StatusCode)" -ForegroundColor Cyan
    Write-Host "   Access-Control-Allow-Origin: $($preflightResponse.Headers['Access-Control-Allow-Origin'])" -ForegroundColor Cyan
    Write-Host "   Access-Control-Allow-Methods: $($preflightResponse.Headers['Access-Control-Allow-Methods'])" -ForegroundColor Cyan
    Write-Host "   Access-Control-Allow-Headers: $($preflightResponse.Headers['Access-Control-Allow-Headers'])" -ForegroundColor Cyan
} catch {
    Write-Host "❌ CORS Preflight failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Login to get token
Write-Host ""
Write-Host "3. Testing Login for Protected Endpoint..." -ForegroundColor Yellow

$loginData = @{
    username = "hifdzul"
    password = "admin123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    $token = $loginResponse.token
    Write-Host "✅ Login successful! Token obtained" -ForegroundColor Green
} catch {
    Write-Host "❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Cannot test protected endpoints without authentication" -ForegroundColor Yellow
    Read-Host "Press Enter to continue..."
    exit 1
}

# Test 4: Protected endpoint with CORS headers
Write-Host ""
Write-Host "4. Testing Protected Endpoint with CORS..." -ForegroundColor Yellow

try {
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
        "Origin" = "http://localhost:3000"
    }
    
    $usersResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/users" -Method GET -Headers $headers
    
    Write-Host "✅ Protected endpoint access successful!" -ForegroundColor Green
    Write-Host "   Status Code: $($usersResponse.StatusCode)" -ForegroundColor Cyan
    Write-Host "   Access-Control-Allow-Origin: $($usersResponse.Headers['Access-Control-Allow-Origin'])" -ForegroundColor Cyan
    Write-Host "   Response Length: $($usersResponse.Content.Length) characters" -ForegroundColor Cyan
    
    # Parse response content
    $users = $usersResponse.Content | ConvertFrom-Json
    Write-Host "   Found $($users.Count) users" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Protected endpoint access failed: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode
        Write-Host "   Status Code: $statusCode" -ForegroundColor Red
        
        if ($statusCode -eq 401) {
            Write-Host "   This means 'Unauthorized' - check if token is valid" -ForegroundColor Yellow
        } elseif ($statusCode -eq 403) {
            Write-Host "   This means 'Forbidden' - check if user has permission" -ForegroundColor Yellow
        }
    }
}

# Test 5: CORS Error Simulation
Write-Host ""
Write-Host "5. Testing CORS Error Handling..." -ForegroundColor Yellow

try {
    # Try to access without proper CORS headers
    $noCorsResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/users" -Method GET -Headers @{"Authorization" = "Bearer $token"}
    Write-Host "✅ Request without CORS headers successful" -ForegroundColor Green
} catch {
    Write-Host "❌ Request failed (expected if CORS is strict): $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "CORS Test completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Check if frontend can now access the users endpoint" -ForegroundColor Cyan
Write-Host "2. Verify no CORS errors in browser console" -ForegroundColor Cyan
Write-Host "3. Test user management functionality" -ForegroundColor Cyan

Read-Host "Press Enter to continue..."

