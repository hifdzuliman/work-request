-- Migration script to add array fields for perbaikan and peminjaman requests
-- This script adds support for multiple items in repair and borrowing requests

-- Add array fields for perbaikan requests
ALTER TABLE requests 
ADD COLUMN nama_barang_perbaikan_array TEXT[],
ADD COLUMN type_model_perbaikan_array TEXT[],
ADD COLUMN jumlah_perbaikan_array INTEGER[],
ADD COLUMN jenis_pekerjaan_array TEXT[],
ADD COLUMN lokasi_perbaikan_array TEXT[];

-- Add array fields for peminjaman requests
ALTER TABLE requests 
ADD COLUMN lokasi_peminjaman_array TEXT[],
ADD COLUMN kegunaan_array TEXT[],
ADD COLUMN tgl_peminjaman_array TIMESTAMP[],
ADD COLUMN tgl_pengembalian_array TIMESTAMP[];

-- Add array fields for general use (can be used by any request type)
ALTER TABLE requests 
ADD COLUMN lokasi_array TEXT[];

-- Create indexes for better performance on array fields
CREATE INDEX idx_requests_nama_barang_perbaikan_array ON requests USING GIN (nama_barang_perbaikan_array);
CREATE INDEX idx_requests_lokasi_peminjaman_array ON requests USING GIN (lokasi_peminjaman_array);
CREATE INDEX idx_requests_lokasi_array ON requests USING GIN (lokasi_array);

-- Add comments to document the new fields
COMMENT ON COLUMN requests.nama_barang_perbaikan_array IS 'Array of item names for repair requests';
COMMENT ON COLUMN requests.type_model_perbaikan_array IS 'Array of item types/models for repair requests';
COMMENT ON COLUMN requests.jumlah_perbaikan_array IS 'Array of item quantities for repair requests';
COMMENT ON COLUMN requests.jenis_pekerjaan_array IS 'Array of work types for repair requests';
COMMENT ON COLUMN requests.lokasi_perbaikan_array IS 'Array of locations for repair requests';

COMMENT ON COLUMN requests.lokasi_peminjaman_array IS 'Array of locations for borrowing requests';
COMMENT ON COLUMN requests.kegunaan_array IS 'Array of purposes for borrowing requests';
COMMENT ON COLUMN requests.tgl_peminjaman_array IS 'Array of borrowing dates';
COMMENT ON COLUMN requests.tgl_pengembalian_array IS 'Array of return dates';

COMMENT ON COLUMN requests.lokasi_array IS 'General location array that can be used by any request type';

-- Update existing records to migrate data from single fields to arrays
-- This ensures backward compatibility

-- For perbaikan requests, migrate single fields to arrays
UPDATE requests 
SET 
  nama_barang_perbaikan_array = CASE 
    WHEN nama_barang IS NOT NULL THEN ARRAY[nama_barang]
    ELSE NULL
  END,
  type_model_perbaikan_array = CASE 
    WHEN type_model IS NOT NULL THEN ARRAY[type_model]
    ELSE NULL
  END,
  jumlah_perbaikan_array = CASE 
    WHEN jumlah IS NOT NULL THEN ARRAY[jumlah]
    ELSE NULL
  END,
  jenis_pekerjaan_array = CASE 
    WHEN jenis_pekerjaan IS NOT NULL THEN ARRAY[jenis_pekerjaan]
    ELSE NULL
  END,
  lokasi_perbaikan_array = CASE 
    WHEN lokasi IS NOT NULL THEN ARRAY[lokasi]
    ELSE NULL
  END
WHERE jenis_request = 'perbaikan';

-- For peminjaman requests, migrate single fields to arrays
UPDATE requests 
SET 
  lokasi_peminjaman_array = CASE 
    WHEN lokasi IS NOT NULL THEN ARRAY[lokasi]
    ELSE NULL
  END,
  kegunaan_array = CASE 
    WHEN kegunaan IS NOT NULL THEN ARRAY[kegunaan]
    ELSE NULL
  END,
  tgl_peminjaman_array = CASE 
    WHEN tgl_peminjaman IS NOT NULL THEN ARRAY[tgl_peminjaman]
    ELSE NULL
  END,
  tgl_pengembalian_array = CASE 
    WHEN tgl_pengembalian IS NOT NULL THEN ARRAY[tgl_pengembalian]
    ELSE NULL
  END
WHERE jenis_request = 'peminjaman';

-- For pengadaan requests, ensure lokasi_array is populated if needed
UPDATE requests 
SET lokasi_array = ARRAY['Default Location']
WHERE jenis_request = 'pengadaan' AND lokasi_array IS NULL;

-- Verify the migration
SELECT 
  jenis_request,
  COUNT(*) as total_requests,
  COUNT(nama_barang_perbaikan_array) as perbaikan_with_arrays,
  COUNT(lokasi_peminjaman_array) as peminjaman_with_arrays,
  COUNT(lokasi_array) as with_lokasi_array
FROM requests 
GROUP BY jenis_request
ORDER BY jenis_request;
