# Test Double API Hit Issue
Write-Host "Testing Double API Hit Prevention..." -ForegroundColor Green
Write-Host ""

# Test 1: Monitor API calls to users endpoint
Write-Host "1. Monitoring API calls to /api/users..." -ForegroundColor Yellow
Write-Host "   Navigate to /pengguna page in browser" -ForegroundColor Cyan
Write-Host "   Check Network tab for duplicate requests" -ForegroundColor Cyan
Write-Host ""

# Test 2: Check backend logs for multiple requests
Write-Host "2. Check Backend Logs..." -ForegroundColor Yellow
Write-Host "   Look for multiple GET /api/users requests" -ForegroundColor Cyan
Write-Host "   Should see only ONE request per page load" -ForegroundColor Green
Write-Host ""

# Test 3: Test with curl to verify single response
Write-Host "3. Testing Single API Call..." -ForegroundColor Yellow

# Login to get token
$loginData = @{
    username = "hifdzul"
    password = "admin123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    $token = $loginResponse.token
    Write-Host "✅ Login successful! Token obtained" -ForegroundColor Green
    
    # Test users endpoint
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    Write-Host "   Testing /api/users endpoint..." -ForegroundColor Cyan
    $usersResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/users" -Method GET -Headers $headers
    
    Write-Host "✅ Users endpoint response:" -ForegroundColor Green
    Write-Host "   Status Code: $($usersResponse.StatusCode)" -ForegroundColor Cyan
    Write-Host "   Response Length: $($usersResponse.Content.Length) characters" -ForegroundColor Cyan
    
    # Parse response
    $users = $usersResponse.Content | ConvertFrom-Json
    Write-Host "   Found $($users.Count) users" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Test failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Double Hit Test completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Expected Results:" -ForegroundColor Yellow
Write-Host "✅ Only ONE API call to /api/users per page load" -ForegroundColor Green
Write-Host "✅ No duplicate requests in Network tab" -ForegroundColor Green
Write-Host "✅ Backend logs show single request" -ForegroundColor Green
Write-Host ""
Write-Host "If you still see double hits:" -ForegroundColor Red
Write-Host "1. Check React.StrictMode in index.js" -ForegroundColor Yellow
Write-Host "2. Verify useEffect cleanup in Pengguna.js" -ForegroundColor Yellow
Write-Host "3. Clear browser cache and hard refresh" -ForegroundColor Yellow

Read-Host "Press Enter to continue..."

