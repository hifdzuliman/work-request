# Web Work Request Backend

Backend service for the Web Work Request application built with Go, Gin, and PostgreSQL.

## Features

- **Authentication & Authorization**: JWT-based authentication with role-based access control
- **User Management**: User registration, login, and profile management
- **Work Request Management**: Create, read, update, and delete work requests
- **Activity & Item Management**: Support for multiple activities with multiple items per activity
- **Role-based Access Control**: Different permissions for regular users and operators
- **RESTful API**: Clean REST API design with proper HTTP status codes

## Prerequisites

- Go 1.21 or higher
- PostgreSQL 12 or higher
- Git

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd web-work-request-backend
   ```

2. **Install Go dependencies**
   ```bash
   go mod tidy
   ```

3. **Set up environment variables**
   Create a `config.env` file in the backend directory:
   ```env
   DB_HOST=localhost
   DB_PORT=5432
   DB_USER=postgres
   DB_PASSWORD=your_password
   DB_NAME=web_work_request
   DB_SSLMODE=disable
   JWT_SECRET=your-secret-key-here
   JWT_EXPIRY=24h
   SERVER_PORT=8080
   SERVER_MODE=debug
   ```

4. **Set up PostgreSQL database**
   ```sql
   CREATE DATABASE web_work_request;
   ```

## Running the Application

1. **Start the server**
   ```bash
   go run main.go
   ```

2. **The server will start on port 8080 (or the port specified in config.env)**

## API Endpoints

### Public Endpoints
- `GET /health` - Health check
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login

### Protected Endpoints (Require Authentication)
- `GET /api/users` - Get all users
- `GET /api/users/:id` - Get user by ID
- `POST /api/work-requests` - Create work request
- `GET /api/work-requests` - Get all work requests
- `GET /api/work-requests/my-requests` - Get user's work requests
- `GET /api/work-requests/:id` - Get work request by ID
- `PUT /api/work-requests/:id/status` - Update work request status
- `DELETE /api/work-requests/:id` - Delete work request

### Authentication

All protected endpoints require a valid JWT token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```

## Database Schema

### Users Table
- `id` - UUID (Primary Key)
- `username` - VARCHAR(50) UNIQUE
- `password_hash` - VARCHAR(255)
- `name` - VARCHAR(100)
- `email` - VARCHAR(100) UNIQUE
- `unit` - VARCHAR(50)
- `role` - VARCHAR(20) (user/operator)
- `created_at` - TIMESTAMP
- `updated_at` - TIMESTAMP

### Work Requests Table
- `id` - UUID (Primary Key)
- `unit` - VARCHAR(50)
- `pemohon` - VARCHAR(100)
- `approver` - VARCHAR(100)
- `tanggal_pengajuan` - DATE
- `status` - VARCHAR(20) (pending/approved/rejected)
- `catatan` - TEXT
- `created_at` - TIMESTAMP
- `updated_at` - TIMESTAMP

### Activities Table
- `id` - UUID (Primary Key)
- `work_request_id` - UUID (Foreign Key)
- `kebutuhan` - VARCHAR(255)
- `created_at` - TIMESTAMP

### Items Table
- `id` - UUID (Primary Key)
- `activity_id` - UUID (Foreign Key)
- `nama_barang` - VARCHAR(255)
- `jumlah_barang` - INTEGER
- `keterangan` - TEXT
- `created_at` - TIMESTAMP

## Project Structure

```
backend/
├── config/          # Configuration management
├── database/        # Database connection and schema
├── handlers/        # HTTP request handlers
├── middleware/      # Authentication and authorization middleware
├── models/          # Data models and structs
├── repository/      # Data access layer
├── routes/          # API route definitions
├── services/        # Business logic layer
├── utils/           # Utility functions
├── config.env       # Environment configuration
├── go.mod           # Go module file
├── go.sum           # Go module checksums
├── main.go          # Application entry point
└── README.md        # This file
```

## Development

### Adding New Endpoints

1. Add the handler function in `handlers/handlers.go`
2. Add the route in `routes/routes.go`
3. Add any necessary business logic in `services/services.go`
4. Add data access methods in `repository/repository.go`

### Testing

```bash
go test ./...
```

### Building

```bash
go build -o web-work-request-backend main.go
```

## Security Features

- Password hashing using bcrypt
- JWT token-based authentication
- Role-based access control
- Input validation and sanitization
- CORS middleware for cross-origin requests

## Error Handling

The API returns consistent error responses:
```json
{
  "error": "Error message description"
}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.
