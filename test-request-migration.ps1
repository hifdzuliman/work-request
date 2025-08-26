# Test Request Table Migration
Write-Host "Testing Request Table Migration..." -ForegroundColor Green
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
    Write-Host "Cannot test request endpoints without authentication" -ForegroundColor Yellow
    Read-Host "Press Enter to continue..."
    exit 1
}

# Test 3: Test Create Request endpoint
Write-Host ""
Write-Host "3. Testing Create Request Endpoint..." -ForegroundColor Yellow

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$requestData = @{
    jenis_request = "pengadaan"
    unit = "IT Department"
    nama_barang = "Laptop Test"
    type_model = "Dell Latitude 5520"
    jumlah = 1
    lokasi = "Kantor Pusat"
    jenis_pekerjaan = $null
    kegunaan = "Untuk testing migration"
    tgl_request = "2024-01-20"
    tgl_peminjaman = $null
    tgl_pengembalian = $null
    keterangan = "Request untuk testing migration table"
} | ConvertTo-Json

try {
    $createResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/requests" -Method POST -Headers $headers -Body $requestData
    
    Write-Host "✅ Create request endpoint successful!" -ForegroundColor Green
    Write-Host "   Status Code: $($createResponse.StatusCode)" -ForegroundColor Cyan
    
    # Parse response
    $responseData = $createResponse.Content | ConvertFrom-Json
    Write-Host "   Success: $($responseData.success)" -ForegroundColor Cyan
    Write-Host "   Request ID: $($responseData.request.id)" -ForegroundColor Cyan
    Write-Host "   Jenis Request: $($responseData.request.jenis_request)" -ForegroundColor Cyan
    Write-Host "   Status: $($responseData.request.status_request)" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Create request endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode
        Write-Host "   Status Code: $statusCode" -ForegroundColor Red
        
        if ($statusCode -eq 400) {
            Write-Host "   This means 'Bad Request' - check request data format" -ForegroundColor Yellow
        } elseif ($statusCode -eq 500) {
            Write-Host "   This means 'Internal Server Error' - check backend logs" -ForegroundColor Yellow
        }
    }
}

# Test 4: Test Get All Requests endpoint
Write-Host ""
Write-Host "4. Testing Get All Requests Endpoint..." -ForegroundColor Yellow

try {
    $getAllResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/requests" -Method GET -Headers $headers
    
    Write-Host "✅ Get all requests endpoint successful!" -ForegroundColor Green
    Write-Host "   Status Code: $($getAllResponse.StatusCode)" -ForegroundColor Cyan
    
    # Parse response
    $responseData = $getAllResponse.Content | ConvertFrom-Json
    Write-Host "   Total Requests: $($responseData.data.Count)" -ForegroundColor Cyan
    
    if ($responseData.data.Count -gt 0) {
        Write-Host "   First Request:" -ForegroundColor Cyan
        Write-Host "     - ID: $($responseData.data[0].id)" -ForegroundColor Cyan
        Write-Host "     - Jenis: $($responseData.data[0].jenis_request)" -ForegroundColor Cyan
        Write-Host "     - Unit: $($responseData.data[0].unit)" -ForegroundColor Cyan
        Write-Host "     - Status: $($responseData.data[0].status_request)" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host "❌ Get all requests endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
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

# Test 6: Verify Database Migration
Write-Host ""
Write-Host "6. Database Migration Verification..." -ForegroundColor Yellow
Write-Host "   To verify database migration:" -ForegroundColor Cyan
Write-Host "   1. Check if 'request' table exists" -ForegroundColor Cyan
Write-Host "   2. Verify table structure matches new schema" -ForegroundColor Cyan
Write-Host "   3. Check if old tables (work_requests, activities, items) are removed" -ForegroundColor Cyan

Write-Host ""
Write-Host "Request Table Migration Test completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Expected Results:" -ForegroundColor Yellow
Write-Host "✅ Create request endpoint returns 201" -ForegroundColor Green
Write-Host "✅ Get all requests endpoint returns 200" -ForegroundColor Green
Write-Host "✅ Dashboard stats show correct counts" -ForegroundColor Green
Write-Host "✅ New request table structure is working" -ForegroundColor Green
Write-Host ""
Write-Host "Migration Summary:" -ForegroundColor Cyan
Write-Host "   Old: work_requests, activities, items tables" -ForegroundColor Cyan
Write-Host "   New: request table with unified structure" -ForegroundColor Cyan
Write-Host "   Features: pengadaan, perbaikan, peminjaman" -ForegroundColor Cyan
Write-Host "   Status: DIAJUKAN, DISETUJUI, DITOLAK, DIPROSES, SELESAI" -ForegroundColor Cyan

Read-Host "Press Enter to continue..."

