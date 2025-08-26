# User Management Integration - CRUD Operations

## Overview
Halaman pengguna telah terintegrasi penuh dengan backend untuk operasi CRUD (Create, Read, Update, Delete) yang lengkap.

## Features Implemented

### ✅ **Backend API Endpoints**
- `GET /api/users` - Get all users
- `GET /api/users/:id` - Get user by ID
- `POST /api/users` - Create new user
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user

### ✅ **Frontend Components**
- User list table dengan pagination
- Create user modal form
- Edit user modal form
- User detail modal
- Delete confirmation
- Loading states dan error handling

### ✅ **Data Validation**
- Form validation di frontend
- Backend validation dengan Gin binding
- Duplicate username/email prevention
- Password hashing untuk security

## Backend Implementation

### 1. **Models**
```go
// CreateUserRequest
type CreateUserRequest struct {
    Username string `json:"username" binding:"required"`
    Password string `json:"password" binding:"required,min=6"`
    Name     string `json:"name" binding:"required"`
    Email    string `json:"email" binding:"required,email"`
    Unit     string `json:"unit" binding:"required"`
    Role     string `json:"role" binding:"required,oneof=user operator"`
}

// UpdateUserRequest
type UpdateUserRequest struct {
    Name  string `json:"name,omitempty"`
    Email string `json:"email,omitempty"`
    Unit  string `json:"unit,omitempty"`
    Role  string `json:"role,omitempty" binding:"omitempty,oneof=user operator"`
}
```

### 2. **Handlers**
- `CreateUser` - Validasi input dan buat user baru
- `GetAllUsers` - Ambil semua users dari database
- `GetUserByID` - Ambil user berdasarkan ID
- `UpdateUser` - Update data user (tidak termasuk username/password)
- `DeleteUser` - Hapus user dari database

### 3. **Services**
- Business logic untuk user management
- Validasi duplicate username/email
- Password hashing dengan bcrypt
- Error handling yang comprehensive

### 4. **Repository**
- Database operations untuk users table
- SQL queries untuk CRUD operations
- Connection management

## Frontend Implementation

### 1. **API Service**
```javascript
// User endpoints
async getAllUsers() {
  return this.request('/users');
}

async getUserById(id) {
  return this.request(`/users/${id}`);
}

async createUser(userData) {
  return this.request('/users', {
    method: 'POST',
    body: JSON.stringify(userData)
  });
}

async updateUser(id, userData) {
  return this.request(`/users/${id}`, {
    method: 'PUT',
    body: JSON.stringify(userData)
  });
}

async deleteUser(id) {
  return this.request(`/users/${id}`, {
    method: 'DELETE'
  });
}
```

### 2. **State Management**
- `penggunaList` - Array of users
- `loading` - Loading state untuk API calls
- `submitting` - Form submission state
- `errors` - Validation errors
- Modal states untuk create/edit/detail

### 3. **Form Handling**
- Real-time validation
- Error display
- Loading states
- Form reset functionality

## API Response Formats

### **Create User Response**
```json
{
  "success": true,
  "message": "User created successfully",
  "user": {
    "id": "uuid-here",
    "username": "newuser",
    "name": "New User",
    "email": "newuser@example.com",
    "unit": "IT Department",
    "role": "user",
    "created_at": "2025-01-25T10:00:00Z",
    "updated_at": "2025-01-25T10:00:00Z"
  }
}
```

### **Update User Response**
```json
{
  "success": true,
  "message": "User updated successfully",
  "user": {
    "id": "uuid-here",
    "username": "existinguser",
    "name": "Updated Name",
    "email": "updated@email.com",
    "unit": "Updated Unit",
    "role": "operator",
    "created_at": "2025-01-25T10:00:00Z",
    "updated_at": "2025-01-25T10:00:00Z"
  }
}
```

### **Delete User Response**
```json
{
  "success": true,
  "message": "User deleted successfully"
}
```

## Security Features

### 1. **Authentication Required**
- Semua user management endpoints memerlukan JWT token
- Token validation di middleware
- User context dari token

### 2. **Input Validation**
- Frontend form validation
- Backend Gin binding validation
- SQL injection prevention
- XSS protection

### 3. **Password Security**
- Password hashing dengan bcrypt
- Minimum password length (6 characters)
- Password tidak dikirim saat update

### 4. **Data Integrity**
- Unique username constraint
- Unique email constraint
- Role validation (user/operator only)
- Timestamp tracking

## Testing

### 1. **Backend Testing**
```bash
# Test user management endpoints
.\test-user-management.ps1
```

### 2. **Frontend Testing**
- Navigate to: `http://localhost:3000/pengguna`
- Test create user functionality
- Test edit user functionality
- Test delete user functionality
- Test user detail view

### 3. **API Testing**
```bash
# Get all users
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:8080/api/users

# Create user
curl -X POST -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"test123","name":"Test User","email":"test@example.com","unit":"Test","role":"user"}' \
  http://localhost:8080/api/users
```

## Error Handling

### 1. **Common Errors**
- `400 Bad Request` - Invalid input data
- `401 Unauthorized` - Missing/invalid token
- `404 Not Found` - User not found
- `409 Conflict` - Username/email already exists
- `500 Internal Server Error` - Database/server error

### 2. **Frontend Error Display**
- Form validation errors
- API error messages
- Loading states
- Success confirmations

## Database Schema

### **Users Table**
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

## Usage Examples

### 1. **Create New User**
1. Click "Tambah Pengguna" button
2. Fill in user details:
   - Username: unique username
   - Password: minimum 6 characters
   - Name: full name
   - Email: valid email format
   - Unit: department/unit
   - Role: user or operator
3. Click "Simpan"

### 2. **Edit Existing User**
1. Click edit icon (pencil) on user row
2. Modify fields (username cannot be changed)
3. Click "Update"

### 3. **Delete User**
1. Click delete icon (trash) on user row
2. Confirm deletion in popup
3. User will be permanently removed

### 4. **View User Details**
1. Click view icon (eye) on user row
2. See complete user information
3. Modal shows all user data

## Next Steps

### 1. **Immediate Testing**
- Test all CRUD operations
- Verify error handling
- Check loading states

### 2. **Enhancement Ideas**
- User search functionality
- User filtering by role/unit
- Bulk user operations
- User import/export
- User activity logging

### 3. **Production Considerations**
- Rate limiting
- Audit logging
- User permission levels
- Soft delete instead of hard delete
- User deactivation

## Troubleshooting

### **Common Issues**

#### Issue 1: "User not found" error
**Cause**: User ID doesn't exist in database
**Solution**: Verify user exists, check ID format

#### Issue 2: "Username already exists" error
**Cause**: Duplicate username in database
**Solution**: Use unique username, check existing users

#### Issue 3: "Email already exists" error
**Cause**: Duplicate email in database
**Solution**: Use unique email, check existing users

#### Issue 4: "Invalid role" error
**Cause**: Role not in allowed values
**Solution**: Use only 'user' or 'operator'

#### Issue 5: Frontend not loading users
**Cause**: Authentication token expired
**Solution**: Re-login to get new token

### **Debug Commands**
```bash
# Check backend logs
cd backend
go run main.go

# Check database
psql -U your_user -d your_db -c "SELECT * FROM users;"

# Test API endpoints
.\test-user-management.ps1
```

## Support

Jika ada masalah dengan user management:

1. **Check backend logs** untuk error detail
2. **Verify database connection** dan schema
3. **Test API endpoints** secara manual
4. **Check frontend console** untuk JavaScript errors
5. **Verify authentication token** masih valid

User management integration sudah lengkap dan siap digunakan untuk production!

