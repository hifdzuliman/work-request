# 🚀 **Pengadaan Array Fields - Web Work Request System**

## 📋 **Overview**

Sistem Web Work Request telah diupgrade untuk mendukung **array fields** pada request jenis `pengadaan`. Ini memungkinkan user untuk menambahkan multiple items dalam satu pengajuan, memberikan fleksibilitas yang lebih besar dalam pengelolaan request.

## 🎯 **Fitur Utama**

### **1. Array Fields untuk Pengadaan**
- **`nama_barang_array[]`** - Array nama barang yang diajukan
- **`type_model_array[]`** - Array type/model untuk setiap barang
- **`jumlah_array[]`** - Array jumlah untuk setiap barang
- **`keterangan_array[]`** - Array keterangan spesifik untuk setiap barang

### **2. Single Fields untuk Request Lain**
- **Perbaikan**: `nama_barang`, `type_model`, `jumlah`, `jenis_pekerjaan`, `lokasi`
- **Peminjaman**: `lokasi`, `kegunaan`, `tgl_peminjaman`, `tgl_pengembalian`

### **3. Auto-filled Basic Information**
- **Unit/Departemen**: Otomatis dari data user yang login
- **Tanggal Request**: Otomatis tanggal hari ini
- **Requested By**: Otomatis nama user yang login
- Tidak perlu input manual untuk informasi dasar

### **4. Dynamic Form Interface**
- Form yang berubah sesuai jenis request yang dipilih
- Add/remove item rows untuk pengadaan
- Conditional validation untuk setiap request type

## 🗄️ **Database Schema Update**

### **Struktur Tabel Baru**

```sql
CREATE TABLE request (
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
```

### **Migration Script**
File: `backend/scripts/update-pengadaan-array.sql`

## 🔧 **Backend Changes**

### **1. Models (`backend/models/models.go`)**

```go
type Request struct {
    ID            int64     `json:"id" db:"id"`
    JenisRequest string    `json:"jenis_request" db:"jenis_request"`
    Unit          string    `json:"unit" db:"unit"`
    
    // For pengadaan: array fields
    NamaBarangArray    []string  `json:"nama_barang_array" db:"nama_barang_array"`
    TypeModelArray     []string  `json:"type_model_array" db:"type_model_array"`
    JumlahArray        []int     `json:"jumlah_array" db:"jumlah_array"`
    KeteranganArray    []string  `json:"keterangan_array" db:"keterangan_array"`
    
    // For perbaikan: single fields
    NamaBarang      *string   `json:"nama_barang" db:"nama_barang"`
    TypeModel       *string   `json:"type_model" db:"type_model"`
    Jumlah          *int      `json:"jumlah" db:"jumlah"`
    JenisPekerjaan  *string   `json:"jenis_pekerjaan" db:"jenis_pekerjaan"`
    
    // For peminjaman: single fields
    Lokasi          *string   `json:"lokasi" db:"lokasi"`
    Kegunaan        *string   `json:"kegunaan" db:"kegunaan"`
    TglPeminjaman   *time.Time `json:"tgl_peminjaman" db:"tgl_peminjaman"`
    TglPengembalian *time.Time `json:"tgl_pengembalian" db:"tgl_pengembalian"`
    
    // Common fields
    TglRequest      time.Time  `json:"tgl_request" db:"tgl_request"`
    Keterangan      *string    `json:"keterangan" db:"keterangan"`
    StatusRequest   string     `json:"status_request" db:"status_request"`
    RequestedBy     string     `json:"requested_by" db:"requested_by"`
    ApprovedBy      *string    `json:"approved_by" db:"approved_by"`
    AcceptedBy      *string    `json:"accepted_by" db:"accepted_by"`
    CreatedAt       time.Time  `json:"created_at" db:"created_at"`
    UpdatedAt       time.Time  `json:"updated_at" db:"updated_at"`
}
```

### **2. Create Request Request Model**

```go
type CreateRequestRequest struct {
    JenisRequest    string   `json:"jenis_request" binding:"required,oneof=pengadaan perbaikan peminjaman"`
    Unit            string   `json:"unit" binding:"required"`
    
    // For pengadaan: array fields
    NamaBarangArray    []string `json:"nama_barang_array"`
    TypeModelArray     []string `json:"type_model_array"`
    JumlahArray        []int    `json:"jumlah_array"`
    KeteranganArray    []string `json:"keterangan_array"`
    
    // For perbaikan: single fields
    NamaBarang      *string `json:"nama_barang"`
    TypeModel       *string `json:"type_model"`
    Jumlah          *int    `json:"jumlah"`
    JenisPekerjaan  *string `json:"jenis_pekerjaan"`
    
    // For peminjaman: single fields
    Lokasi          *string `json:"lokasi"`
    Kegunaan        *string `json:"kegunaan"`
    TglPeminjaman   *string `json:"tgl_peminjaman"`
    TglPengembalian *string `json:"tgl_pengembalian"`
    
    // Common fields
    TglRequest      string  `json:"tgl_request" binding:"required"`
    Keterangan      *string `json:"keterangan"`
}
```

## 🎨 **Frontend Changes**

### **1. Auto-filled Information Display**
- Informasi dasar ditampilkan tapi tidak bisa diedit
- Unit dan tanggal request otomatis terisi
- User experience yang lebih baik

### **2. Dynamic Form State (`frontend/src/pages/Pengajuan.js`)**

```javascript
const [formData, setFormData] = useState({
    jenis_request: 'pengadaan',
    // For pengadaan: array fields
    nama_barang_array: [''],
    type_model_array: [''],
    jumlah_array: [1],
    keterangan_array: [''],
    // For perbaikan: single fields
    nama_barang: '',
    type_model: '',
    jumlah: 1,
    jenis_pekerjaan: '',
    // For peminjaman: single fields
    lokasi: '',
    kegunaan: '',
    tgl_peminjaman: '',
    tgl_pengembalian: '',
    keterangan: ''
});
```

### **3. Array Field Handlers**

```javascript
// Handle array field changes for pengadaan
const handleArrayFieldChange = (field, index, value) => {
    setFormData(prev => ({
        ...prev,
        [field]: prev[field].map((item, i) => i === index ? value : item)
    }));
};

// Add new item row for pengadaan
const addItemRow = () => {
    setFormData(prev => ({
        ...prev,
        nama_barang_array: [...prev.nama_barang_array, ''],
        type_model_array: [...prev.type_model_array, ''],
        jumlah_array: [...prev.jumlah_array, 1],
        keterangan_array: [...prev.keterangan_array, '']
    }));
};

// Remove item row for pengadaan
const removeItemRow = (index) => {
    if (formData.nama_barang_array.length > 1) {
        setFormData(prev => ({
            ...prev,
            nama_barang_array: prev.nama_barang_array.filter((_, i) => i !== index),
            type_model_array: prev.type_model_array.filter((_, i) => i !== index),
            jumlah_array: prev.jumlah_array.filter((_, i) => i !== index),
            keterangan_array: prev.keterangan_array.filter((_, i) => i !== index)
        }));
    }
};
```

### **3. Auto-filled Information Display**

```javascript
{/* Auto-filled Information Display */}
<div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
    <h3 className="text-sm font-medium text-blue-900 mb-2">Informasi Otomatis</h3>
    <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 text-sm">
        <div>
            <span className="font-medium text-blue-700">Unit/Departemen:</span>
            <span className="ml-2 text-blue-900">{user?.unit || 'Tidak tersedia'}</span>
        </div>
        <div>
            <span className="font-medium text-blue-700">Tanggal Request:</span>
            <span className="ml-2 text-blue-900">{new Date().toLocaleDateString('id-ID')}</span>
        </div>
    </div>
</div>
```

### **4. Conditional Form Rendering**

```javascript
{formData.jenis_request === 'pengadaan' && (
    <div className="bg-white shadow rounded-lg p-6">
        <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-medium text-gray-900">Daftar Barang yang Diajukan</h3>
            <button
                type="button"
                onClick={addItemRow}
                className="inline-flex items-center px-3 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
                <Plus className="h-4 w-4 mr-2" />
                Tambah Barang
            </button>
        </div>
        
        <div className="space-y-4">
            {formData.nama_barang_array.map((item, index) => (
                <div key={index} className="border border-gray-200 rounded-lg p-4">
                    {/* Item form fields */}
                </div>
            ))}
        </div>
    </div>
)}

### **5. Smart Data Submission**

```javascript
const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Prepare request data based on jenis_request
    let requestData = {
        jenis_request: formData.jenis_request,
        unit: user?.unit || '', // Auto-fill from logged in user
        tgl_request: new Date().toISOString().split('T')[0], // Auto-fill current date
        keterangan: formData.keterangan
    };

    if (formData.jenis_request === 'pengadaan') {
        // For pengadaan: use array fields
        requestData = {
            ...requestData,
            nama_barang_array: formData.nama_barang_array.filter(item => item.trim() !== ''),
            type_model_array: formData.type_model_array.filter(item => item.trim() !== ''),
            jumlah_array: formData.jumlah_array.filter((item, index) => formData.nama_barang_array[index].trim() !== ''),
            keterangan_array: formData.keterangan_array.filter(item => item.trim() !== '')
        };
    } else if (formData.jenis_request === 'perbaikan') {
        // For perbaikan: use single fields
        requestData = {
            ...requestData,
            nama_barang: formData.nama_barang,
            type_model: formData.type_model,
            jumlah: formData.jumlah,
            jenis_pekerjaan: formData.jenis_pekerjaan,
            lokasi: formData.lokasi
        };
    } else if (formData.jenis_request === 'peminjaman') {
        // For peminjaman: use single fields
        requestData = {
            ...requestData,
            lokasi: formData.lokasi,
            kegunaan: formData.kegunaan,
            tgl_peminjaman: formData.tgl_peminjaman || null,
            tgl_pengembalian: formData.tgl_pengembalian || null
        };
    }

    const response = await api.createRequest(requestData);
    // Handle response...
};
```

## 🧪 **Testing**

### **1. Automated Testing Scripts**
- **`test-pengadaan-array.ps1`** - PowerShell script untuk testing array fields
- **`test-pengadaan-array.bat`** - Batch script untuk menjalankan testing
- **`test-pengadaan-auto-info.ps1`** - PowerShell script untuk testing auto-filled information
- **`test-pengadaan-auto-info.bat`** - Batch script untuk menjalankan testing auto-filled info

### **2. Manual Testing Steps**

#### **A. Test Pengadaan Request**
1. Login ke sistem
2. Navigate ke `/pengajuan`
3. Pilih jenis request "pengadaan"
4. Isi unit dan tanggal request
5. Tambah multiple items:
   - Item 1: Laptop Dell, Dell XPS 13, Jumlah: 5, Keterangan: "Untuk developer team"
   - Item 2: Mouse Wireless, Logitech MX Master, Jumlah: 10, Keterangan: "Untuk semua staff"
   - Item 3: Keyboard Mechanical, Cherry MX Blue, Jumlah: 8, Keterangan: "Untuk developer team"
6. Submit request
7. Verify data tersimpan dengan array fields

#### **B. Test Perbaikan Request**
1. Pilih jenis request "perbaikan"
2. Isi single fields: nama_barang, type_model, jumlah, jenis_pekerjaan, lokasi
3. Submit request
4. Verify data tersimpan dengan single fields

#### **C. Test Peminjaman Request**
1. Pilih jenis request "peminjaman"
2. Isi single fields: lokasi, kegunaan, tgl_peminjaman, tgl_pengembalian
3. Submit request
4. Verify data tersimpan dengan single fields

#### **D. Test Auto-filled Information**
1. Login dengan user yang memiliki unit tertentu
2. Buat request apapun (pengadaan/perbaikan/peminjaman)
3. Verify bahwa:
   - Unit otomatis terisi sesuai user yang login
   - Tanggal request otomatis terisi tanggal hari ini
   - Requested by otomatis terisi nama user yang login
4. Tidak perlu input manual untuk informasi dasar

### **3. Expected Results**

#### **Pengadaan Request**
```json
{
    "jenis_request": "pengadaan",
    "unit": "IT Department",
    "nama_barang_array": ["Laptop Dell", "Mouse Wireless", "Keyboard Mechanical"],
    "type_model_array": ["Dell XPS 13", "Logitech MX Master", "Cherry MX Blue"],
    "jumlah_array": [5, 10, 8],
    "keterangan_array": ["Untuk developer team", "Untuk semua staff", "Untuk developer team"],
    "tgl_request": "2024-01-20",
    "keterangan": "Pengajuan peralatan IT untuk tim development"
}
```

#### **Perbaikan Request**
```json
{
    "jenis_request": "perbaikan",
    "unit": "Maintenance Department",
    "nama_barang": "Printer HP",
    "type_model": "HP LaserJet Pro",
    "jumlah": 2,
    "jenis_pekerjaan": "Ganti cartridge dan service",
    "lokasi": "Ruang Admin, Lantai 1",
    "tgl_request": "2024-01-20",
    "keterangan": "Printer bermasalah, perlu maintenance"
}
```

#### **Peminjaman Request**
```json
{
    "jenis_request": "peminjaman",
    "unit": "Marketing Department",
    "lokasi": "Ruang Meeting VIP, Lantai 3",
    "kegunaan": "Meeting dengan client penting",
    "tgl_peminjaman": "2024-01-25",
    "tgl_pengembalian": "2024-01-25",
    "tgl_request": "2024-01-20",
    "keterangan": "Meeting dengan client untuk project baru"
}
```

## 🔍 **Data Display & Filtering**

### **1. Dashboard Statistics**
- Total pengajuan berdasarkan jenis request
- Breakdown per status untuk setiap jenis request

### **2. Riwayat Page**
- Display array fields untuk pengadaan requests
- Single fields untuk perbaikan dan peminjaman
- Filtering berdasarkan jenis request

### **3. Persetujuan Page**
- Array display untuk pengadaan requests
- Approval workflow untuk semua jenis request

## 🚀 **Benefits**

### **1. User Experience**
- **Fleksibilitas**: Satu pengajuan bisa berisi multiple items
- **Efisiensi**: Tidak perlu buat multiple request untuk items yang sama
- **Konsistensi**: Data terorganisir dengan baik dalam satu request
- **Auto-fill**: Informasi dasar otomatis terisi dari data user
- **Faster Completion**: Form lebih cepat diselesaikan

### **2. Data Management**
- **Structured Data**: Array fields memudahkan processing dan analysis
- **Scalability**: Mudah menambah/remove items sesuai kebutuhan
- **Validation**: Conditional validation berdasarkan jenis request

### **3. Business Process**
- **Streamlined Workflow**: Satu approval untuk multiple items
- **Better Tracking**: Monitoring progress per item dalam satu request
- **Reporting**: Analytics yang lebih detail dan akurat

## 🔧 **Technical Implementation**

### **1. Database Migration**
```bash
# Run migration script
psql -U username -d database_name -f backend/scripts/update-pengadaan-array.sql
```

### **2. Backend Restart**
```bash
cd backend
go run main.go
```

### **3. Frontend Testing**
```bash
cd frontend
npm start
```

### **4. Run Tests**
```bash
# Test array fields
test-pengadaan-array.bat

# Test auto-filled information
test-pengadaan-auto-info.bat
```

## 📚 **API Endpoints**

### **Create Request**
```
POST /api/requests
Content-Type: application/json
Authorization: Bearer <token>

Body: CreateRequestRequest (supports both array and single fields)
```

### **Get All Requests**
```
GET /api/requests
Authorization: Bearer <token>

Response: Array of Request objects with conditional fields
```

### **Get Request by ID**
```
GET /api/requests/{id}
Authorization: Bearer <token>

Response: Request object with conditional fields
```

## 🎯 **Future Enhancements**

### **1. Advanced Array Features**
- Drag & drop reordering untuk items
- Bulk import/export untuk multiple items
- Template system untuk common item combinations

### **2. Enhanced Validation**
- Cross-field validation untuk array items
- Business rule validation (e.g., budget limits per request)
- Duplicate item detection

### **3. Reporting & Analytics**
- Item-level analytics dan reporting
- Cost analysis per item dan request
- Trend analysis untuk different item types

## 🐛 **Troubleshooting**

### **Common Issues**

#### **1. Array Fields Not Saving**
- Check database migration script execution
- Verify backend model struct tags
- Check API request payload format

#### **2. Frontend Form Errors**
- Verify form state management
- Check array field handlers
- Validate conditional rendering logic

#### **3. Data Display Issues**
- Check response parsing in frontend
- Verify conditional field rendering
- Test with different request types

### **Debug Commands**
```bash
# Check database structure
psql -U username -d database_name -c "\d request"

# Check sample data
psql -U username -d database_name -c "SELECT * FROM request WHERE jenis_request = 'pengadaan' LIMIT 1;"

# Test API endpoints
curl -X POST http://localhost:8080/api/requests \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"jenis_request":"pengadaan","unit":"Test","nama_barang_array":["Item1"],"type_model_array":["Model1"],"jumlah_array":[1],"keterangan_array":["Test"],"tgl_request":"2024-01-20"}'
```

## 📞 **Support**

Untuk pertanyaan atau issues terkait fitur array fields:

1. **Check Documentation**: Review this README thoroughly
2. **Run Tests**: Execute testing scripts untuk verification
3. **Check Logs**: Review backend dan frontend console logs
4. **Database Check**: Verify database structure dan data integrity

---

**🎉 Selamat! Sistem Web Work Request sekarang mendukung array fields untuk pengadaan requests dengan fleksibilitas yang lebih besar!**
