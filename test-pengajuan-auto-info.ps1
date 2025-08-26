# Test Pengajuan Auto Information
Write-Host "Testing Pengajuan Auto Information..." -ForegroundColor Green
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

# Test 2: Login to get token and user info
Write-Host ""
Write-Host "2. Testing Login and User Info..." -ForegroundColor Yellow

$loginData = @{
    username = "hifdzul"
    password = "admin123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    $token = $loginResponse.token
    $userInfo = $loginResponse.user
    Write-Host "✅ Login successful! Token obtained" -ForegroundColor Green
    Write-Host "   User: $($userInfo.name) (Role: $($userInfo.role))" -ForegroundColor Cyan
    Write-Host "   Unit: $($userInfo.unit)" -ForegroundColor Cyan
    Write-Host "   Email: $($userInfo.email)" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Cannot test endpoints without authentication" -ForegroundColor Yellow
    Read-Host "Press Enter to continue..."
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Test 3: Create Pengadaan Request (Auto-filled info)
Write-Host ""
Write-Host "3. Testing Create Pengadaan Request with Auto-filled Info..." -ForegroundColor Yellow

$pengadaanData = @{
    jenis_request = "pengadaan"
    nama_barang_array = @("Laptop Dell", "Mouse Wireless")
    type_model_array = @("Dell XPS 13", "Logitech MX Master")
    jumlah_array = @(2, 5)
    keterangan_array = @("Untuk developer team", "Untuk semua staff")
    keterangan = "Pengajuan peralatan IT untuk tim development"
} | ConvertTo-Json

try {
    $pengadaanResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/requests" -Method POST -Body $pengadaanData -Headers $headers
    
    Write-Host "✅ Create pengadaan request successful!" -ForegroundColor Green
    Write-Host "   Status Code: $($pengadaanResponse.StatusCode)" -ForegroundColor Cyan
    
    # Parse response
    $responseData = $pengadaanResponse.Content | ConvertFrom-Json
    Write-Host "   Response Type: $($responseData.GetType().Name)" -ForegroundColor Cyan
    
    if ($responseData.data) {
        Write-Host "   Created Request ID: $($responseData.data.id)" -ForegroundColor Cyan
        Write-Host "   Jenis Request: $($responseData.data.jenis_request)" -ForegroundColor Cyan
        Write-Host "   Unit (Auto-filled): $($responseData.data.unit)" -ForegroundColor Cyan
        Write-Host "   Tanggal Request (Auto-filled): $($responseData.data.tgl_request)" -ForegroundColor Cyan
        Write-Host "   Requested By (Auto-filled): $($responseData.data.requested_by)" -ForegroundColor Cyan
        Write-Host "   Status: $($responseData.data.status_request)" -ForegroundColor Cyan
        
        # Verify auto-filled information
        if ($responseData.data.unit -eq $userInfo.unit) {
            Write-Host "   ✅ Unit correctly auto-filled from user data" -ForegroundColor Green
        } else {
            Write-Host "   ❌ Unit not correctly auto-filled" -ForegroundColor Red
        }
        
        if ($responseData.data.requested_by -eq $userInfo.name) {
            Write-Host "   ✅ Requested By correctly auto-filled from user data" -ForegroundColor Green
        } else {
            Write-Host "   ❌ Requested By not correctly auto-filled" -ForegroundColor Red
        }
        
        # Check array fields
        if ($responseData.data.nama_barang_array) {
            Write-Host "   Nama Barang Array: $($responseData.data.nama_barang_array -join ', ')" -ForegroundColor Cyan
            Write-Host "   Type Model Array: $($responseData.data.type_model_array -join ', ')" -ForegroundColor Cyan
            Write-Host "   Jumlah Array: $($responseData.data.jumlah_array -join ', ')" -ForegroundColor Cyan
            Write-Host "   Keterangan Array: $($responseData.data.keterangan_array -join ', ')" -ForegroundColor Cyan
        }
    }
    
} catch {
    Write-Host "❌ Create pengadaan request failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Create Perbaikan Request (Auto-filled info)
Write-Host ""
Write-Host "4. Testing Create Perbaikan Request with Auto-filled Info..." -ForegroundColor Yellow

$perbaikanData = @{
    jenis_request = "perbaikan"
    nama_barang = "Printer HP"
    type_model = "HP LaserJet Pro"
    jumlah = 1
    jenis_pekerjaan = "Ganti cartridge dan service"
    lokasi = "Ruang Admin, Lantai 1"
    keterangan = "Printer bermasalah, perlu maintenance"
} | ConvertTo-Json

try {
    $perbaikanResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/requests" -Method POST -Body $perbaikanData -Headers $headers
    
    Write-Host "✅ Create perbaikan request successful!" -ForegroundColor Green
    Write-Host "   Status Code: $($perbaikanResponse.StatusCode)" -ForegroundColor Cyan
    
    # Parse response
    $responseData = $perbaikanResponse.Content | ConvertFrom-Json
    Write-Host "   Response Type: $($responseData.GetType().Name)" -ForegroundColor Cyan
    
    if ($responseData.data) {
        Write-Host "   Created Request ID: $($responseData.data.id)" -ForegroundColor Cyan
        Write-Host "   Jenis Request: $($responseData.data.jenis_request)" -ForegroundColor Cyan
        Write-Host "   Unit (Auto-filled): $($responseData.data.unit)" -ForegroundColor Cyan
        Write-Host "   Tanggal Request (Auto-filled): $($responseData.data.tgl_request)" -ForegroundColor Cyan
        Write-Host "   Requested By (Auto-filled): $($responseData.data.requested_by)" -ForegroundColor Cyan
        Write-Host "   Nama Barang: $($responseData.data.nama_barang)" -ForegroundColor Cyan
        Write-Host "   Type Model: $($responseData.data.type_model)" -ForegroundColor Cyan
        Write-Host "   Jumlah: $($responseData.data.jumlah)" -ForegroundColor Cyan
        Write-Host "   Jenis Pekerjaan: $($responseData.data.jenis_pekerjaan)" -ForegroundColor Cyan
        Write-Host "   Lokasi: $($responseData.data.lokasi)" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host "❌ Create perbaikan request failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Create Peminjaman Request (Auto-filled info)
Write-Host ""
Write-Host "5. Testing Create Peminjaman Request with Auto-filled Info..." -ForegroundColor Yellow

$peminjamanData = @{
    jenis_request = "peminjaman"
    lokasi = "Ruang Meeting VIP, Lantai 3"
    kegunaan = "Meeting dengan client penting"
    tgl_peminjaman = "2024-01-25"
    tgl_pengembalian = "2024-01-25"
    keterangan = "Meeting dengan client untuk project baru"
} | ConvertTo-Json

try {
    $peminjamanResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/requests" -Method POST -Body $peminjamanData -Headers $headers
    
    Write-Host "✅ Create peminjaman request successful!" -ForegroundColor Green
    Write-Host "   Status Code: $($peminjamanResponse.StatusCode)" -ForegroundColor Cyan
    
    # Parse response
    $responseData = $peminjamanResponse.Content | ConvertFrom-Json
    Write-Host "   Response Type: $($responseData.GetType().Name)" -ForegroundColor Cyan
    
    if ($responseData.data) {
        Write-Host "   Created Request ID: $($responseData.data.id)" -ForegroundColor Cyan
        Write-Host "   Jenis Request: $($responseData.data.jenis_request)" -ForegroundColor Cyan
        Write-Host "   Unit (Auto-filled): $($responseData.data.unit)" -ForegroundColor Cyan
        Write-Host "   Tanggal Request (Auto-filled): $($responseData.data.tgl_request)" -ForegroundColor Cyan
        Write-Host "   Requested By (Auto-filled): $($responseData.data.requested_by)" -ForegroundColor Cyan
        Write-Host "   Lokasi: $($responseData.data.lokasi)" -ForegroundColor Cyan
        Write-Host "   Kegunaan: $($responseData.data.kegunaan)" -ForegroundColor Cyan
        Write-Host "   Tanggal Peminjaman: $($responseData.data.tgl_peminjaman)" -ForegroundColor Cyan
        Write-Host "   Tanggal Pengembalian: $($responseData.data.tgl_pengembalian)" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host "❌ Create peminjaman request failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: Verify All Requests Have Auto-filled Info
Write-Host ""
Write-Host "6. Verifying All Requests Have Auto-filled Info..." -ForegroundColor Yellow

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
        
        # Check auto-filled fields for all requests
        $autoFilledCorrectly = 0
        foreach ($request in $responseData.data) {
            if ($request.unit -eq $userInfo.unit -and $request.requested_by -eq $userInfo.name) {
                $autoFilledCorrectly++
            }
        }
        
        Write-Host "   Requests with correct auto-filled info: $autoFilledCorrectly/$($responseData.data.Count)" -ForegroundColor Cyan
        
        if ($autoFilledCorrectly -eq $responseData.data.Count) {
            Write-Host "   ✅ All requests have correctly auto-filled information!" -ForegroundColor Green
        } else {
            Write-Host "   ❌ Some requests are missing auto-filled information" -ForegroundColor Red
        }
        
        # Show sample of auto-filled data
        if ($responseData.data.Count -gt 0) {
            $sampleRequest = $responseData.data[0]
            Write-Host "   Sample Request Auto-filled Info:" -ForegroundColor Cyan
            Write-Host "     - Unit: $($sampleRequest.unit) (User Unit: $($userInfo.unit))" -ForegroundColor Cyan
            Write-Host "     - Requested By: $($sampleRequest.requested_by) (User Name: $($userInfo.name))" -ForegroundColor Cyan
            Write-Host "     - Tanggal Request: $($sampleRequest.tgl_request)" -ForegroundColor Cyan
        }
    } else {
        Write-Host "   Data Structure: Direct array" -ForegroundColor Cyan
        Write-Host "   Total Requests: $($responseData.Count)" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host "❌ Get all requests failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Pengajuan Auto Information Test completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Expected Results:" -ForegroundColor Yellow
Write-Host "✅ Unit automatically filled from logged-in user data" -ForegroundColor Green
Write-Host "✅ Tanggal Request automatically filled with current date" -ForegroundColor Green
Write-Host "✅ Requested By automatically filled from logged-in user name" -ForegroundColor Green
Write-Host "✅ No manual input required for basic information" -ForegroundColor Green
Write-Host "✅ All request types work with auto-filled information" -ForegroundColor Green
Write-Host ""
Write-Host "Auto-filled Information Summary:" -ForegroundColor Cyan
Write-Host "   Unit: Automatically from user.unit" -ForegroundColor Cyan
Write-Host "   Tanggal Request: Automatically current date" -ForegroundColor Cyan
Write-Host "   Requested By: Automatically from user.name" -ForegroundColor Cyan
Write-Host ""
Write-Host "Frontend Changes:" -ForegroundColor Cyan
Write-Host "   - Removed manual input fields for unit and tanggal request" -ForegroundColor Cyan
Write-Host "   - Added display-only section showing auto-filled information" -ForegroundColor Cyan
Write-Host "   - Form state simplified (no unit/tgl_request in formData)" -ForegroundColor Cyan
Write-Host "   - handleSubmit automatically fills required fields" -ForegroundColor Cyan
Write-Host ""
Write-Host "User Experience Improvements:" -ForegroundColor Cyan
Write-Host "   - Faster form completion (less fields to fill)" -ForegroundColor Cyan
Write-Host "   - Reduced input errors (auto-filled data is always correct)" -ForegroundColor Cyan
Write-Host "   - Better UX (information clearly displayed but not editable)" -ForegroundColor Cyan

Read-Host "Press Enter to continue..."

