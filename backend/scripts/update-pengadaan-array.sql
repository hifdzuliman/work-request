-- Update Request Table Structure for Array Support
-- This script adds array fields for pengadaan requests

-- First, let's backup existing data
CREATE TABLE IF NOT EXISTS request_backup AS SELECT * FROM request;

-- Add new array columns for pengadaan
ALTER TABLE request 
ADD COLUMN nama_barang_array TEXT[],
ADD COLUMN type_model_array TEXT[],
ADD COLUMN jumlah_array INTEGER[],
ADD COLUMN keterangan_array TEXT[];

-- Update existing pengadaan records to use arrays
UPDATE request 
SET 
    nama_barang_array = ARRAY[nama_barang],
    type_model_array = ARRAY[type_model],
    jumlah_array = ARRAY[jumlah],
    keterangan_array = ARRAY[keterangan]
WHERE jenis_request = 'pengadaan';

-- Create a new table structure for better array support
CREATE TABLE IF NOT EXISTS request_new (
    id BIGSERIAL PRIMARY KEY,
    jenis_request VARCHAR(50) NOT NULL, -- pengadaan, perbaikan, peminjaman
    unit VARCHAR(100), -- unit/departemen yang request
    
    -- For pengadaan: array fields
    nama_barang_array TEXT[], -- array of item names
    type_model_array TEXT[], -- array of types/models
    jumlah_array INTEGER[], -- array of quantities
    keterangan_array TEXT[], -- array of descriptions
    
    -- For perbaikan: single fields
    nama_barang VARCHAR(200), -- single item name
    type_model VARCHAR(100), -- single type/model
    jumlah INTEGER, -- single quantity
    jenis_pekerjaan TEXT, -- jenis pekerjaan perbaikan
    
    -- For peminjaman: single fields
    lokasi VARCHAR(200), -- lokasi kerja / penggunaan
    kegunaan TEXT, -- kegunaan peminjaman
    tgl_peminjaman DATE,
    tgl_pengembalian DATE,
    
    -- Common fields
    tgl_request DATE,
    keterangan TEXT, -- general keterangan
    status_request VARCHAR(50) DEFAULT 'DIAJUKAN',
    requested_by VARCHAR(100),
    approved_by VARCHAR(100),
    accepted_by VARCHAR(100),
    created_at TIMESTAMP DEFAULT now(),
    updated_at TIMESTAMP DEFAULT now()
);

-- Migrate data to new structure
INSERT INTO request_new (
    id, jenis_request, unit, 
    nama_barang_array, type_model_array, jumlah_array, keterangan_array,
    nama_barang, type_model, jumlah, jenis_pekerjaan,
    lokasi, kegunaan, tgl_peminjaman, tgl_pengembalian,
    tgl_request, keterangan, status_request, requested_by, approved_by, accepted_by, created_at, updated_at
)
SELECT 
    id, jenis_request, unit,
    CASE WHEN jenis_request = 'pengadaan' THEN nama_barang_array ELSE NULL END,
    CASE WHEN jenis_request = 'pengadaan' THEN type_model_array ELSE NULL END,
    CASE WHEN jenis_request = 'pengadaan' THEN jumlah_array ELSE NULL END,
    CASE WHEN jenis_request = 'pengadaan' THEN keterangan_array ELSE NULL END,
    CASE WHEN jenis_request != 'pengadaan' THEN nama_barang ELSE NULL END,
    CASE WHEN jenis_request != 'pengadaan' THEN type_model ELSE NULL END,
    CASE WHEN jenis_request != 'pengadaan' THEN jumlah ELSE NULL END,
    jenis_pekerjaan,
    lokasi, kegunaan, tgl_peminjaman, tgl_pengembalian,
    tgl_request, keterangan, status_request, requested_by, approved_by, accepted_by, created_at, updated_at
FROM request;

-- Drop old table and rename new one
DROP TABLE request;
ALTER TABLE request_new RENAME TO request;

-- Recreate indexes
CREATE INDEX idx_request_jenis_request ON request(jenis_request);
CREATE INDEX idx_request_status_request ON request(status_request);
CREATE INDEX idx_request_requested_by ON request(requested_by);
CREATE INDEX idx_request_unit ON request(unit);
CREATE INDEX idx_request_tgl_request ON request(tgl_request);

-- Insert sample data for testing
INSERT INTO request (
    jenis_request, unit, 
    nama_barang_array, type_model_array, jumlah_array, keterangan_array,
    tgl_request, requested_by, status_request
) VALUES 
('pengadaan', 'IT Department', 
 ARRAY['Laptop Dell', 'Mouse Wireless', 'Keyboard Mechanical'], 
 ARRAY['Dell XPS 13', 'Logitech MX Master', 'Cherry MX Blue'], 
 ARRAY[5, 10, 8], 
 ARRAY['Untuk developer team', 'Untuk semua staff', 'Untuk developer team'],
 '2024-01-15', 'hifdzul', 'DIAJUKAN'
),
('pengadaan', 'HR Department', 
 ARRAY['Printer HP', 'Scanner Canon', 'Paper A4'], 
 ARRAY['HP LaserJet Pro', 'Canon CanoScan', 'Double A 80gsm'], 
 ARRAY[2, 1, 50], 
 ARRAY['Untuk print dokumen', 'Untuk scan dokumen', 'Untuk print dokumen'],
 '2024-01-16', 'hifdzul', 'DISETUJUI'
);

-- Show the new structure
\d request;

-- Show sample data
SELECT 
    id, jenis_request, unit, 
    nama_barang_array, type_model_array, jumlah_array, keterangan_array,
    nama_barang, type_model, jumlah, jenis_pekerjaan,
    lokasi, kegunaan, tgl_peminjaman, tgl_pengembalian,
    tgl_request, keterangan, status_request, requested_by, approved_by, accepted_by, created_at, updated_at
FROM request 
ORDER BY id;

