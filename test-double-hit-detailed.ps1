# Test Double API Hit Issue - Detailed Analysis
Write-Host "Testing Double API Hit Prevention - Detailed Analysis..." -ForegroundColor Green
Write-Host ""

# Test 1: Monitor specific endpoints for double hits
Write-Host "1. Monitoring Specific Endpoints..." -ForegroundColor Yellow
Write-Host "   Endpoints to monitor:" -ForegroundColor Cyan
Write-Host "   - GET /api/users/me (AuthContext)" -ForegroundColor Cyan
Write-Host "   - GET /api/users (Pengguna component)" -ForegroundColor Cyan
Write-Host ""

# Test 2: Check backend logs for duplicate requests
Write-Host "2. Check Backend Logs for Duplicates..." -ForegroundColor Yellow
Write-Host "   Look for multiple requests to:" -ForegroundColor Cyan
Write-Host "   - GET /api/users/me" -ForegroundColor Red
Write-Host "   - GET /api/users" -ForegroundColor Red
Write-Host "   Should see only ONE request per endpoint per page load" -ForegroundColor Green
Write-Host ""

# Test 3: Test individual endpoints
Write-Host "3. Testing Individual Endpoints..." -ForegroundColor Yellow

# Login to get token
$loginData = @{
    username = "hifdzul"
    password = "admin123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    $token = $loginResponse.token
    Write-Host "✅ Login successful! Token obtained" -ForegroundColor Green
    
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    # Test /api/users/me endpoint
    Write-Host ""
    Write-Host "   Testing /api/users/me endpoint..." -ForegroundColor Cyan
    try {
        $meResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/users/me" -Method GET -Headers $headers
        Write-Host "   ✅ /api/users/me response:" -ForegroundColor Green
        Write-Host "      Status Code: $($meResponse.StatusCode)" -ForegroundColor Cyan
        Write-Host "      Response Length: $($meResponse.Content.Length) characters" -ForegroundColor Cyan
        
        $meData = $meResponse.Content | ConvertFrom-Json
        Write-Host "      User: $($meData.name) (Role: $($meData.role))" -ForegroundColor Cyan
    } catch {
        Write-Host "   ❌ /api/users/me failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Test /api/users endpoint
    Write-Host ""
    Write-Host "   Testing /api/users endpoint..." -ForegroundColor Cyan
    try {
        $usersResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/users" -Method GET -Headers $headers
        
        Write-Host "   ✅ /api/users response:" -ForegroundColor Green
        Write-Host "      Status Code: $($usersResponse.StatusCode)" -ForegroundColor Cyan
        Write-Host "      Response Length: $($usersResponse.Content.Length) characters" -ForegroundColor Cyan
        
        $users = $usersResponse.Content | ConvertFrom-Json
        Write-Host "      Found $($users.Count) users" -ForegroundColor Cyan
    } catch {
        Write-Host "   ❌ /api/users failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Cannot test protected endpoints without authentication" -ForegroundColor Yellow
    Read-Host "Press Enter to continue..."
    exit 1
}

# Test 4: Simulate page navigation
Write-Host ""
Write-Host "4. Simulating Page Navigation..." -ForegroundColor Yellow
Write-Host "   Navigate to these pages in browser:" -ForegroundColor Cyan
Write-Host "   1. /dashboard (should call /api/users/me)" -ForegroundColor Cyan
Write-Host "   2. /pengguna (should call /api/users)" -ForegroundColor Cyan
Write-Host "   3. Back to /dashboard" -ForegroundColor Cyan
Write-Host "   4. Back to /pengguna" -ForegroundColor Cyan
Write-Host ""

# Test 5: Check for caching issues
Write-Host "5. Checking for Caching Issues..." -ForegroundColor Yellow
Write-Host "   Look for:" -ForegroundColor Cyan
Write-Host "   - Cache-Control headers" -ForegroundColor Cyan
Write-Host "   - ETag headers" -ForegroundColor Cyan
Write-Host "   - 304 Not Modified responses" -ForegroundColor Cyan
Write-Host ""

Write-Host "Double Hit Detailed Test completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Expected Results:" -ForegroundColor Yellow
Write-Host "✅ Single API call to /api/users/me per page load" -ForegroundColor Green
Write-Host "✅ Single API call to /api/users per page load" -ForegroundColor Green
Write-Host "✅ No duplicate requests in Network tab" -ForegroundColor Green
Write-Host "✅ Backend logs show single request per endpoint" -ForegroundColor Green
Write-Host ""
Write-Host "If you still see double hits:" -ForegroundColor Red
Write-Host "1. Check React.StrictMode in index.js" -ForegroundColor Yellow
Write-Host "2. Verify useEffect cleanup in AuthContext.js" -ForegroundColor Yellow
Write-Host "3. Verify useEffect cleanup in Pengguna.js" -ForegroundColor Yellow
Write-Host "4. Check for multiple component mounts" -ForegroundColor Yellow
Write-Host "5. Clear browser cache and hard refresh" -ForegroundColor Yellow

Read-Host "Press Enter to continue..."

