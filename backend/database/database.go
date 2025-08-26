package database

import (
	"database/sql"
	"fmt"
	"log"
	"web-work-request-backend/config"

	_ "github.com/lib/pq"
)

func InitDB(cfg *config.Config) (*sql.DB, error) {
	log.Println("Initializing database with config:", cfg)
	psqlInfo := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=%s",
		cfg.DBHost, cfg.DBPort, cfg.DBUser, cfg.DBPassword, cfg.DBName, cfg.DBSSLMode)

	db, err := sql.Open("postgres", psqlInfo)
	if err != nil {
		return nil, err
	}

	if err = db.Ping(); err != nil {
		return nil, err
	}

	log.Println("Successfully connected to database")

	// Create tables if they don't exist
	if err := createTables(db); err != nil {
		return nil, err
	}

	return db, nil
}

func createTables(db *sql.DB) error {
	// Users table
	createUsersTable := `
	CREATE TABLE IF NOT EXISTS users (
		id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
		username VARCHAR(50) UNIQUE NOT NULL,
		password_hash VARCHAR(255) NOT NULL,
		name VARCHAR(100) NOT NULL,
		email VARCHAR(100) UNIQUE NOT NULL,
		unit VARCHAR(50) NOT NULL,
		role VARCHAR(20) NOT NULL DEFAULT 'user',
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	);`

	// Requests table
	createRequestsTable := `
	CREATE TABLE IF NOT EXISTS request (
		id BIGSERIAL PRIMARY KEY,
		jenis_request VARCHAR(50) NOT NULL,
		unit VARCHAR(100),
		nama_barang VARCHAR(200),
		type_model VARCHAR(100),
		jumlah INT,
		lokasi VARCHAR(200),
		jenis_pekerjaan TEXT,
		kegunaan TEXT,
		tgl_request DATE,
		tgl_peminjaman DATE,
		tgl_pengembalian DATE,
		keterangan TEXT,
		status_request VARCHAR(50) DEFAULT 'DIAJUKAN',
		requested_by VARCHAR(100),
		approved_by VARCHAR(100),
		accepted_by VARCHAR(100),
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	);`

	// Execute table creation
	tables := []string{
		createUsersTable,
		createRequestsTable,
	}

	for _, table := range tables {
		if _, err := db.Exec(table); err != nil {
			return fmt.Errorf("failed to create table: %v", err)
		}
	}

	log.Println("Database tables created successfully")
	return nil
}
