# Web Work Request API Documentation

## Base URL
```
http://localhost:8080
```

## Authentication
All protected endpoints require a JWT token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```

## Endpoints

### 1. Health Check
**GET** `/health`

**Response:**
```json
{
  "status": "ok",
  "message": "Web Work Request API is running"
}
```

### 2. User Registration
**POST** `/api/auth/register`

**Request Body:**
```json
{
  "username": "john_doe",
  "password": "password123",
  "name": "John Doe",
  "email": "john@example.com",
  "unit": "IT Department",
  "role": "user"
}
```

**Response:**
```json
{
  "id": "uuid-here",
  "username": "john_doe",
  "name": "John Doe",
  "email": "john@example.com",
  "unit": "IT Department",
  "role": "user",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

### 3. User Login
**POST** `/api/auth/login`

**Request Body:**
```json
{
  "username": "john_doe",
  "password": "password123"
}
```

**Response:**
```json
{
  "token": "jwt-token-here",
  "user": {
    "id": "uuid-here",
    "username": "john_doe",
    "name": "John Doe",
    "email": "john@example.com",
    "unit": "IT Department",
    "role": "user",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
}
```

### 4. Get All Users
**GET** `/api/users`

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Response:**
```json
[
  {
    "id": "uuid-here",
    "username": "john_doe",
    "name": "John Doe",
    "email": "john@example.com",
    "unit": "IT Department",
    "role": "user",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
]
```

### 5. Get User by ID
**GET** `/api/users/:id`

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Response:**
```json
{
  "id": "uuid-here",
  "username": "john_doe",
  "name": "John Doe",
  "email": "john@example.com",
  "unit": "IT Department",
  "role": "user",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

### 6. Create Work Request
**POST** `/api/work-requests`

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Request Body:**
```json
{
  "unit": "IT Department",
  "pemohon": "John Doe",
  "approver": "Manager Name",
  "activities": [
    {
      "kebutuhan": "Maintenance Server",
      "items": [
        {
          "nama_barang": "RAM DDR4 16GB",
          "jumlah_barang": 2,
          "keterangan": "Untuk upgrade server production"
        },
        {
          "nama_barang": "SSD 1TB",
          "jumlah_barang": 1,
          "keterangan": "Untuk backup storage"
        }
      ]
    },
    {
      "kebutuhan": "Network Equipment",
      "items": [
        {
          "nama_barang": "Switch 24 Port",
          "jumlah_barang": 1,
          "keterangan": "Untuk lab testing"
        }
      ]
    }
  ]
}
```

**Response:**
```json
{
  "id": "uuid-here",
  "unit": "IT Department",
  "pemohon": "John Doe",
  "approver": "Manager Name",
  "tanggal_pengajuan": "2024-01-01T00:00:00Z",
  "status": "pending",
  "catatan": "",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z",
  "activities": [
    {
      "id": "uuid-here",
      "work_request_id": "uuid-here",
      "kebutuhan": "Maintenance Server",
      "created_at": "2024-01-01T00:00:00Z",
      "items": [
        {
          "id": "uuid-here",
          "activity_id": "uuid-here",
          "nama_barang": "RAM DDR4 16GB",
          "jumlah_barang": 2,
          "keterangan": "Untuk upgrade server production",
          "created_at": "2024-01-01T00:00:00Z"
        }
      ]
    }
  ]
}
```

### 7. Get All Work Requests
**GET** `/api/work-requests`

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 10)
- `status` (optional): Filter by status (pending/approved/rejected)

**Response:**
```json
{
  "data": [
    {
      "id": "uuid-here",
      "unit": "IT Department",
      "pemohon": "John Doe",
      "approver": "Manager Name",
      "tanggal_pengajuan": "2024-01-01T00:00:00Z",
      "status": "pending",
      "catatan": "",
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 1
  }
}
```

### 8. Get My Work Requests
**GET** `/api/work-requests/my-requests`

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Response:**
```json
[
  {
    "id": "uuid-here",
    "unit": "IT Department",
    "pemohon": "John Doe",
    "approver": "Manager Name",
    "tanggal_pengajuan": "2024-01-01T00:00:00Z",
    "status": "pending",
    "catatan": "",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
]
```

### 9. Get Work Request by ID
**GET** `/api/work-requests/:id`

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Response:**
```json
{
  "id": "uuid-here",
  "unit": "IT Department",
  "pemohon": "John Doe",
  "approver": "Manager Name",
  "tanggal_pengajuan": "2024-01-01T00:00:00Z",
  "status": "pending",
  "catatan": "",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z",
  "activities": [
    {
      "id": "uuid-here",
      "work_request_id": "uuid-here",
      "kebutuhan": "Maintenance Server",
      "created_at": "2024-01-01T00:00:00Z",
      "items": [
        {
          "id": "uuid-here",
          "activity_id": "uuid-here",
          "nama_barang": "RAM DDR4 16GB",
          "jumlah_barang": 2,
          "keterangan": "Untuk upgrade server production",
          "created_at": "2024-01-01T00:00:00Z"
        }
      ]
    }
  ]
}
```

### 10. Update Work Request Status
**PUT** `/api/work-requests/:id/status`

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Request Body:**
```json
{
  "status": "approved",
  "catatan": "Request approved after review"
}
```

**Response:**
```json
{
  "message": "Work request status updated successfully"
}
```

### 11. Delete Work Request
**DELETE** `/api/work-requests/:id`

**Headers:**
```
Authorization: Bearer <jwt-token>
```

**Response:**
```json
{
  "message": "Work request deleted successfully"
}
```

## Error Responses

All endpoints return errors in the following format:

```json
{
  "error": "Error message description"
}
```

**Common HTTP Status Codes:**
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `500` - Internal Server Error

## Testing with cURL

### Register a new user:
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "password123",
    "name": "Test User",
    "email": "test@example.com",
    "unit": "Test Department",
    "role": "user"
  }'
```

### Login:
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "password123"
  }'
```

### Create a work request (replace TOKEN with actual token):
```bash
curl -X POST http://localhost:8080/api/work-requests \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{
    "unit": "Test Department",
    "pemohon": "Test User",
    "approver": "Manager",
    "activities": [
      {
        "kebutuhan": "Test Activity",
        "items": [
          {
            "nama_barang": "Test Item",
            "jumlah_barang": 1,
            "keterangan": "Test description"
          }
        ]
      }
    ]
  }'
```
