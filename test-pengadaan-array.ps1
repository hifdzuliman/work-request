# Test Pengadaan Array Fields
Write-Host "Testing Pengadaan Array Fields..." -ForegroundColor Green
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
    Write-Host "Cannot test endpoints without authentication" -ForegroundColor Yellow
    Read-Host "Press Enter to continue..."
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Test 3: Create Pengadaan Request with Array Fields
Write-Host ""
Write-Host "3. Testing Create Pengadaan Request with Array Fields..." -ForegroundColor Yellow

$pengadaanData = @{
    jenis_request = "pengadaan"
    unit = "IT Department"
    nama_barang_array = @("Laptop Dell", "Mouse Wireless", "Keyboard Mechanical")
    type_model_array = @("Dell XPS 13", "Logitech MX Master", "Cherry MX Blue")
    jumlah_array = @(5, 10, 8)
    keterangan_array = @("Untuk developer team", "Untuk semua staff", "Untuk developer team")
    tgl_request = "2024-01-20"
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
        Write-Host "   Unit: $($responseData.data.unit)" -ForegroundColor Cyan
        Write-Host "   Status: $($responseData.data.status_request)" -ForegroundColor Cyan
        
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

# Test 4: Create Perbaikan Request (Single Fields)
Write-Host ""
Write-Host "4. Testing Create Perbaikan Request (Single Fields)..." -ForegroundColor Yellow

$perbaikanData = @{
    jenis_request = "perbaikan"
    unit = "Maintenance Department"
    nama_barang = "Printer HP"
    type_model = "HP LaserJet Pro"
    jumlah = 2
    jenis_pekerjaan = "Ganti cartridge dan service"
    lokasi = "Ruang Admin, Lantai 1"
    tgl_request = "2024-01-20"
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
        Write-Host "   Nama Barang: $($responseData.data.nama_barang)" -ForegroundColor Cyan
        Write-Host "   Type Model: $($responseData.data.type_model)" -ForegroundColor Cyan
        Write-Host "   Jumlah: $($responseData.data.jumlah)" -ForegroundColor Cyan
        Write-Host "   Jenis Pekerjaan: $($responseData.data.jenis_pekerjaan)" -ForegroundColor Cyan
        Write-Host "   Lokasi: $($responseData.data.lokasi)" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host "❌ Create perbaikan request failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Create Peminjaman Request (Single Fields)
Write-Host ""
Write-Host "5. Testing Create Peminjaman Request (Single Fields)..." -ForegroundColor Yellow

$peminjamanData = @{
    jenis_request = "peminjaman"
    unit = "Marketing Department"
    lokasi = "Ruang Meeting VIP, Lantai 3"
    kegunaan = "Meeting dengan client penting"
    tgl_peminjaman = "2024-01-25"
    tgl_pengembalian = "2024-01-25"
    tgl_request = "2024-01-20"
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
        Write-Host "   Lokasi: $($responseData.data.lokasi)" -ForegroundColor Cyan
        Write-Host "   Kegunaan: $($responseData.data.kegunaan)" -ForegroundColor Cyan
        Write-Host "   Tanggal Peminjaman: $($responseData.data.tgl_peminjaman)" -ForegroundColor Cyan
        Write-Host "   Tanggal Pengembalian: $($responseData.data.tgl_pengembalian)" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host "❌ Create peminjaman request failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: Get All Requests to Verify Data
Write-Host ""
Write-Host "6. Testing Get All Requests to Verify Data..." -ForegroundColor Yellow

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
        
        # Find pengadaan requests
        $pengadaanRequests = $responseData.data | Where-Object { $_.jenis_request -eq "pengadaan" }
        Write-Host "   Pengadaan Requests: $($pengadaanRequests.Count)" -ForegroundColor Cyan
        
        if ($pengadaanRequests.Count -gt 0) {
            $latestPengadaan = $pengadaanRequests | Sort-Object id -Descending | Select-Object -First 1
            Write-Host "   Latest Pengadaan Request:" -ForegroundColor Cyan
            Write-Host "     - ID: $($latestPengadaan.id)" -ForegroundColor Cyan
            Write-Host "     - Unit: $($latestPengadaan.unit)" -ForegroundColor Cyan
            Write-Host "     - Nama Barang Array: $($latestPengadaan.nama_barang_array -join ', ')" -ForegroundColor Cyan
            Write-Host "     - Type Model Array: $($latestPengadaan.type_model_array -join ', ')" -ForegroundColor Cyan
            Write-Host "     - Jumlah Array: $($latestPengadaan.jumlah_array -join ', ')" -ForegroundColor Cyan
            Write-Host "     - Keterangan Array: $($latestPengadaan.keterangan_array -join ', ')" -ForegroundColor Cyan
        }
        
        # Find perbaikan requests
        $perbaikanRequests = $responseData.data | Where-Object { $_.jenis_request -eq "perbaikan" }
        Write-Host "   Perbaikan Requests: $($perbaikanRequests.Count)" -ForegroundColor Cyan
        
        # Find peminjaman requests
        $peminjamanRequests = $responseData.data | Where-Object { $_.jenis_request -eq "peminjaman" }
        Write-Host "   Peminjaman Requests: $($peminjamanRequests.Count)" -ForegroundColor Cyan
    } else {
        Write-Host "   Data Structure: Direct array" -ForegroundColor Cyan
        Write-Host "   Total Requests: $($responseData.Count)" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host "❌ Get all requests failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Pengadaan Array Fields Test completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Expected Results:" -ForegroundColor Yellow
Write-Host "✅ Pengadaan requests support array fields" -ForegroundColor Green
Write-Host "✅ Perbaikan requests use single fields" -ForegroundColor Green
Write-Host "✅ Peminjaman requests use single fields" -ForegroundColor Green
Write-Host "✅ All request types can be created successfully" -ForegroundColor Green
Write-Host "✅ Array fields are properly stored and retrieved" -ForegroundColor Green
Write-Host ""
Write-Host "Array Fields Summary:" -ForegroundColor Cyan
Write-Host "   Pengadaan: nama_barang_array[], type_model_array[], jumlah_array[], keterangan_array[]" -ForegroundColor Cyan
Write-Host "   Perbaikan: nama_barang, type_model, jumlah, jenis_pekerjaan, lokasi" -ForegroundColor Cyan
Write-Host "   Peminjaman: lokasi, kegunaan, tgl_peminjaman, tgl_pengembalian" -ForegroundColor Cyan
Write-Host ""
Write-Host "Frontend Features:" -ForegroundColor Cyan
Write-Host "   - Dynamic form fields based on request type" -ForegroundColor Cyan
Write-Host "   - Add/remove item rows for pengadaan" -ForegroundColor Cyan
Write-Host "   - Conditional validation for each request type" -ForegroundColor Cyan
Write-Host "   - Array data handling and submission" -ForegroundColor Cyan

Read-Host "Press Enter to continue..."

