package routes

import (
	"web-work-request-backend/handlers"
	"web-work-request-backend/middleware"

	"github.com/gin-gonic/gin"
)

func SetupRoutes(handler *handlers.Handler) *gin.Engine {
	// Configure Gin to prevent automatic redirects
	gin.SetMode(gin.ReleaseMode)
	r := gin.New()

	// Add recovery and logger middleware
	r.Use(gin.Recovery())
	r.Use(gin.Logger())

	// Add CORS middleware
	r.Use(middleware.CORSMiddleware())

	// Health check
	r.GET("/health", handler.HealthCheck)

	// Public routes
	api := r.Group("/api")
	{
		// Auth routes
		auth := api.Group("/auth")
		{
			auth.POST("/register", handler.Register)
			auth.POST("/login", handler.Login)
		}

		// Protected routes - User management
		users := api.Group("/users")
		users.Use(middleware.AuthMiddleware())
		{
			users.GET("/me", handler.GetCurrentUser)
			users.GET("", handler.GetAllUsers) // Remove trailing slash to prevent 301
			users.GET("/:id", handler.GetUserByID)
			users.POST("", handler.CreateUser) // Remove trailing slash
			users.PUT("/:id", handler.UpdateUser)
			users.DELETE("/:id", handler.DeleteUser)
		}

		// Dashboard routes
		dashboard := api.Group("/dashboard")
		dashboard.Use(middleware.AuthMiddleware())
		{
			dashboard.GET("/stats", handler.GetDashboardStats)
		}

		// Protected routes - Requests
		requests := api.Group("/requests")
		requests.Use(middleware.AuthMiddleware())
		{
			requests.POST("", handler.CreateRequest) // Remove trailing slash
			requests.GET("", handler.GetAllRequests) // Remove trailing slash
			requests.GET("/my-requests", handler.GetRequestsByUser)
			requests.GET("/:id", handler.GetRequestByID)
			requests.PUT("/:id/status", handler.UpdateRequestStatus)
			requests.DELETE("/:id", handler.DeleteRequest)
		}

		// Operator-only routes
		operator := api.Group("/operator")
		operator.Use(middleware.AuthMiddleware())
		operator.Use(middleware.OperatorMiddleware())
		{
			// These routes are only accessible by operators
			// The middleware ensures role-based access control
		}
	}

	return r
}
