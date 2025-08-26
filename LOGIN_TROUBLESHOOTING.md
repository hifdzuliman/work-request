# Login Issue Troubleshooting Guide

## Problem Description
Error 401 (Unauthorized) saat login dengan credentials:
- Username: `hifdzul`
- Password: `admin123`

## Root Causes
1. **User tidak ada di database**
2. **Password hash tidak sesuai**
3. **Database connection issue**
4. **Backend service error**

## Solution Steps

### Step 1: Create Test User
Jalankan script untuk membuat user test:

```bash
cd backend
go run scripts/create-test-user.go
```

Atau gunakan script batch:
```bash
fix-login-issue.bat
```

### Step 2: Verify Database Connection
Pastikan database PostgreSQL berjalan dan terhubung:

```bash
# Check config.env file
cat backend/config.env

# Verify database connection
cd backend
go run main.go
```

### Step 3: Test Login API
Test login menggunakan curl atau PowerShell:

```bash
# Using curl
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"hifdzul","password":"admin123"}'

# Using PowerShell
.\test-login.ps1
```

### Step 4: Check Backend Logs
Backend sekarang memiliki logging yang lebih detail. Periksa output untuk:

```
Login attempt for username: hifdzul
Login failed for username hifdzul: invalid credentials
```

## Expected Response
Jika berhasil, response seharusnya:

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid-here",
    "username": "hifdzul",
    "name": "Hifdzul Test User",
    "email": "hifdzul@test.com",
    "unit": "IT Department",
    "role": "operator"
  }
}
```

## Database Schema
Tabel `users` harus memiliki struktur:

```sql
CREATE TABLE users (
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
```

## Test User Credentials
- **Username**: `hifdzul`
- **Password**: `admin123`
- **Role**: `operator`
- **Unit**: `IT Department`

## Common Issues & Solutions

### Issue 1: "invalid credentials"
**Cause**: User tidak ada atau password salah
**Solution**: Jalankan `go run scripts/create-test-user.go`

### Issue 2: Database connection failed
**Cause**: PostgreSQL tidak berjalan atau config salah
**Solution**: 
1. Start PostgreSQL service
2. Check `backend/config.env`
3. Verify database credentials

### Issue 3: Table doesn't exist
**Cause**: Database belum diinisialisasi
**Solution**: Backend akan otomatis membuat tabel saat startup

### Issue 4: CORS error
**Cause**: Frontend tidak bisa akses backend
**Solution**: 
1. Backend CORS middleware sudah dikonfigurasi
2. Frontend proxy sudah disetup
3. Pastikan backend berjalan di port 8080

## Verification Commands

### Check if user exists:
```sql
SELECT username, name, role FROM users WHERE username = 'hifdzul';
```

### Check password hash:
```sql
SELECT username, password_hash FROM users WHERE username = 'hifdzul';
```

### Test password verification:
```go
// In Go code
hashedPassword := "$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi"
isValid := utils.CheckPasswordHash("admin123", hashedPassword)
fmt.Println("Password valid:", isValid) // Should print: true
```

## Next Steps
Setelah login berhasil:

1. **Test frontend integration**: Buka `http://localhost:3000/integration-test`
2. **Verify token storage**: Check browser localStorage
3. **Test protected routes**: Navigate to dashboard
4. **Check user context**: Verify user role and permissions

## Support
Jika masalah masih berlanjut:

1. Check backend logs untuk error detail
2. Verify database schema dan data
3. Test API endpoints secara manual
4. Check network connectivity antara frontend dan backend

