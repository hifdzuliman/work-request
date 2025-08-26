# Password Generation Scripts

This directory contains tools and scripts for generating password hashes for the Web Work Request application.

## 🛠️ Available Tools

### 1. Go CLI Tool (`cmd/password/main.go`)

A command-line tool written in Go for generating password hashes.

**Usage:**
```bash
# Generate hash for a specific password
go run cmd/password/main.go -password="yourpassword"

# Generate a random password with hash
go run cmd/password/main.go -generate -length=16

# Verify a password against a hash
go run cmd/password/main.go -verify="password" -hash="hashstring"
```

**Examples:**
```bash
# Hash a simple password
go run cmd/password/main.go -password="admin123"

# Generate a 20-character random password
go run cmd/password/main.go -generate -length=20

# Verify password
go run cmd/password/main.go -verify="admin123" -hash="$2a$10$..."
```

### 2. Windows Batch Script (`generate-password.bat`)

A simple Windows batch script for generating password hashes.

**Usage:**
```cmd
# Generate hash for a password
generate-password.bat admin123

# Generate hash for password with spaces
generate-password.bat "My Password"

# Run without arguments to see usage
generate-password.bat
```

### 3. PowerShell Script (`generate-password.ps1`)

A PowerShell script with more advanced features.

**Usage:**
```powershell
# Generate hash for a password
.\generate-password.ps1 -Password 'admin123'

# Generate a random password
.\generate-password.ps1 -Generate -Length 20

# Verify a password
.\generate-password.ps1 -Verify 'admin123' -Hash '$2a$10$...'
```

## 🔐 Password Hash Functions

The backend includes several utility functions for password management:

### `GeneratePasswordHash(password string)`
Generates a bcrypt hash for a given password.

### `GenerateRandomPassword(length int)`
Generates a random password of specified length.

### `GenerateSecurePassword(length int)`
Generates both a random password and its hash.

### `CheckPasswordHash(password, hash string)`
Verifies if a password matches its hash.

## 📝 Creating Initial Users

### Step 1: Generate Password Hashes
```bash
# For admin user
go run cmd/password/main.go -password="admin123"

# For regular user
go run cmd/password/main.go -password="user123"

# For test user
go run cmd/password/main.go -password="test123"
```

### Step 2: Update SQL Script
Edit `create-initial-users.sql` and replace the placeholder hashes:
```sql
-- Replace this:
'$2a$10$YOUR_HASH_HERE'

-- With the actual hash from step 1:
'$2a$10$actualHashHere...'
```

### Step 3: Run SQL Script
```sql
-- Connect to your PostgreSQL database and run:
\i create-initial-users.sql
```

## 🔒 Security Best Practices

1. **Use Strong Passwords**: Minimum 8 characters with mixed case, numbers, and symbols
2. **Store Only Hashes**: Never store plain text passwords in the database
3. **Use bcrypt**: The application uses bcrypt with default cost (10)
4. **Regular Updates**: Change default passwords after first login
5. **Environment Variables**: Store sensitive configuration in environment variables

## 🚀 Quick Start

### For Windows Users:
```cmd
cd apps\backend\scripts
generate-password.bat admin123
```

### For PowerShell Users:
```powershell
cd apps\backend\scripts
.\generate-password.ps1 -Password 'admin123'
```

### For Go Users:
```bash
cd apps\backend
go run cmd/password/main.go -password="admin123"
```

## 📋 Example Output

When you run the password tool, you'll see output like this:
```
Password: admin123
Hash: $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdLvLvK
```

Use the hash value in your SQL scripts or configuration files.

## 🆘 Troubleshooting

### Common Issues:

1. **Go not found**: Ensure Go is installed and in your PATH
2. **Permission denied**: Run PowerShell as Administrator if needed
3. **Hash verification fails**: Ensure you're using the exact hash string
4. **Database connection**: Ensure PostgreSQL is running and accessible

### Getting Help:

- Check the main backend README.md
- Verify Go installation: `go version`
- Test database connection
- Check environment variables in `config.env`
