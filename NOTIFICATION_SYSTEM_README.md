# Notification System Implementation

## Overview
Sistem notifikasi pop-up yang dapat digunakan kembali untuk memberikan feedback kepada pengguna tentang status berbagai aksi dalam aplikasi work request.

## Fitur Utama
- **Multiple Notification Types**: Success, Error, Warning, Info, Pending, Approved, Rejected
- **Auto-close**: Notifikasi otomatis hilang setelah durasi tertentu
- **Progress Bar**: Visual indicator untuk waktu tersisa
- **Customizable**: Dapat disesuaikan durasi, posisi, dan styling
- **Global State Management**: Menggunakan custom hook untuk state management

## Komponen

### 1. Notification.js
Komponen utama untuk menampilkan notifikasi individual.

**Props:**
- `type`: Jenis notifikasi (success, error, warning, info, pending, approved, rejected)
- `title`: Judul notifikasi
- `message`: Pesan notifikasi
- `duration`: Durasi dalam milidetik (default: 5000ms)
- `onClose`: Callback function untuk menutup notifikasi
- `position`: Posisi notifikasi (default: 'top-right')

**Features:**
- Icon yang sesuai dengan tipe notifikasi
- Warna yang konsisten untuk setiap tipe
- Progress bar yang menunjukkan waktu tersisa
- Auto-close functionality
- Smooth animations

### 2. useNotification.js
Custom hook untuk mengelola state notifikasi global.

**Functions:**
- `addNotification(notification)`: Menambah notifikasi baru
- `removeNotification(id)`: Menghapus notifikasi berdasarkan ID
- `clearAll()`: Menghapus semua notifikasi
- `showSuccess(title, message)`: Helper untuk notifikasi sukses
- `showError(title, message)`: Helper untuk notifikasi error
- `showPengajuanSuccess(jenisRequest)`: Helper untuk sukses pengajuan
- `showPengajuanApproved(jenisRequest, approver)`: Helper untuk pengajuan disetujui
- `showPengajuanRejected(jenisRequest, approver, reason)`: Helper untuk pengajuan ditolak
- `showPengajuanProcessed(jenisRequest, processor)`: Helper untuk pengajuan diproses
- `showPengajuanCompleted(jenisRequest, completer)`: Helper untuk pengajuan selesai

### 3. NotificationContainer.js
Container untuk merender semua notifikasi aktif.

**Features:**
- Menggunakan context dari useNotification hook
- Merender multiple notifications
- Mengatur posisi dan stacking

## Implementasi di Halaman

### 1. Pengajuan.js
- **Import**: `import useNotification from '../hooks/useNotification';`
- **Usage**: 
  - `showPengajuanSuccess(formData.jenis_request)` untuk sukses submit
  - `showError(title, message)` untuk error handling

### 2. Persetujuan.js
- **Import**: `import useNotification from '../hooks/useNotification';`
- **Usage**:
  - `showPengajuanApproved(request.jenis_request, user?.name)` untuk approval
  - `showPengajuanRejected(request.jenis_request, user?.name, keterangan)` untuk rejection
  - `showPengajuanProcessed(request.jenis_request, user?.name)` untuk processing
  - `showPengajuanCompleted(request.jenis_request, user?.name)` untuk completion
  - `showError(title, message)` untuk error handling

## Struktur Data Notifikasi

```javascript
{
  id: string,           // Unique identifier
  type: string,         // success, error, warning, info, pending, approved, rejected
  title: string,        // Judul notifikasi
  message: string,      // Pesan detail
  duration: number,     // Durasi dalam milidetik
  position: string,     // Posisi notifikasi
  timestamp: Date       // Waktu pembuatan
}
```

## Styling dan Theme

### Colors
- **Success**: Green (bg-green-500, text-green-800)
- **Error**: Red (bg-red-500, text-red-800)
- **Warning**: Yellow (bg-yellow-500, text-yellow-800)
- **Info**: Blue (bg-blue-500, text-blue-800)
- **Pending**: Orange (bg-orange-500, text-orange-800)
- **Approved**: Green (bg-green-500, text-green-800)
- **Rejected**: Red (bg-red-500, text-red-800)

### Icons
- **Success**: CheckCircle
- **Error**: XCircle
- **Warning**: AlertTriangle
- **Info**: Info
- **Pending**: Clock
- **Approved**: CheckCircle
- **Rejected**: XCircle

## Penggunaan

### Basic Usage
```javascript
import useNotification from '../hooks/useNotification';

const MyComponent = () => {
  const { showSuccess, showError } = useNotification();
  
  const handleSubmit = async () => {
    try {
      // ... logic
      showSuccess('Berhasil!', 'Data berhasil disimpan');
    } catch (error) {
      showError('Error!', 'Terjadi kesalahan saat menyimpan');
    }
  };
  
  return (
    <>
      <NotificationContainer />
      {/* component content */}
    </>
  );
};
```

### Custom Notification
```javascript
const { addNotification } = useNotification();

addNotification({
  type: 'warning',
  title: 'Peringatan',
  message: 'Data akan dihapus permanen',
  duration: 10000, // 10 seconds
  position: 'top-center'
});
```

## Konfigurasi

### Default Settings
- **Duration**: 5000ms (5 detik)
- **Position**: 'top-right'
- **Max Notifications**: Unlimited (dapat diatur di useNotification hook)
- **Animation**: Fade in/out dengan transform

### Customization
Semua pengaturan dapat disesuaikan melalui props atau dengan memodifikasi hook:

```javascript
// Di useNotification.js
const defaultDuration = 5000;
const defaultPosition = 'top-right';
const maxNotifications = 5; // Batasi jumlah notifikasi
```

## Best Practices

1. **Gunakan Helper Functions**: Gunakan `showPengajuanSuccess`, `showPengajuanApproved`, dll. untuk konsistensi
2. **Jangan Overuse**: Jangan tampilkan notifikasi untuk setiap aksi kecil
3. **Clear Messages**: Pesan harus jelas dan actionable
4. **Consistent Timing**: Gunakan durasi yang konsisten untuk tipe notifikasi yang sama
5. **Error Handling**: Selalu gunakan notifikasi error untuk error handling

## Troubleshooting

### Notifikasi Tidak Muncul
1. Pastikan `NotificationContainer` sudah diimport dan digunakan
2. Periksa console untuk error JavaScript
3. Pastikan hook `useNotification` sudah diimport dengan benar

### Notifikasi Tidak Hilang
1. Periksa `duration` setting
2. Pastikan `onClose` callback berfungsi
3. Periksa state management di hook

### Styling Issues
1. Pastikan Tailwind CSS sudah terinstall
2. Periksa class names yang digunakan
3. Pastikan tidak ada CSS conflicts

## Future Enhancements

1. **Sound Notifications**: Tambahkan audio feedback
2. **Toast Queue**: Antrian untuk notifikasi yang banyak
3. **Custom Animations**: Lebih banyak variasi animasi
4. **Notification History**: Simpan riwayat notifikasi
5. **User Preferences**: Pengaturan notifikasi per user
6. **Push Notifications**: Notifikasi browser push
7. **Email Integration**: Kirim notifikasi via email

## Dependencies

- **React**: 18+
- **Lucide React**: Untuk icons
- **Tailwind CSS**: Untuk styling
- **Custom Hooks**: useNotification

## File Structure

```
src/
├── components/
│   ├── Notification.js
│   └── NotificationContainer.js
├── hooks/
│   └── useNotification.js
└── pages/
    ├── Pengajuan.js (menggunakan notification)
    └── Persetujuan.js (menggunakan notification)
```

## Testing

### Unit Tests
- Test setiap tipe notifikasi
- Test auto-close functionality
- Test error handling
- Test custom duration dan position

### Integration Tests
- Test notifikasi di halaman Pengajuan
- Test notifikasi di halaman Persetujuan
- Test multiple notifications
- Test notification stacking

### Manual Testing
1. Submit pengajuan baru (harus muncul notifikasi sukses)
2. Approve/reject pengajuan (harus muncul notifikasi sesuai status)
3. Test error scenarios
4. Test multiple notifications
5. Test auto-close functionality
