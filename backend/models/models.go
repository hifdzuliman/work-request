package models

import (
	"time"

	"github.com/google/uuid"
)

// User represents a user in the system
type User struct {
	ID           uuid.UUID `json:"id" db:"id"`
	Username     string    `json:"username" db:"username"`
	PasswordHash string    `json:"-" db:"password_hash"`
	Name         string    `json:"name" db:"name"`
	Email        string    `json:"email" db:"email"`
	Unit         string    `json:"unit" db:"unit"`
	Role         string    `json:"role" db:"role"`
	CreatedAt    time.Time `json:"created_at" db:"created_at"`
	UpdatedAt    time.Time `json:"updated_at" db:"updated_at"`
}

// Request represents a request (pengadaan, perbaikan, peminjaman)
type Request struct {
	ID           int64  `json:"id" db:"id"`
	JenisRequest string `json:"jenis_request" db:"jenis_request"`
	Unit         string `json:"unit" db:"unit"`

	// For pengadaan: array fields
	NamaBarangArray []string `json:"nama_barang_array" db:"nama_barang_array"`
	TypeModelArray  []string `json:"type_model_array" db:"type_model_array"`
	JumlahArray     []int    `json:"jumlah_array" db:"jumlah_array"`
	KeteranganArray []string `json:"keterangan_array" db:"keterangan_array"`

	// For perbaikan: array fields (new approach)
	NamaBarangPerbaikanArray []string `json:"nama_barang_perbaikan_array" db:"nama_barang_perbaikan_array"`
	TypeModelPerbaikanArray  []string `json:"type_model_perbaikan_array" db:"type_model_perbaikan_array"`
	JumlahPerbaikanArray     []int    `json:"jumlah_perbaikan_array" db:"jumlah_perbaikan_array"`
	JenisPekerjaanArray      []string `json:"jenis_pekerjaan_array" db:"jenis_pekerjaan_array"`
	LokasiPerbaikanArray     []string `json:"lokasi_perbaikan_array" db:"lokasi_perbaikan_array"`

	// For peminjaman: array fields (new approach)
	LokasiPeminjamanArray []string    `json:"lokasi_peminjaman_array" db:"lokasi_peminjaman_array"`
	KegunaanArray         []string    `json:"kegunaan_array" db:"kegunaan_array"`
	TglPeminjamanArray    []time.Time `json:"tgl_peminjaman_array" db:"tgl_peminjaman_array"`
	TglPengembalianArray  []time.Time `json:"tgl_pengembalian_array" db:"tgl_pengembalian_array"`

	// Legacy single fields for backward compatibility
	NamaBarang      *string    `json:"nama_barang" db:"nama_barang"`
	TypeModel       *string    `json:"type_model" db:"type_model"`
	Jumlah          *int       `json:"jumlah" db:"jumlah"`
	JenisPekerjaan  *string    `json:"jenis_pekerjaan" db:"jenis_pekerjaan"`
	Lokasi          *string    `json:"lokasi" db:"lokasi"`
	Kegunaan        *string    `json:"kegunaan" db:"kegunaan"`
	TglPeminjaman   *time.Time `json:"tgl_peminjaman" db:"tgl_peminjaman"`
	TglPengembalian *time.Time `json:"tgl_pengembalian" db:"tgl_pengembalian"`

	// Common fields
	TglRequest    *time.Time `json:"tgl_request" db:"tgl_request"`
	Keterangan    *string    `json:"keterangan" db:"keterangan"`
	StatusRequest string     `json:"status_request" db:"status_request"`
	RequestedBy   string     `json:"requested_by" db:"requested_by"`
	ApprovedBy    *string    `json:"approved_by" db:"approved_by"`
	AcceptedBy    *string    `json:"accepted_by" db:"accepted_by"`
	CreatedAt     time.Time  `json:"created_at" db:"created_at"`
	UpdatedAt     time.Time  `json:"updated_at" db:"updated_at"`
}

// CreateRequestRequest represents the request to create a request
type CreateRequestRequest struct {
	JenisRequest string `json:"jenis_request" binding:"required,oneof=pengadaan perbaikan peminjaman"`
	Unit         string `json:"unit" binding:"required"`

	// For pengadaan: array fields
	NamaBarangArray []string `json:"nama_barang_array"`
	TypeModelArray  []string `json:"type_model_array"`
	JumlahArray     []int    `json:"jumlah_array"`
	KeteranganArray []string `json:"keterangan_array"`

	// For perbaikan: array fields (new approach)
	NamaBarangPerbaikanArray []string `json:"nama_barang_perbaikan_array"`
	TypeModelPerbaikanArray  []string `json:"type_model_perbaikan_array"`
	JumlahPerbaikanArray     []int    `json:"jumlah_perbaikan_array"`
	JenisPekerjaanArray      []string `json:"jenis_pekerjaan_array"`
	LokasiPerbaikanArray     []string `json:"lokasi_perbaikan_array"`

	// For peminjaman: array fields (new approach)
	LokasiPeminjamanArray []string `json:"lokasi_peminjaman_array"`
	KegunaanArray         []string `json:"kegunaan_array"`
	TglPeminjamanArray    []string `json:"tgl_peminjaman_array"`
	TglPengembalianArray  []string `json:"tgl_pengembalian_array"`

	// Legacy single fields for backward compatibility
	NamaBarang      *string `json:"nama_barang"`
	TypeModel       *string `json:"type_model"`
	Jumlah          *int    `json:"jumlah"`
	JenisPekerjaan  *string `json:"jenis_pekerjaan"`
	Lokasi          *string `json:"lokasi"`
	Kegunaan        *string `json:"kegunaan"`
	TglPeminjaman   *string `json:"tgl_peminjaman"`
	TglPengembalian *string `json:"tgl_pengembalian"`

	// Common fields
	TglRequest string  `json:"tgl_request" binding:"required"`
	Keterangan *string `json:"keterangan"`
}

// UpdateRequestRequest represents the request to update a request
type UpdateRequestRequest struct {
	StatusRequest string  `json:"status_request" binding:"required,oneof=DIAJUKAN DISETUJUI DITOLAK DIPROSES SELESAI"`
	ApprovedBy    *string `json:"approved_by"`
	AcceptedBy    *string `json:"accepted_by"`
	Keterangan    string  `json:"keterangan"`
}

// LoginRequest represents the login request
type LoginRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

// RegisterRequest represents the registration request
type RegisterRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required,min=6"`
	Name     string `json:"name" binding:"required"`
	Email    string `json:"email" binding:"required,email"`
	Unit     string `json:"unit" binding:"required"`
	Role     string `json:"role" binding:"required,oneof=user operator"`
}

// CreateUserRequest represents the request to create a user
type CreateUserRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required,min=6"`
	Name     string `json:"name" binding:"required"`
	Email    string `json:"email" binding:"required,email"`
	Unit     string `json:"unit" binding:"required"`
	Role     string `json:"role" binding:"required,oneof=user operator"`
}

// UpdateUserRequest represents the request to update a user
type UpdateUserRequest struct {
	Name  string `json:"name,omitempty"`
	Email string `json:"email,omitempty"`
	Unit  string `json:"unit,omitempty"`
	Role  string `json:"role,omitempty" binding:"omitempty,oneof=user operator"`
}

// AuthResponse represents the authentication response
type AuthResponse struct {
	Token string `json:"token"`
	User  User   `json:"user"`
}

// PaginationRequest represents pagination parameters
type PaginationRequest struct {
	Page  int `form:"page" binding:"min=1"`
	Limit int `form:"limit" binding:"min=1,max=100"`
}

// PaginationResponse represents pagination response
type PaginationResponse struct {
	Page       int         `json:"page"`
	Limit      int         `json:"limit"`
	Total      int64       `json:"total"`
	TotalPages int         `json:"total_pages"`
	Data       interface{} `json:"data"`
}

// DashboardStats represents dashboard statistics
type DashboardStats struct {
	UserID           string `json:"user_id"`
	Role             string `json:"role"`
	TotalPengajuan   int    `json:"total_pengajuan"`
	TotalPersetujuan int    `json:"total_persetujuan"`
	TotalRiwayat     int    `json:"total_riwayat"`
	TotalPengguna    int    `json:"total_pengguna"`
}
