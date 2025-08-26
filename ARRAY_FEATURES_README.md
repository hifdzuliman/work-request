# Array Features untuk Perbaikan dan Peminjaman

## 📋 Overview

Fitur ini menambahkan dukungan array untuk pengajuan type **perbaikan** dan **peminjaman**, mirip dengan fitur array yang sudah ada untuk **pengadaan**. Sekarang pengguna dapat menambahkan multiple items dalam satu pengajuan untuk kedua jenis request tersebut.

## 🚀 Fitur Baru

### 1. **Perbaikan dengan Multiple Items**
- Satu pengajuan perbaikan bisa berisi multiple barang
- Setiap barang memiliki informasi lengkap:
  - Nama barang
  - Type/Model
  - Jumlah
  - Jenis pekerjaan
  - Lokasi

### 2. **Peminjaman dengan Multiple Lokasi**
- Satu pengajuan peminjaman bisa berisi multiple lokasi
- Setiap lokasi memiliki informasi lengkap:
  - Lokasi
  - Tanggal peminjaman
  - Tanggal pengembalian
  - Kegunaan

### 3. **Backward Compatibility**
- Data lama tetap bisa diakses
- Legacy fields tetap didukung
- Migration otomatis dari single fields ke arrays

## 🏗️ Struktur Database

### **New Array Fields**

#### **Perbaikan Requests**
```sql
nama_barang_perbaikan_array TEXT[]      -- Array nama barang
type_model_perbaikan_array TEXT[]       -- Array type/model
jumlah_perbaikan_array INTEGER[]        -- Array jumlah
jenis_pekerjaan_array TEXT[]            -- Array jenis pekerjaan
lokasi_perbaikan_array TEXT[]           -- Array lokasi
```

#### **Peminjaman Requests**
```sql
lokasi_peminjaman_array TEXT[]          -- Array lokasi
kegunaan_array TEXT[]                   -- Array kegunaan
tgl_peminjaman_array TIMESTAMP[]        -- Array tanggal peminjaman
tgl_pengembalian_array TIMESTAMP[]      -- Array tanggal pengembalian
```

#### **General Array Fields**
```sql
lokasi_array TEXT[]                     -- Array lokasi umum
```

## 🎨 Frontend Changes

### **1. Form Pengajuan (`Pengajuan.js`)**

#### **Perbaikan Form**
- Multiple item rows dengan tombol "Tambah Barang"
- Setiap row berisi: nama barang, type/model, jumlah, jenis pekerjaan, lokasi
- Tombol hapus untuk setiap row (kecuali row pertama)

#### **Peminjaman Form**
- Multiple location rows dengan tombol "Tambah Lokasi"
- Setiap row berisi: lokasi, tanggal peminjaman, tanggal pengembalian, kegunaan
- Tombol hapus untuk setiap row (kecuali row pertama)

### **2. Halaman Riwayat (`Riwayat.js`)**
- Display array data untuk semua jenis request
- Detail modal menampilkan semua items dalam array
- Filtering dan searching tetap berfungsi

### **3. Halaman Persetujuan (`Persetujuan.js`)**
- Detail modal menampilkan array data dengan format yang jelas
- Setiap item ditampilkan dalam card terpisah
- Approval workflow tetap sama

## 🔧 Backend Changes

### **1. Models (`models.go`)**
```go
type Request struct {
    // ... existing fields ...
    
    // New array fields for perbaikan
    NamaBarangPerbaikanArray []string `json:"nama_barang_perbaikan_array"`
    TypeModelPerbaikanArray  []string `json:"type_model_perbaikan_array"`
    JumlahPerbaikanArray     []int    `json:"jumlah_perbaikan_array"`
    JenisPekerjaanArray      []string `json:"jenis_pekerjaan_array"`
    LokasiPerbaikanArray     []string `json:"lokasi_perbaikan_array"`
    
    // New array fields for peminjaman
    LokasiPeminjamanArray     []string    `json:"lokasi_peminjaman_array"`
    KegunaanArray             []string    `json:"kegunaan_array"`
    TglPeminjamanArray        []time.Time `json:"tgl_peminjaman_array"`
    TglPengembalianArray      []time.Time `json:"tgl_pengembalian_array"`
    
    // General array field
    LokasiArray               []string    `json:"lokasi_array"`
}
```

### **2. Database Migration**
- Script SQL untuk menambah kolom array baru
- Migration data dari single fields ke arrays
- Index creation untuk performance

## 📊 Data Flow

### **1. Create Request**
```javascript
// Perbaikan dengan multiple items
{
  jenis_request: 'perbaikan',
  nama_barang_perbaikan_array: ['Printer HP', 'Scanner Canon'],
  type_model_perbaikan_array: ['HP LaserJet Pro', 'Canon CanoScan'],
  jumlah_perbaikan_array: [2, 1],
  jenis_pekerjaan_array: ['Ganti cartridge', 'Service'],
  lokasi_perbaikan_array: ['Ruang IT', 'Ruang Admin']
}

// Peminjaman dengan multiple lokasi
{
  jenis_request: 'peminjaman',
  lokasi_peminjaman_array: ['Ruang Meeting VIP', 'Ruang Conference'],
  kegunaan_array: ['Meeting client', 'Presentasi quarterly'],
  tgl_peminjaman_array: ['2024-01-25', '2024-01-30'],
  tgl_pengembalian_array: ['2024-01-25', '2024-01-30']
}
```

### **2. Display Data**
- Table view menampilkan item pertama + count additional items
- Detail modal menampilkan semua items dalam format yang jelas
- Array data diproses sesuai jenis request

## 🔄 Migration Process

### **1. Database Migration**
```bash
# Run the migration script
psql -d your_database -f backend/scripts/add-array-fields.sql
```

### **2. Data Migration**
- Existing single field data otomatis dikonversi ke arrays
- Backward compatibility tetap terjaga
- Legacy fields tetap bisa diakses

### **3. Verification**
```sql
-- Check migration results
SELECT 
  jenis_request,
  COUNT(*) as total_requests,
  COUNT(nama_barang_perbaikan_array) as perbaikan_with_arrays,
  COUNT(lokasi_peminjaman_array) as peminjaman_with_arrays
FROM requests 
GROUP BY jenis_request;
```

## ✅ Benefits

### **1. User Experience**
- **Efisiensi**: Satu pengajuan untuk multiple items
- **Konsistensi**: Format yang sama untuk semua jenis request
- **Fleksibilitas**: Bisa tambah/hapus items sesuai kebutuhan

### **2. Data Management**
- **Organized**: Data terstruktur dalam arrays
- **Searchable**: Array fields bisa di-index dan di-search
- **Scalable**: Mudah extend untuk fitur baru

### **3. Business Logic**
- **Workflow**: Approval process tetap sama
- **Tracking**: Setiap item bisa di-track secara terpisah
- **Reporting**: Analytics yang lebih detail

## 🚨 Important Notes

### **1. Backward Compatibility**
- Existing data tetap bisa diakses
- Legacy fields tetap didukung
- API responses tetap konsisten

### **2. Data Validation**
- Array fields harus memiliki length yang sama
- Required fields tetap wajib diisi
- Data type validation tetap berlaku

### **3. Performance**
- Array fields di-index dengan GIN index
- Query performance tetap optimal
- Memory usage reasonable

## 🔮 Future Enhancements

### **1. Advanced Features**
- Bulk operations untuk multiple items
- Template pengajuan untuk items yang sering digunakan
- Import/export data dalam format Excel/CSV

### **2. UI Improvements**
- Drag & drop untuk reorder items
- Auto-complete untuk nama barang/lokasi
- Validation real-time

### **3. Analytics**
- Dashboard untuk multiple items
- Trend analysis per item
- Cost tracking per item

## 📝 Testing

### **1. Unit Tests**
- Array field validation
- Data conversion logic
- API response format

### **2. Integration Tests**
- Form submission dengan multiple items
- Data display di semua halaman
- Migration process

### **3. User Acceptance Tests**
- End-to-end workflow
- Multiple items scenarios
- Edge cases handling

## 🆘 Troubleshooting

### **1. Common Issues**
- Array fields kosong: Check data migration
- Display tidak muncul: Verify array data structure
- Performance lambat: Check database indexes

### **2. Debug Steps**
- Check database schema
- Verify API responses
- Inspect frontend state

### **3. Support**
- Check migration logs
- Verify data consistency
- Review error messages

---

**Version**: 1.0.0  
**Last Updated**: January 2024  
**Compatibility**: PostgreSQL 12+, Go 1.19+, React 18+
