# Test Menu Integration: Pengajuan, Persetujuan, dan Riwayat
Write-Host "Testing Menu Integration..." -ForegroundColor Green
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
    Write-Host "Cannot test menu endpoints without authentication" -ForegroundColor Yellow
    Read-Host "Press Enter to continue..."
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Test 3: Test Pengajuan (Create Request) endpoint
Write-Host ""
Write-Host "3. Testing Pengajuan (Create Request) Endpoint..." -ForegroundColor Yellow

$pengajuanData = @{
    jenis_request = "pengadaan"
    unit = "IT Department"
    nama_barang = "Laptop Development"
    type_model = "Dell Latitude 5520"
    jumlah = 3
    lokasi = "Kantor Pusat"
    jenis_pekerjaan = $null
    kegunaan = $null
    tgl_request = "2024-01-20"
    tgl_peminjaman = $null
    tgl_pengembalian = $null
    keterangan = "Laptop untuk tim development baru"
} | ConvertTo-Json

try {
    $createResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/requests" -Method POST -Headers $headers -Body $pengajuanData
    
    Write-Host "✅ Create request (Pengajuan) successful!" -ForegroundColor Green
    Write-Host "   Status Code: $($createResponse.StatusCode)" -ForegroundColor Cyan
    
    # Parse response
    $responseData = $createResponse.Content | ConvertFrom-Json
    Write-Host "   Success: $($responseData.success)" -ForegroundColor Cyan
    Write-Host "   Request ID: $($responseData.request.id)" -ForegroundColor Cyan
    Write-Host "   Jenis Request: $($responseData.request.jenis_request)" -ForegroundColor Cyan
    Write-Host "   Status: $($responseData.request.status_request)" -ForegroundColor Cyan
    
    $newRequestId = $responseData.request.id
    
} catch {
    Write-Host "❌ Create request (Pengajuan) failed: $($_.Exception.Message)" -ForegroundColor Red
    
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

# Test 4: Test Persetujuan (Get All Requests) endpoint
Write-Host ""
Write-Host "4. Testing Persetujuan (Get All Requests) Endpoint..." -ForegroundColor Yellow

try {
    $getAllResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/requests" -Method GET -Headers $headers
    
    Write-Host "✅ Get all requests (Persetujuan) successful!" -ForegroundColor Green
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
        
        # Check if there are pending requests for approval
        $pendingRequests = $responseData.data | Where-Object { $_.status_request -eq "DIAJUKAN" }
        Write-Host "   Pending Requests for Approval: $($pendingRequests.Count)" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host "❌ Get all requests (Persetujuan) failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Test Riwayat (Get My Requests) endpoint
Write-Host ""
Write-Host "5. Testing Riwayat (Get My Requests) Endpoint..." -ForegroundColor Yellow

try {
    $myRequestsResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/requests/my-requests" -Method GET -Headers $headers
    
    Write-Host "✅ Get my requests (Riwayat) successful!" -ForegroundColor Green
    Write-Host "   Status Code: $($myRequestsResponse.StatusCode)" -ForegroundColor Cyan
    
    # Parse response
    $responseData = $myRequestsResponse.Content | ConvertFrom-Json
    Write-Host "   My Requests Count: $($responseData.Count)" -ForegroundColor Cyan
    
    if ($responseData.Count -gt 0) {
        Write-Host "   My First Request:" -ForegroundColor Cyan
        Write-Host "     - ID: $($responseData[0].id)" -ForegroundColor Cyan
        Write-Host "     - Jenis: $($responseData[0].jenis_request)" -ForegroundColor Cyan
        Write-Host "     - Unit: $($responseData[0].unit)" -ForegroundColor Cyan
        Write-Host "     - Status: $($responseData[0].status_request)" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host "❌ Get my requests (Riwayat) failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: Test Update Request Status (Persetujuan workflow)
Write-Host ""
Write-Host "6. Testing Update Request Status (Persetujuan workflow)..." -ForegroundColor Yellow

if ($newRequestId) {
    $updateData = @{
        status_request = "DISETUJUI"
        approved_by = "hifdzul"
        keterangan = "Disetujui untuk testing"
    } | ConvertTo-Json
    
    try {
        $updateResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/requests/$newRequestId/status" -Method PUT -Headers $headers -Body $updateData
        
        Write-Host "✅ Update request status successful!" -ForegroundColor Green
        Write-Host "   Status Code: $($updateResponse.StatusCode)" -ForegroundColor Cyan
        
        # Parse response
        $responseData = $updateResponse.Content | ConvertFrom-Json
        Write-Host "   Message: $($responseData.message)" -ForegroundColor Cyan
        
    } catch {
        Write-Host "❌ Update request status failed: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "⚠️  Skipping status update test - no new request ID available" -ForegroundColor Yellow
}

# Test 7: Test Dashboard Stats endpoint
Write-Host ""
Write-Host "7. Testing Dashboard Stats Endpoint..." -ForegroundColor Yellow

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

# Test 8: Test different request types
Write-Host ""
Write-Host "8. Testing Different Request Types..." -ForegroundColor Yellow

# Test Perbaikan request
$perbaikanData = @{
    jenis_request = "perbaikan"
    unit = "Maintenance"
    nama_barang = "AC Split"
    type_model = "Panasonic 1 PK"
    jumlah = 1
    lokasi = "Ruang Meeting"
    jenis_pekerjaan = "Service AC tidak dingin"
    kegunaan = $null
    tgl_request = "2024-01-21"
    tgl_peminjaman = $null
    tgl_pengembalian = $null
    keterangan = "AC tidak dingin, perlu service"
} | ConvertTo-Json

try {
    $perbaikanResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/requests" -Method POST -Headers $headers -Body $perbaikanData
    
    Write-Host "✅ Create perbaikan request successful!" -ForegroundColor Green
    Write-Host "   Status Code: $($perbaikanResponse.StatusCode)" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Create perbaikan request failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Peminjaman request
$peminjamanData = @{
    jenis_request = "peminjaman"
    unit = "Marketing"
    nama_barang = "Projector"
    type_model = "Epson EB-X41"
    jumlah = 1
    lokasi = "Aula Utama"
    jenis_pekerjaan = $null
    kegunaan = "Presentasi client meeting"
    tgl_request = "2024-01-22"
    tgl_peminjaman = "2024-01-25"
    tgl_pengembalian = "2024-01-25"
    keterangan = "Untuk presentasi client meeting"
} | ConvertTo-Json

try {
    $peminjamanResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/requests" -Method POST -Headers $headers -Body $peminjamanData
    
    Write-Host "✅ Create peminjaman request successful!" -ForegroundColor Green
    Write-Host "   Status Code: $($peminjamanResponse.StatusCode)" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Create peminjaman request failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 9: Verify final data
Write-Host ""
Write-Host "9. Verifying Final Data..." -ForegroundColor Yellow

try {
    $finalResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/requests" -Method GET -Headers $headers
    $finalData = $finalResponse.Content | ConvertFrom-Json
    
    Write-Host "✅ Final verification successful!" -ForegroundColor Green
    Write-Host "   Total Requests: $($finalData.data.Count)" -ForegroundColor Cyan
    
    # Count by type
    $pengadaanCount = ($finalData.data | Where-Object { $_.jenis_request -eq "pengadaan" }).Count
    $perbaikanCount = ($finalData.data | Where-Object { $_.jenis_request -eq "perbaikan" }).Count
    $peminjamanCount = ($finalData.data | Where-Object { $_.jenis_request -eq "peminjaman" }).Count
    
    Write-Host "   Request Types:" -ForegroundColor Cyan
    Write-Host "     - Pengadaan: $pengadaanCount" -ForegroundColor Cyan
    Write-Host "     - Perbaikan: $perbaikanCount" -ForegroundColor Cyan
    Write-Host "     - Peminjaman: $peminjamanCount" -ForegroundColor Cyan
    
    # Count by status
    $diajukanCount = ($finalData.data | Where-Object { $_.status_request -eq "DIAJUKAN" }).Count
    $disetujuiCount = ($finalData.data | Where-Object { $_.status_request -eq "DISETUJUI" }).Count
    $ditolakCount = ($finalData.data | Where-Object { $_.status_request -eq "DITOLAK" }).Count
    
    Write-Host "   Request Statuses:" -ForegroundColor Cyan
    Write-Host "     - Diajukan: $diajukanCount" -ForegroundColor Cyan
    Write-Host "     - Disetujui: $disetujuiCount" -ForegroundColor Cyan
    Write-Host "     - Ditolak: $ditolakCount" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Final verification failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Menu Integration Test completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Expected Results:" -ForegroundColor Yellow
Write-Host "✅ Pengajuan: Create request endpoint returns 201" -ForegroundColor Green
Write-Host "✅ Persetujuan: Get all requests endpoint returns 200" -ForegroundColor Green
Write-Host "✅ Riwayat: Get my requests endpoint returns 200" -ForegroundColor Green
Write-Host "✅ Status Update: Update request status endpoint returns 200" -ForegroundColor Green
Write-Host "✅ Dashboard: Dashboard stats show correct counts" -ForegroundColor Green
Write-Host "✅ Request Types: All three types (pengadaan, perbaikan, peminjaman) work" -ForegroundColor Green
Write-Host ""
Write-Host "Integration Summary:" -ForegroundColor Cyan
Write-Host "   Pengajuan: Users can create new requests" -ForegroundColor Cyan
Write-Host "   Persetujuan: Operators can view and approve/reject requests" -ForegroundColor Cyan
Write-Host "   Riwayat: Users can view their request history" -ForegroundColor Cyan
Write-Host "   Dashboard: Real-time statistics for all users" -ForegroundColor Cyan
Write-Host "   Request Types: Unified table handles all request types" -ForegroundColor Cyan
Write-Host "   Status Flow: DIAJUKAN → DISETUJUI/DITOLAK → DIPROSES → SELESAI" -ForegroundColor Cyan

Read-Host "Press Enter to continue..."

