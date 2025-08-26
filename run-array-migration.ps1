# Array Fields Migration Script
# This script will add array fields for perbaikan and peminjaman requests
# to support multiple items like pengadaan requests.

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Array Fields Migration Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This script will add array fields for perbaikan and peminjaman requests" -ForegroundColor Yellow
Write-Host "to support multiple items like pengadaan requests." -ForegroundColor Yellow
Write-Host ""

Write-Host "Prerequisites:" -ForegroundColor Yellow
Write-Host "- PostgreSQL database is running" -ForegroundColor White
Write-Host "- Database connection details are configured" -ForegroundColor White
Write-Host "- You have admin privileges on the database" -ForegroundColor White
Write-Host ""

Read-Host "Press Enter to continue..."

Write-Host ""
Write-Host "Starting migration..." -ForegroundColor Green
Write-Host ""

# Check if psql is available
try {
    $psqlPath = Get-Command psql -ErrorAction Stop
    Write-Host "Found psql at: $($psqlPath.Source)" -ForegroundColor Green
} catch {
    Write-Host "ERROR: psql command not found. Please install PostgreSQL client tools." -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit 1
}

Write-Host "Running SQL migration script..." -ForegroundColor Green
Write-Host ""

# Database configuration - update these values according to your setup
$DB_NAME = "work_request_db"
$DB_USER = "postgres"
$DB_HOST = "localhost"
$DB_PORT = "5432"

Write-Host "Database: $DB_NAME" -ForegroundColor Cyan
Write-Host "User: $DB_USER" -ForegroundColor Cyan
Write-Host "Host: $DB_HOST" -ForegroundColor Cyan
Write-Host "Port: $DB_PORT" -ForegroundColor Cyan
Write-Host ""

# Check if migration script exists
$migrationScript = "backend\scripts\add-array-fields.sql"
if (-not (Test-Path $migrationScript)) {
    Write-Host "ERROR: Migration script not found at: $migrationScript" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit 1
}

Write-Host "Migration script found: $migrationScript" -ForegroundColor Green
Write-Host ""

# Run the migration script
try {
    $arguments = @(
        "-h", $DB_HOST,
        "-p", $DB_PORT,
        "-U", $DB_USER,
        "-d", $DB_NAME,
        "-f", $migrationScript
    )
    
    Write-Host "Executing: psql $($arguments -join ' ')" -ForegroundColor Gray
    Write-Host ""
    
    $result = & psql @arguments 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "Migration completed successfully!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "New array fields have been added:" -ForegroundColor Green
        Write-Host "- nama_barang_perbaikan_array[]" -ForegroundColor White
        Write-Host "- type_model_perbaikan_array[]" -ForegroundColor White
        Write-Host "- jumlah_perbaikan_array[]" -ForegroundColor White
        Write-Host "- jenis_pekerjaan_array[]" -ForegroundColor White
        Write-Host "- lokasi_perbaikan_array[]" -ForegroundColor White
        Write-Host "- lokasi_peminjaman_array[]" -ForegroundColor White
        Write-Host "- kegunaan_array[]" -ForegroundColor White
        Write-Host "- tgl_peminjaman_array[]" -ForegroundColor White
        Write-Host "- tgl_pengembalian_array[]" -ForegroundColor White
        Write-Host "- lokasi_array[]" -ForegroundColor White
        Write-Host ""
        Write-Host "Existing data has been migrated to maintain backward compatibility." -ForegroundColor Green
        Write-Host ""
        
        # Show migration results
        Write-Host "Migration Results:" -ForegroundColor Cyan
        Write-Host $result -ForegroundColor Gray
    } else {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Red
        Write-Host "Migration failed!" -ForegroundColor Red
        Write-Host "========================================" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please check the error messages above and fix any issues." -ForegroundColor Yellow
        Write-Host "Common issues:" -ForegroundColor Yellow
        Write-Host "- Database connection problems" -ForegroundColor White
        Write-Host "- Insufficient privileges" -ForegroundColor White
        Write-Host "- Database doesn't exist" -ForegroundColor White
        Write-Host ""
        Write-Host "Error output:" -ForegroundColor Red
        Write-Host $result -ForegroundColor Red
    }
} catch {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "Migration failed with exception!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Exception: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

Write-Host "Press Enter to exit..."
Read-Host
