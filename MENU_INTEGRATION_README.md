# Menu Integration Documentation

## Overview
Dokumen ini menjelaskan integrasi lengkap untuk tiga menu utama aplikasi Web Work Request:
1. **Pengajuan** - Halaman untuk membuat pengajuan baru
2. **Persetujuan** - Halaman untuk operator menyetujui/menolak pengajuan
3. **Riwayat** - Halaman untuk melihat riwayat pengajuan

## Backend Integration

### 1. API Endpoints

#### Pengajuan (Create Request)
```http
POST /api/requests
Authorization: Bearer <token>
Content-Type: application/json

{
  "jenis_request": "pengadaan|perbaikan|peminjaman",
  "unit": "string",
  "nama_barang": "string",
  "type_model": "string",
  "jumlah": "integer",
  "lokasi": "string",
  "jenis_pekerjaan": "string|null",
  "kegunaan": "string|null",
  "tgl_request": "YYYY-MM-DD",
  "tgl_peminjaman": "YYYY-MM-DD|null",
  "tgl_pengembalian": "YYYY-MM-DD|null",
  "keterangan": "string"
}
```

#### Persetujuan (Get All Requests)
```http
GET /api/requests
Authorization: Bearer <token>

Response:
{
  "data": [
    {
      "id": "integer",
      "jenis_request": "string",
      "unit": "string",
      "nama_barang": "string",
      "type_model": "string",
      "jumlah": "integer",
      "lokasi": "string",
      "jenis_pekerjaan": "string|null",
      "kegunaan": "string|null",
      "tgl_request": "date",
      "tgl_peminjaman": "date|null",
      "tgl_pengembalian": "date|null",
      "keterangan": "string",
      "status_request": "string",
      "requested_by": "string",
      "approved_by": "string|null",
      "accepted_by": "string|null",
      "created_at": "timestamp",
      "updated_at": "timestamp"
    }
  ],
  "pagination": {
    "page": "integer",
    "limit": "integer",
    "total": "integer"
  }
}
```

#### Riwayat (Get My Requests)
```http
GET /api/requests/my-requests
Authorization: Bearer <token>

Response: Array of requests created by the authenticated user
```

#### Update Request Status
```http
PUT /api/requests/{id}/status
Authorization: Bearer <token>
Content-Type: application/json

{
  "status_request": "DISETUJUI|DITOLAK|DIPROSES|SELESAI",
  "approved_by": "string|null",
  "accepted_by": "string|null",
  "keterangan": "string"
}
```

### 2. Database Schema

#### Request Table
```sql
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
```

### 3. Status Flow
```
DIAJUKAN → DISETUJUI/DITOLAK → DIPROSES → SELESAI
   ↓              ↓              ↓         ↓
  User        Operator      Staff      Completed
creates      approves/     processes   request
request      rejects       request
```

## Frontend Integration

### 1. Pengajuan Page (`/pengajuan`)

#### Features
- Form untuk membuat pengajuan baru
- Dynamic fields berdasarkan jenis request:
  - **Pengadaan**: Basic fields (unit, nama_barang, jumlah, lokasi, dll)
  - **Perbaikan**: + jenis_pekerjaan field
  - **Peminjaman**: + tgl_peminjaman, tgl_pengembalian, kegunaan fields
- Validation dan error handling
- Redirect ke halaman riwayat setelah berhasil

#### Key Components
```jsx
const Pengajuan = () => {
  const [formData, setFormData] = useState({
    jenis_request: 'pengadaan',
    unit: user?.unit || '',
    nama_barang: '',
    type_model: '',
    jumlah: 1,
    lokasi: '',
    jenis_pekerjaan: '',
    kegunaan: '',
    tgl_request: new Date().toISOString().split('T')[0],
    tgl_peminjaman: '',
    tgl_pengembalian: '',
    keterangan: ''
  });

  const handleSubmit = async (e) => {
    // Call api.createRequest()
    // Handle success/error
    // Redirect to /riwayat
  };
};
```

### 2. Persetujuan Page (`/persetujuan`)

#### Features
- Role-based access (hanya untuk operator)
- Statistik: Menunggu Persetujuan, Total Disetujui, Total Ditolak
- Tabel pengajuan yang menunggu persetujuan
- Modal detail untuk review pengajuan
- Action buttons: Setujui/Tolak

#### Key Components
```jsx
const Persetujuan = () => {
  const { user } = useAuth();
  const [requests, setRequests] = useState([]);
  const [selectedRequest, setSelectedRequest] = useState(null);

  useEffect(() => {
    if (user?.role === 'operator') {
      loadRequests(); // api.getAllRequests()
    }
  }, [user]);

  const handleStatusUpdate = async (requestId, newStatus, keterangan) => {
    // Call api.updateRequestStatus()
    // Reload requests
    // Close modal
  };
};
```

### 3. Riwayat Page (`/riwayat`)

#### Features
- Tampilkan semua pengajuan user (atau semua untuk operator)
- Filtering: Search, Status, Jenis, Unit
- Tabel dengan informasi lengkap
- Modal detail untuk melihat informasi lengkap
- Refresh data

#### Key Components
```jsx
const Riwayat = () => {
  const { user } = useAuth();
  const [requests, setRequests] = useState([]);
  const [filteredRequests, setFilteredRequests] = useState([]);
  
  // Filter states
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [jenisFilter, setJenisFilter] = useState('all');
  const [unitFilter, setUnitFilter] = useState('all');

  useEffect(() => {
    loadRequests(); // api.getAllRequests() or api.getMyRequests()
  }, []);

  useEffect(() => {
    filterRequests(); // Apply filters
  }, [requests, searchTerm, statusFilter, jenisFilter, unitFilter]);
};
```

## API Service Layer

### 1. Request Methods
```javascript
// Create new request
async createRequest(requestData) {
  return this.request('/requests', {
    method: 'POST',
    body: JSON.stringify(requestData)
  });
}

// Get all requests (for operators)
async getAllRequests() {
  return this.request('/requests');
}

// Get user's requests (for regular users)
async getMyRequests() {
  return this.request('/requests/my-requests');
}

// Update request status
async updateRequestStatus(id, statusData) {
  return this.request(`/requests/${id}/status`, {
    method: 'PUT',
    body: JSON.stringify(statusData)
  });
}
```

### 2. Response Handling
```javascript
// Success response format
{
  "success": true,
  "request": { /* request object */ }
}

// Error response format
{
  "error": "Error message"
}
```

## Testing

### 1. Manual Testing
1. **Pengajuan**: Buat pengajuan baru dengan berbagai jenis request
2. **Persetujuan**: Login sebagai operator, approve/reject requests
3. **Riwayat**: Lihat history pengajuan dengan berbagai filter

### 2. Automated Testing
Gunakan script `test-menu-integration.ps1` untuk testing otomatis:

```powershell
# Test semua endpoint
.\test-menu-integration.ps1

# Expected results:
# ✅ Pengajuan: Create request endpoint returns 201
# ✅ Persetujuan: Get all requests endpoint returns 200
# ✅ Riwayat: Get my requests endpoint returns 200
# ✅ Status Update: Update request status endpoint returns 200
```

## Error Handling

### 1. Backend Errors
- **400 Bad Request**: Invalid input data
- **401 Unauthorized**: Missing or invalid token
- **403 Forbidden**: Insufficient permissions
- **404 Not Found**: Request not found
- **500 Internal Server Error**: Server error

### 2. Frontend Error Handling
```jsx
try {
  const response = await api.createRequest(data);
  // Handle success
} catch (error) {
  setError(error.message || 'Gagal membuat pengajuan');
  // Show error message to user
}
```

## Security Considerations

### 1. Authentication
- JWT token required for all protected endpoints
- Token validation in middleware

### 2. Authorization
- Role-based access control
- Users can only see their own requests
- Operators can see and manage all requests

### 3. Input Validation
- Backend validation for all input fields
- SQL injection prevention
- XSS protection

## Performance Optimizations

### 1. Frontend
- Debounced search input
- Efficient filtering with useMemo
- Lazy loading for large datasets

### 2. Backend
- Database indexes on frequently queried fields
- Pagination for large result sets
- Efficient SQL queries

## Troubleshooting

### Common Issues

#### 1. CORS Errors
```bash
# Check backend CORS configuration
# Ensure frontend proxy is set correctly
```

#### 2. Authentication Issues
```bash
# Verify JWT token is valid
# Check token expiration
# Ensure proper Authorization header
```

#### 3. Database Connection
```bash
# Check PostgreSQL connection
# Verify table structure
# Check database permissions
```

### Debug Commands
```bash
# Check backend logs
cd backend && go run main.go

# Check frontend console
cd frontend && npm start

# Test API endpoints
curl -X GET http://localhost:8080/health
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"hifdzul","password":"admin123"}'
```

## Future Enhancements

### 1. Additional Features
- Email notifications for status changes
- File attachments for requests
- Advanced reporting and analytics
- Mobile app support

### 2. Performance Improvements
- Redis caching for frequently accessed data
- Database connection pooling
- API rate limiting
- CDN for static assets

### 3. Security Enhancements
- Two-factor authentication
- Audit logging
- IP whitelisting
- Advanced role permissions

## Conclusion

Integrasi menu pengajuan, persetujuan, dan riwayat telah berhasil diimplementasikan dengan fitur lengkap:

✅ **Pengajuan**: Form dinamis untuk berbagai jenis request  
✅ **Persetujuan**: Workflow approval untuk operator  
✅ **Riwayat**: History dan filtering untuk semua user  
✅ **API Integration**: Endpoint lengkap dengan authentication  
✅ **Database**: Schema unified untuk semua request types  
✅ **Security**: Role-based access control dan validation  
✅ **Testing**: Automated testing script dan manual verification  

Sistem siap untuk production use dengan monitoring dan error handling yang komprehensif.

