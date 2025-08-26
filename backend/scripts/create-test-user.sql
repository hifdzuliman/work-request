-- Create test user for development
-- This script creates a user with username 'hifdzul' and password 'admin123'

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Delete existing user if exists
DELETE FROM users WHERE username = 'hifdzul';

-- Create test user
INSERT INTO users (
    id,
    username,
    password_hash,
    name,
    email,
    unit,
    role,
    created_at,
    updated_at
) VALUES (
    uuid_generate_v4(),
    'hifdzul',
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- password: admin123
    'Hifdzul Test User',
    'hifdzul@test.com',
    'IT Department',
    'operator',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

-- Verify the user was created
SELECT 
    username,
    name,
    email,
    unit,
    role,
    created_at
FROM users 
WHERE username = 'hifdzul';

