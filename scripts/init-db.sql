-- PostgreSQL Database Initialization Script
-- This script runs when the PostgreSQL container starts for the first time

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Set timezone
SET timezone = 'Asia/Jakarta';

-- Create database if it doesn't exist (this will be handled by POSTGRES_DB env var)
-- But we can create additional databases if needed

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    unit VARCHAR(50) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create request table
CREATE TABLE IF NOT EXISTS request (
    id BIGSERIAL PRIMARY KEY,
    jenis_request VARCHAR(50) NOT NULL,
    unit VARCHAR(100),
    nama_barang VARCHAR(200),
    type_model VARCHAR(100),
    jumlah INT,
    lokasi VARCHAR(200),
    jenis_pekerjaan TEXT,
    kegunaan TEXT,
    tgl_request DATE,
    tgl_peminjaman DATE,
    tgl_pengembalian DATE,
    keterangan TEXT,
    status_request VARCHAR(50) DEFAULT 'DIAJUKAN',
    requested_by VARCHAR(100),
    approved_by VARCHAR(100),
    accepted_by VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_request_jenis_request ON request(jenis_request);
CREATE INDEX IF NOT EXISTS idx_request_unit ON request(unit);
CREATE INDEX IF NOT EXISTS idx_request_status_request ON request(status_request);
CREATE INDEX IF NOT EXISTS idx_request_requested_by ON request(requested_by);
CREATE INDEX IF NOT EXISTS idx_request_tgl_request ON request(tgl_request);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_unit ON users(unit);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_request_updated_at BEFORE UPDATE ON request
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert default admin user (password: admin123)
-- You should change this password in production
INSERT INTO users (username, password_hash, name, email, unit, role) VALUES
('admin', crypt('admin123', gen_salt('bf')), 'System Administrator', 'admin@workrequest.com', 'IT Department', 'operator')
ON CONFLICT (username) DO NOTHING;

-- Insert sample data for testing (optional)
INSERT INTO request (jenis_request, unit, nama_barang, type_model, jumlah, lokasi, keterangan, status_request, requested_by) VALUES
('pengadaan', 'IT Department', 'Laptop', 'Dell Latitude 5520', 2, 'Kantor Pusat', 'Laptop untuk tim development baru', 'DIAJUKAN', 'admin'),
('perbaikan', 'Maintenance', 'Server', 'HP ProLiant DL380', 1, 'Data Center', 'Maintenance server database', 'DIAJUKAN', 'admin'),
('peminjaman', 'Marketing', 'Projector', 'Epson EB-X41', 1, 'Meeting Room A', 'Untuk presentasi client', 'DIAJUKAN', 'admin')
ON CONFLICT DO NOTHING;

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE work_request_db TO work_request_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO work_request_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO work_request_user;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO work_request_user;

-- Set default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO work_request_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO work_request_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO work_request_user;

-- Create a view for dashboard statistics
CREATE OR REPLACE VIEW dashboard_stats AS
SELECT 
    COUNT(*) as total_requests,
    COUNT(CASE WHEN status_request = 'DIAJUKAN' THEN 1 END) as pending_requests,
    COUNT(CASE WHEN status_request = 'DISETUJUI' THEN 1 END) as approved_requests,
    COUNT(CASE WHEN status_request = 'DITOLAK' THEN 1 END) as rejected_requests,
    COUNT(CASE WHEN status_request = 'DIPROSES' THEN 1 END) as processing_requests,
    COUNT(CASE WHEN status_request = 'SELESAI' THEN 1 END) as completed_requests
FROM request;

-- Grant access to the view
GRANT SELECT ON dashboard_stats TO work_request_user;

-- Log successful initialization
DO $$
BEGIN
    RAISE NOTICE 'Database initialization completed successfully!';
    RAISE NOTICE 'Default admin user created: admin/admin123';
    RAISE NOTICE 'Sample data inserted for testing';
END $$;
