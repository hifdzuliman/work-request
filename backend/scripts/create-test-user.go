package main

import (
	"database/sql"
	"fmt"
	"log"
	"web-work-request-backend/config"
	"web-work-request-backend/database"
	"web-work-request-backend/utils"

	_ "github.com/lib/pq"
)

func main() {
	// Load configuration
	cfg := config.Load()

	// Initialize database
	db, err := database.InitDB(cfg)
	if err != nil {
		log.Fatal("Failed to initialize database:", err)
	}
	defer db.Close()

	// Create test user
	if err := createTestUser(db); err != nil {
		log.Fatal("Failed to create test user:", err)
	}

	log.Println("Test user created successfully!")
}

func createTestUser(db *sql.DB) error {
	// Hash password for 'admin123'
	password := "admin123"
	hashedPassword, err := utils.HashPassword(password)
	if err != nil {
		return fmt.Errorf("failed to hash password: %v", err)
	}

	// Check if user already exists
	var existingUser string
	err = db.QueryRow("SELECT username FROM users WHERE username = $1", "hifdzul").Scan(&existingUser)
	if err == nil {
		// User exists, update password
		_, err = db.Exec(`
			UPDATE users 
			SET password_hash = $1, updated_at = CURRENT_TIMESTAMP 
			WHERE username = $2
		`, hashedPassword, "hifdzul")
		if err != nil {
			return fmt.Errorf("failed to update user: %v", err)
		}
		log.Println("Updated existing user 'hifdzul'")
		return nil
	}

	// User doesn't exist, create new user
	_, err = db.Exec(`
		INSERT INTO users (username, password_hash, name, email, unit, role)
		VALUES ($1, $2, $3, $4, $5, $6)
	`, "hifdzul", hashedPassword, "Hifdzul Test User", "hifdzul@test.com", "IT Department", "operator")

	if err != nil {
		return fmt.Errorf("failed to create user: %v", err)
	}

	log.Println("Created new user 'hifdzul'")
	return nil
}

