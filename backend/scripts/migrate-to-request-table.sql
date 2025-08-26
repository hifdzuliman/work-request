-- Migration Script: Change work_request table to request table
-- Run this script to update the database schema

-- Step 1: Drop existing tables (if they exist)
DROP TABLE IF EXISTS items CASCADE;
DROP TABLE IF EXISTS activities CASCADE;
DROP TABLE IF EXISTS work_requests CASCADE;

-- Step 2: Create new request table
CREATE TABLE request (
    id BIGSERIAL PRIMARY KEY,
    jenis_request VARCHAR(50) NOT NULL,   -- pengadaan, perbaikan, peminjaman
    unit VARCHAR(100),                    -- unit/departemen yang request
    nama_barang VARCHAR(200),
    type_model VARCHAR(100),
    jumlah INT,
    lokasi VARCHAR(200),                  -- lokasi kerja / penggunaan
    jenis_pekerjaan TEXT,                 -- kalau request perbaikan/maintenance
    kegunaan TEXT,                        -- kalau peminjaman
    tgl_request DATE,
    tgl_peminjaman DATE,
    tgl_pengembalian DATE,
    keterangan TEXT,
    status_request VARCHAR(50) DEFAULT 'DIAJUKAN',
    requested_by VARCHAR(100),
    approved_by VARCHAR(100),
    accepted_by VARCHAR(100),
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

-- Step 3: Create indexes for better performance
CREATE INDEX idx_request_jenis_request ON request(jenis_request);
CREATE INDEX idx_request_unit ON request(unit);
CREATE INDEX idx_request_status_request ON request(status_request);
CREATE INDEX idx_request_requested_by ON request(requested_by);
CREATE INDEX idx_request_tgl_request ON request(tgl_request);

-- Step 4: Insert sample data for testing
INSERT INTO request (
    jenis_request, 
    unit, 
    nama_barang, 
    type_model, 
    jumlah, 
    lokasi, 
    jenis_pekerjaan, 
    kegunaan, 
    tgl_request, 
    tgl_peminjaman, 
    tgl_pengembalian, 
    keterangan, 
    status_request, 
    requested_by, 
    approved_by, 
    accepted_by
) VALUES 
    ('pengadaan', 'IT Department', 'Laptop', 'Dell Latitude 5520', 2, 'Kantor Pusat', NULL, 'Untuk tim development', '2024-01-15', NULL, NULL, 'Laptop untuk tim development baru', 'DIAJUKAN', 'hifdzul', NULL, NULL),
    ('perbaikan', 'Maintenance', 'AC Split', 'Panasonic 1 PK', 1, 'Ruang Meeting', 'Service AC', NULL, '2024-01-16', NULL, NULL, 'AC tidak dingin, perlu service', 'DIAJUKAN', 'hifdzul', NULL, NULL),
    ('peminjaman', 'Marketing', 'Projector', 'Epson EB-X41', 1, 'Aula Utama', NULL, 'Presentasi client meeting', '2024-01-17', '2024-01-20', '2024-01-20', 'Untuk presentasi client meeting', 'DIAJUKAN', 'hifdzul', NULL, NULL);

-- Step 5: Verify the new table structure
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns 
WHERE table_name = 'request' 
ORDER BY ordinal_position;

-- Step 6: Verify sample data
SELECT * FROM request;

