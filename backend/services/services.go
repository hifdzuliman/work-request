package services

import (
	"errors"
	"fmt"
	"time"
	"web-work-request-backend/models"
	"web-work-request-backend/repository"
	"web-work-request-backend/utils"
)

type Service struct {
	repo *repository.Repository
}

func NewService(repo *repository.Repository) *Service {
	return &Service{repo: repo}
}

// UserService methods
func (s *Service) RegisterUser(req *models.RegisterRequest) (*models.User, error) {
	// Check if username already exists
	existingUser, _ := s.repo.GetUserByUsername(req.Username)
	if existingUser != nil {
		return nil, errors.New("username already exists")
	}

	// Hash password
	hashedPassword, err := utils.HashPassword(req.Password)
	if err != nil {
		return nil, err
	}

	// Create user
	user := &models.User{
		Username:     req.Username,
		PasswordHash: hashedPassword,
		Name:         req.Name,
		Email:        req.Email,
		Unit:         req.Unit,
		Role:         req.Role,
	}

	err = s.repo.CreateUser(user)
	if err != nil {
		return nil, err
	}

	return user, nil
}

// Dashboard service methods
func (s *Service) GetDashboardStats(userID string) (*models.DashboardStats, error) {
	// Get user to check role
	user, err := s.repo.GetUserByID(userID)
	if err != nil {
		return nil, err
	}

	// Get counts from repository
	stats := &models.DashboardStats{
		UserID: userID,
		Role:   user.Role,
	}

	// Get request counts
	stats.TotalPengajuan, _ = s.repo.GetRequestCount()
	stats.TotalRiwayat, _ = s.repo.GetRequestCount()

	// Operator-specific stats
	if user.Role == "operator" {
		stats.TotalPersetujuan, _ = s.repo.GetPendingRequestCount()
		stats.TotalPengguna, _ = s.repo.GetUserCount()
	}

	return stats, nil
}

func (s *Service) LoginUser(req *models.LoginRequest) (*models.AuthResponse, error) {
	// Get user by username
	user, err := s.repo.GetUserByUsername(req.Username)
	if err != nil {
		return nil, errors.New("invalid credentials")
	}

	// Check password
	if !utils.CheckPasswordHash(req.Password, user.PasswordHash) {
		return nil, errors.New("invalid credentials")
	}

	// Generate JWT token
	token, err := utils.GenerateJWT(user.ID.String(), user.Username, user.Role)
	if err != nil {
		return nil, err
	}

	return &models.AuthResponse{
		Token: token,
		User:  *user,
	}, nil
}

func (s *Service) GetAllUsers() ([]models.User, error) {
	return s.repo.GetAllUsers()
}

func (s *Service) GetUserByID(id string) (*models.User, error) {
	return s.repo.GetUserByID(id)
}

func (s *Service) CreateUser(req *models.CreateUserRequest) (*models.User, error) {
	// Check if username already exists
	existingUser, _ := s.repo.GetUserByUsername(req.Username)
	if existingUser != nil {
		return nil, errors.New("username already exists")
	}

	// Check if email already exists
	existingEmail, _ := s.repo.GetUserByEmail(req.Email)
	if existingEmail != nil {
		return nil, errors.New("email already exists")
	}

	// Hash password
	hashedPassword, err := utils.HashPassword(req.Password)
	if err != nil {
		return nil, err
	}

	// Create user
	user := &models.User{
		Username:     req.Username,
		PasswordHash: hashedPassword,
		Name:         req.Name,
		Email:        req.Email,
		Unit:         req.Unit,
		Role:         req.Role,
	}

	err = s.repo.CreateUser(user)
	if err != nil {
		return nil, err
	}

	return user, nil
}

func (s *Service) UpdateUser(id string, req *models.UpdateUserRequest) (*models.User, error) {
	// Get existing user
	existingUser, err := s.repo.GetUserByID(id)
	if err != nil {
		return nil, err
	}

	// Update fields if provided
	if req.Name != "" {
		existingUser.Name = req.Name
	}
	if req.Email != "" {
		// Check if email already exists for other users
		if req.Email != existingUser.Email {
			existingEmail, _ := s.repo.GetUserByEmail(req.Email)
			if existingEmail != nil {
				return nil, errors.New("email already exists")
			}
		}
		existingUser.Email = req.Email
	}
	if req.Unit != "" {
		existingUser.Unit = req.Unit
	}
	if req.Role != "" {
		existingUser.Role = req.Role
	}

	// Update user
	err = s.repo.UpdateUser(existingUser)
	if err != nil {
		return nil, err
	}

	return existingUser, nil
}

func (s *Service) DeleteUser(id string) error {
	// Check if user exists
	_, err := s.repo.GetUserByID(id)
	if err != nil {
		return err
	}

	// Delete user
	return s.repo.DeleteUser(id)
}

// RequestService methods
func (s *Service) CreateRequest(req *models.CreateRequestRequest, userID string) (*models.Request, error) {
	// Get user to check role and get unit
	user, err := s.repo.GetUserByID(userID)
	if err != nil {
		return nil, err
	}

	// Parse request date
	tglRequest, err := time.Parse("2006-01-02", req.TglRequest)
	if err != nil {
		return nil, fmt.Errorf("invalid request date format: %v", err)
	}

	// Parse optional dates
	var tglPeminjaman *time.Time
	if req.TglPeminjaman != nil && *req.TglPeminjaman != "" {
		parsed, err := time.Parse("2006-01-02", *req.TglPeminjaman)
		if err != nil {
			return nil, fmt.Errorf("invalid peminjaman date format: %v", err)
		}
		tglPeminjaman = &parsed
	}

	var tglPengembalian *time.Time
	if req.TglPengembalian != nil && *req.TglPengembalian != "" {
		parsed, err := time.Parse("2006-01-02", *req.TglPengembalian)
		if err != nil {
			return nil, fmt.Errorf("invalid pengembalian date format: %v", err)
		}
		tglPengembalian = &parsed
	}

	// Create request
	request := &models.Request{
		JenisRequest:    req.JenisRequest,
		Unit:            req.Unit,
		NamaBarang:      req.NamaBarang,
		TypeModel:       req.TypeModel,
		Jumlah:          req.Jumlah,
		Lokasi:          req.Lokasi,
		JenisPekerjaan:  req.JenisPekerjaan,
		Kegunaan:        req.Kegunaan,
		TglRequest:      tglRequest,
		TglPeminjaman:   tglPeminjaman,
		TglPengembalian: tglPengembalian,
		Keterangan:      req.Keterangan,
		StatusRequest:   "DIAJUKAN",
		RequestedBy:     user.Name,
	}

	// Save to database
	err = s.repo.CreateRequest(request)
	if err != nil {
		return nil, err
	}

	return request, nil
}

func (s *Service) GetRequestByID(id string) (*models.Request, error) {
	return s.repo.GetRequestByID(id)
}

func (s *Service) GetAllRequests() ([]models.Request, error) {
	return s.repo.GetAllRequests()
}

func (s *Service) GetRequestsByStatus(status string) ([]models.Request, error) {
	return s.repo.GetRequestsByStatus(status)
}

func (s *Service) UpdateRequestStatus(id string, req *models.UpdateRequestRequest) error {
	return s.repo.UpdateRequestStatus(id, req.StatusRequest, req.ApprovedBy, req.AcceptedBy, req.Keterangan)
}

func (s *Service) DeleteRequest(id string) error {
	return s.repo.DeleteRequest(id)
}

// GetRequestsByUser returns requests created by a specific user
func (s *Service) GetRequestsByUser(userID string) ([]models.Request, error) {
	// This would need to be implemented in the repository
	// For now, we'll get all and filter by requested_by
	allRequests, err := s.repo.GetAllRequests()
	if err != nil {
		return nil, err
	}

	// Get user to check requested_by
	user, err := s.repo.GetUserByID(userID)
	if err != nil {
		return nil, err
	}

	var userRequests []models.Request
	for _, req := range allRequests {
		if req.RequestedBy == user.Name {
			userRequests = append(userRequests, req)
		}
	}

	return userRequests, nil
}
