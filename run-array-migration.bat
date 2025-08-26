@echo off
echo ========================================
echo Array Fields Migration Script
echo ========================================
echo.
echo This script will add array fields for perbaikan and peminjaman requests
echo to support multiple items like pengadaan requests.
echo.
echo Prerequisites:
echo - PostgreSQL database is running
echo - Database connection details are configured
echo - You have admin privileges on the database
echo.
pause

echo.
echo Starting migration...
echo.

REM Check if psql is available
where psql >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: psql command not found. Please install PostgreSQL client tools.
    pause
    exit /b 1
)

echo Running SQL migration script...
echo.

REM You need to update these values according to your database configuration
set DB_NAME=work_request_db
set DB_USER=postgres
set DB_HOST=localhost
set DB_PORT=5432

echo Database: %DB_NAME%
echo User: %DB_USER%
echo Host: %DB_HOST%
echo Port: %DB_PORT%
echo.

REM Run the migration script
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -f backend\scripts\add-array-fields.sql

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo Migration completed successfully!
    echo ========================================
    echo.
    echo New array fields have been added:
    echo - nama_barang_perbaikan_array[]
    echo - type_model_perbaikan_array[]
    echo - jumlah_perbaikan_array[]
    echo - jenis_pekerjaan_array[]
    echo - lokasi_perbaikan_array[]
    echo - lokasi_peminjaman_array[]
    echo - kegunaan_array[]
    echo - tgl_peminjaman_array[]
    echo - tgl_pengembalian_array[]
    echo - lokasi_array[]
    echo.
    echo Existing data has been migrated to maintain backward compatibility.
    echo.
) else (
    echo.
    echo ========================================
    echo Migration failed!
    echo ========================================
    echo.
    echo Please check the error messages above and fix any issues.
    echo Common issues:
    echo - Database connection problems
    echo - Insufficient privileges
    echo - Database doesn't exist
    echo.
)

echo Press any key to exit...
pause >nul
