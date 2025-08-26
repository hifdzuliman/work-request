package repository

import (
	"database/sql"
	"fmt"
	"time"
	"web-work-request-backend/models"
)

type Repository struct {
	db *sql.DB
}

func NewRepository(db *sql.DB) *Repository {
	return &Repository{db: db}
}

// UserRepository methods
func (r *Repository) CreateUser(user *models.User) error {
	query := `
		INSERT INTO users (username, password_hash, name, email, unit, role)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, created_at, updated_at`

	return r.db.QueryRow(
		query,
		user.Username,
		user.PasswordHash,
		user.Name,
		user.Email,
		user.Unit,
		user.Role,
	).Scan(&user.ID, &user.CreatedAt, &user.UpdatedAt)
}

func (r *Repository) GetUserByUsername(username string) (*models.User, error) {
	user := &models.User{}
	query := `SELECT * FROM users WHERE username = $1`

	err := r.db.QueryRow(query, username).Scan(
		&user.ID,
		&user.Username,
		&user.PasswordHash,
		&user.Name,
		&user.Email,
		&user.Unit,
		&user.Role,
		&user.CreatedAt,
		&user.UpdatedAt,
	)

	if err != nil {
		return nil, err
	}

	return user, nil
}

func (r *Repository) GetUserByEmail(email string) (*models.User, error) {
	user := &models.User{}
	query := `SELECT * FROM users WHERE email = $1`

	err := r.db.QueryRow(query, email).Scan(
		&user.ID,
		&user.Username,
		&user.PasswordHash,
		&user.Name,
		&user.Email,
		&user.Unit,
		&user.Role,
		&user.CreatedAt,
		&user.UpdatedAt,
	)

	if err != nil {
		return nil, err
	}

	return user, nil
}

func (r *Repository) UpdateUser(user *models.User) error {
	query := `
		UPDATE users 
		SET name = $1, email = $2, unit = $3, role = $4, updated_at = CURRENT_TIMESTAMP
		WHERE id = $5`

	_, err := r.db.Exec(query, user.Name, user.Email, user.Unit, user.Role, user.ID)
	return err
}

func (r *Repository) DeleteUser(id string) error {
	query := `DELETE FROM users WHERE id = $1`
	_, err := r.db.Exec(query, id)
	return err
}

func (r *Repository) GetUserByID(id string) (*models.User, error) {
	user := &models.User{}
	query := `SELECT * FROM users WHERE id = $1`

	err := r.db.QueryRow(query, id).Scan(
		&user.ID,
		&user.Username,
		&user.PasswordHash,
		&user.Name,
		&user.Email,
		&user.Unit,
		&user.Role,
		&user.CreatedAt,
		&user.UpdatedAt,
	)

	if err != nil {
		return nil, err
	}

	return user, nil
}

func (r *Repository) GetAllUsers() ([]models.User, error) {
	query := `SELECT * FROM users ORDER BY created_at DESC`
	rows, err := r.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var users []models.User
	for rows.Next() {
		var user models.User
		err := rows.Scan(
			&user.ID,
			&user.Username,
			&user.PasswordHash,
			&user.Name,
			&user.Email,
			&user.Unit,
			&user.Role,
			&user.CreatedAt,
			&user.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		users = append(users, user)
	}

	return users, nil
}

// RequestRepository methods
func (r *Repository) CreateRequest(request *models.Request) error {
	query := `
		INSERT INTO request (
			jenis_request, unit, nama_barang, type_model, jumlah, lokasi, 
			jenis_pekerjaan, kegunaan, tgl_request, tgl_peminjaman, 
			tgl_pengembalian, keterangan, status_request, requested_by
		)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
		RETURNING id, created_at, updated_at`

	// Parse dates
	tglRequest, _ := time.Parse("2006-01-02", request.TglRequest.Format("2006-01-02"))

	var tglPeminjaman *time.Time
	if request.TglPeminjaman != nil {
		parsed, _ := time.Parse("2006-01-02", request.TglPeminjaman.Format("2006-01-02"))
		tglPeminjaman = &parsed
	}

	var tglPengembalian *time.Time
	if request.TglPengembalian != nil {
		parsed, _ := time.Parse("2006-01-02", request.TglPengembalian.Format("2006-01-02"))
		tglPengembalian = &parsed
	}

	return r.db.QueryRow(
		query,
		request.JenisRequest,
		request.Unit,
		request.NamaBarang,
		request.TypeModel,
		request.Jumlah,
		request.Lokasi,
		request.JenisPekerjaan,
		request.Kegunaan,
		tglRequest,
		tglPeminjaman,
		tglPengembalian,
		request.Keterangan,
		request.StatusRequest,
		request.RequestedBy,
	).Scan(&request.ID, &request.CreatedAt, &request.UpdatedAt)
}

func (r *Repository) GetRequestByID(id string) (*models.Request, error) {
	// Get request
	requestQuery := `SELECT * FROM request WHERE id = $1`
	request := &models.Request{}

	err := r.db.QueryRow(requestQuery, id).Scan(
		&request.ID,
		&request.JenisRequest,
		&request.Unit,
		&request.NamaBarang,
		&request.TypeModel,
		&request.Jumlah,
		&request.Lokasi,
		&request.JenisPekerjaan,
		&request.Kegunaan,
		&request.TglRequest,
		&request.TglPeminjaman,
		&request.TglPengembalian,
		&request.Keterangan,
		&request.StatusRequest,
		&request.RequestedBy,
		&request.ApprovedBy,
		&request.AcceptedBy,
		&request.CreatedAt,
		&request.UpdatedAt,
	)

	if err != nil {
		return nil, err
	}

	return request, nil
}

func (r *Repository) GetAllRequests() ([]models.Request, error) {
	query := `SELECT * FROM request ORDER BY created_at DESC`
	rows, err := r.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var requests []models.Request
	for rows.Next() {
		var request models.Request
		err := rows.Scan(
			&request.ID,
			&request.JenisRequest,
			&request.Unit,
			&request.NamaBarang,
			&request.TypeModel,
			&request.Jumlah,
			&request.Lokasi,
			&request.JenisPekerjaan,
			&request.Kegunaan,
			&request.TglRequest,
			&request.TglPeminjaman,
			&request.TglPengembalian,
			&request.Keterangan,
			&request.StatusRequest,
			&request.RequestedBy,
			&request.ApprovedBy,
			&request.AcceptedBy,
			&request.CreatedAt,
			&request.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}

		requests = append(requests, request)
	}

	return requests, nil
}

func (r *Repository) GetRequestsByStatus(status string) ([]models.Request, error) {
	query := `SELECT * FROM request WHERE status_request = $1 ORDER BY created_at DESC`
	rows, err := r.db.Query(query, status)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var requests []models.Request
	for rows.Next() {
		var request models.Request
		err := rows.Scan(
			&request.ID,
			&request.JenisRequest,
			&request.Unit,
			&request.NamaBarang,
			&request.TypeModel,
			&request.Jumlah,
			&request.Lokasi,
			&request.JenisPekerjaan,
			&request.Kegunaan,
			&request.TglRequest,
			&request.TglPeminjaman,
			&request.TglPengembalian,
			&request.Keterangan,
			&request.StatusRequest,
			&request.RequestedBy,
			&request.ApprovedBy,
			&request.AcceptedBy,
			&request.CreatedAt,
			&request.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}

		requests = append(requests, request)
	}

	return requests, nil
}

func (r *Repository) UpdateRequestStatus(id string, status string, approvedBy *string, acceptedBy *string, keterangan string) error {
	query := `
		UPDATE request 
		SET status_request = $1, approved_by = $2, accepted_by = $3, keterangan = $4, updated_at = CURRENT_TIMESTAMP
		WHERE id = $5`

	result, err := r.db.Exec(query, status, approvedBy, acceptedBy, keterangan, id)
	if err != nil {
		return err
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return err
	}

	if rowsAffected == 0 {
		return fmt.Errorf("request not found")
	}

	return nil
}

func (r *Repository) DeleteRequest(id string) error {
	query := `DELETE FROM request WHERE id = $1`

	result, err := r.db.Exec(query, id)
	if err != nil {
		return err
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return err
	}

	if rowsAffected == 0 {
		return fmt.Errorf("request not found")
	}

	return nil
}

// Dashboard repository methods
func (r *Repository) GetRequestCount() (int, error) {
	var count int
	query := `SELECT COUNT(*) FROM request`
	err := r.db.QueryRow(query).Scan(&count)
	return count, err
}

func (r *Repository) GetPendingRequestCount() (int, error) {
	var count int
	query := `SELECT COUNT(*) FROM request WHERE status_request = 'DIAJUKAN'`
	err := r.db.QueryRow(query).Scan(&count)
	return count, err
}

func (r *Repository) GetUserCount() (int, error) {
	var count int
	query := `SELECT COUNT(*) FROM users`
	err := r.db.QueryRow(query).Scan(&count)
	return count, err
}
