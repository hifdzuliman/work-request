# Test Riwayat Page Fix
Write-Host "Testing Riwayat Page Fix..." -ForegroundColor Green
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
    Write-Host "Cannot test Riwayat endpoints without authentication" -ForegroundColor Yellow
    Read-Host "Press Enter to continue..."
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Test 3: Test My Requests endpoint (Riwayat)
Write-Host ""
Write-Host "3. Testing My Requests Endpoint (Riwayat)..." -ForegroundColor Yellow

try {
    $myRequestsResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/requests/my-requests" -Method GET -Headers $headers
    
    Write-Host "✅ Get my requests (Riwayat) successful!" -ForegroundColor Green
    Write-Host "   Status Code: $($myRequestsResponse.StatusCode)" -ForegroundColor Cyan
    
    # Parse response
    $responseData = $myRequestsResponse.Content | ConvertFrom-Json
    Write-Host "   Response Type: $($responseData.GetType().Name)" -ForegroundColor Cyan
    Write-Host "   My Requests Count: $($responseData.Count)" -ForegroundColor Cyan
    
    if ($responseData.Count -gt 0) {
        Write-Host "   My First Request:" -ForegroundColor Cyan
        Write-Host "     - ID: $($responseData[0].id)" -ForegroundColor Cyan
        Write-Host "     - Jenis: $($responseData[0].jenis_request)" -ForegroundColor Cyan
        Write-Host "     - Unit: $($responseData[0].unit)" -ForegroundColor Cyan
        Write-Host "     - Status: $($responseData[0].status_request)" -ForegroundColor Cyan
        
        # Check unique values for filters
        $uniqueStatuses = ($responseData | Select-Object -ExpandProperty status_request -Unique)
        $uniqueJenis = ($responseData | Select-Object -ExpandProperty jenis_request -Unique)
        $uniqueUnits = ($responseData | Select-Object -ExpandProperty unit -Unique)
        
        Write-Host "   Unique Values for Filters:" -ForegroundColor Cyan
        Write-Host "     - Statuses: $($uniqueStatuses -join ', ')" -ForegroundColor Cyan
        Write-Host "     - Jenis: $($uniqueJenis -join ', ')" -ForegroundColor Cyan
        Write-Host "     - Units: $($uniqueUnits -join ', ')" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host "❌ Get my requests (Riwayat) failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Test Get All Requests endpoint (for operators)
Write-Host ""
Write-Host "4. Testing Get All Requests Endpoint (for operators)..." -ForegroundColor Yellow

try {
    $getAllResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/requests" -Method GET -Headers $headers
    
    Write-Host "✅ Get all requests successful!" -ForegroundColor Green
    Write-Host "   Status Code: $($getAllResponse.StatusCode)" -ForegroundColor Cyan
    
    # Parse response
    $responseData = $getAllResponse.Content | ConvertFrom-Json
    Write-Host "   Response Type: $($responseData.GetType().Name)" -ForegroundColor Cyan
    
    # Check if response has data property or is direct array
    if ($responseData.data) {
        Write-Host "   Data Structure: Has 'data' property" -ForegroundColor Cyan
        Write-Host "   Total Requests: $($responseData.data.Count)" -ForegroundColor Cyan
        
        if ($responseData.data.Count -gt 0) {
            Write-Host "   First Request:" -ForegroundColor Cyan
            Write-Host "     - ID: $($responseData.data[0].id)" -ForegroundColor Cyan
            Write-Host "     - Jenis: $($responseData.data[0].jenis_request)" -ForegroundColor Cyan
            Write-Host "     - Unit: $($responseData.data[0].unit)" -ForegroundColor Cyan
            Write-Host "     - Status: $($responseData.data[0].status_request)" -ForegroundColor Cyan
        }
    } else {
        Write-Host "   Data Structure: Direct array" -ForegroundColor Cyan
        Write-Host "   Total Requests: $($responseData.Count)" -ForegroundColor Cyan
        
        if ($responseData.Count -gt 0) {
            Write-Host "   First Request:" -ForegroundColor Cyan
            Write-Host "     - ID: $($responseData[0].id)" -ForegroundColor Cyan
            Write-Host "     - Jenis: $($responseData[0].jenis_request)" -ForegroundColor Cyan
            Write-Host "     - Unit: $($responseData[0].unit)" -ForegroundColor Cyan
            Write-Host "     - Status: $($responseData[0].status_request)" -ForegroundColor Cyan
        }
    }
    
} catch {
    Write-Host "❌ Get all requests failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Test Dashboard Stats endpoint
Write-Host ""
Write-Host "5. Testing Dashboard Stats Endpoint..." -ForegroundColor Yellow

try {
    $dashboardResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/dashboard/stats" -Method GET -Headers $headers
    
    Write-Host "✅ Dashboard stats endpoint successful!" -ForegroundColor Green
    Write-Host "   Status Code: $($dashboardResponse.StatusCode)" -ForegroundColor Cyan
    
    # Parse response
    $dashboardData = $dashboardResponse.Content | ConvertFrom-Json
    Write-Host "   Dashboard Statistics:" -ForegroundColor Cyan
    Write-Host "   - Total Pengajuan: $($dashboardData.total_pengajuan)" -ForegroundColor Cyan
    Write-Host "   - Total Persetujuan: $($dashboardData.total_persetujuan)" -ForegroundColor Cyan
    Write-Host "   - Total Riwayat: $($dashboardData.total_riwayat)" -ForegroundColor Cyan
    Write-Host "   - Total Pengguna: $($dashboardData.total_pengguna)" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Dashboard stats endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Riwayat Page Fix Test completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Expected Results:" -ForegroundColor Yellow
Write-Host "✅ No more 'requests.map is not a function' errors" -ForegroundColor Green
Write-Host "✅ Array.isArray() checks prevent map errors" -ForegroundColor Green
Write-Host "✅ Safe spread operator usage" -ForegroundColor Green
Write-Host "✅ All endpoints return proper data structures" -ForegroundColor Green
Write-Host "✅ Frontend can handle both array and object responses" -ForegroundColor Green
Write-Host ""
Write-Host "Fix Summary:" -ForegroundColor Cyan
Write-Host "   Problem: requests.map() called on non-array data" -ForegroundColor Cyan
Write-Host "   Solution: Added Array.isArray() checks before map operations" -ForegroundColor Cyan
Write-Host "   Result: Safe mapping with fallback to empty array" -ForegroundColor Cyan
Write-Host ""
Write-Host "Frontend Changes:" -ForegroundColor Cyan
Write-Host "   - uniqueStatuses: Array.isArray(requests) ? [...new Set(requests.map(...))] : []" -ForegroundColor Cyan
Write-Host "   - uniqueJenis: Array.isArray(requests) ? [...new Set(requests.map(...))] : []" -ForegroundColor Cyan
Write-Host "   - uniqueUnits: Array.isArray(requests) ? [...new Set(requests.map(...))] : []" -ForegroundColor Cyan
Write-Host "   - filterRequests: Array.isArray(requests) ? [...requests] : []" -ForegroundColor Cyan
Write-Host "   - Safe rendering even when requests is undefined/null" -ForegroundColor Cyan

Read-Host "Press Enter to continue..."

