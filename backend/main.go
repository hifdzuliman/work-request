package main

import (
	"log"
	"web-work-request-backend/config"
	"web-work-request-backend/database"
	"web-work-request-backend/handlers"
	"web-work-request-backend/repository"
	"web-work-request-backend/routes"
	"web-work-request-backend/services"
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

	// Initialize repository, service, and handler
	repo := repository.NewRepository(db)
	service := services.NewService(repo)
	handler := handlers.NewHandler(service)

	// Setup routes
	router := routes.SetupRoutes(handler)

	log.Printf("Server starting on port %s", cfg.ServerPort)

	// Start server
	err = router.Run(":" + cfg.ServerPort)
	if err != nil {
		log.Fatal("Failed to start server:", err)
	}
}
