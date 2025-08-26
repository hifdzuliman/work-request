# 🚀 Work Request Management System

A comprehensive web-based application for managing work requests, approvals, and tracking in organizations. Built with React frontend and Go backend, featuring real-time notifications, role-based access control, and comprehensive reporting.

## 📋 Table of Contents

- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Architecture](#-architecture)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Usage](#-usage)
- [API Documentation](#-api-documentation)
- [Database Schema](#-database-schema)
- [Development](#-development)
- [Deployment](#-deployment)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)

## ✨ Features

### 🔐 **Authentication & Authorization**
- **User Management**: Register, login, profile management
- **Role-Based Access Control**: User, Operator roles
- **JWT Token Authentication**: Secure API access
- **Session Management**: Persistent login state

### 📝 **Request Management**
- **Multiple Request Types**:
  - **Pengadaan** (Procurement): Equipment and supplies requests
  - **Perbaikan** (Repair): Maintenance and repair requests  
  - **Peminjaman** (Borrowing): Equipment borrowing requests
- **Array-Based Items**: Support for multiple items per request
- **File Attachments**: Document and image uploads
- **Status Tracking**: DIAJUKAN → DISETUJUI/DITOLAK → DIPROSES → SELESAI

### 📊 **Dashboard & Analytics**
- **Real-time Statistics**: Request counts, approval rates
- **Role-specific Views**: Different dashboards for users and operators
- **Quick Actions**: Fast access to common functions
- **Activity Monitoring**: Recent request activities

### ✅ **Approval System**
- **Operator Dashboard**: Review and approve/reject requests
- **Status Updates**: Real-time status changes
- **Approval History**: Track who approved what and when
- **Bulk Operations**: Handle multiple requests efficiently

### 📚 **History & Reporting**
- **Comprehensive History**: All request records with full details
- **Advanced Filtering**: Date ranges, units, status, search
- **Data Export**: CSV export functionality
- **Real-time Sync**: Dashboard and history page synchronization

### 🔔 **Notification System**
- **Success Notifications**: Request submitted, approved, completed
- **Error Alerts**: Validation errors, API failures
- **Status Updates**: Real-time status change notifications
- **Toast Messages**: Non-intrusive user feedback

### 🎨 **User Interface**
- **Modern Design**: Clean, responsive interface
- **Mobile Responsive**: Works on all device sizes
- **Dark/Light Mode**: User preference support
- **Accessibility**: Screen reader friendly

## 🛠️ Tech Stack

### **Frontend**
- **React 18**: Modern React with hooks and context
- **Tailwind CSS**: Utility-first CSS framework
- **Lucide React**: Beautiful, customizable icons
- **React Router**: Client-side routing
- **Context API**: Global state management

### **Backend**
- **Go (Golang)**: High-performance server language
- **Gin Framework**: Fast HTTP web framework
- **PostgreSQL**: Robust relational database
- **JWT**: JSON Web Token authentication
- **GORM**: Object-relational mapping

### **Infrastructure**
- **Docker**: Containerization support
- **Environment Config**: Flexible configuration management
- **CORS Support**: Cross-origin resource sharing
- **Logging**: Comprehensive application logging

## 🏗️ Architecture

### **System Overview**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend       │    │   Database      │
│   (React)       │◄──►│   (Go/Gin)      │◄──►│   (PostgreSQL)  │
│                 │    │                 │    │                 │
│ • Components    │    │ • Handlers      │    │ • Users Table   │
│ • Contexts      │    │ • Services      │    │ • Request Table │
│ • Hooks         │    │ • Repository    │    │ • Indexes       │
│ • API Client    │    │ • Middleware    │    │ • Constraints   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### **Frontend Architecture**
```
App.js
├── AuthProvider (Authentication Context)
├── NotificationProvider (Notification System)
├── RiwayatProvider (Data Management)
└── Router
    ├── Public Routes (Login, Register)
    ├── Protected Routes (Dashboard, Requests)
    └── Role-based Routes (Operator Functions)
```

### **Backend Architecture**
```
main.go
├── Config Loading
├── Database Initialization
├── Repository Layer
├── Service Layer
├── Handler Layer
└── Route Setup
```

## 🚀 Installation

### **Prerequisites**
- **Node.js** 18+ and **npm** 9+
- **Go** 1.21+
- **PostgreSQL** 14+
- **Git**

### **1. Clone Repository**
```bash
git clone <repository-url>
cd work-request
```

### **2. Backend Setup**
```bash
cd backend

# Install Go dependencies
go mod tidy

# Set environment variables
cp .env.example .env
# Edit .env with your database credentials

# Run database migrations
psql -U your_user -d your_database -f scripts/migrate-to-request-table.sql

# Start backend server
go run main.go
```

### **3. Frontend Setup**
```bash
cd frontend

# Install dependencies
npm install

# Set environment variables
cp .env.example .env
# Edit .env with your API base URL

# Start development server
npm start
```

### **4. Database Setup**
```bash
# Connect to PostgreSQL
psql -U your_user -d your_database

# Create tables (if not using migration script)
\i scripts/migrate-to-request-table.sql

# Insert sample data (optional)
\i scripts/sample-data.sql
```

## ⚙️ Configuration

### **Environment Variables**

#### **Backend (.env)**
```env
# Server Configuration
SERVER_PORT=8080
SERVER_HOST=localhost

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_USER=your_username
DB_PASSWORD=your_password
DB_NAME=work_request_db
DB_SSL_MODE=disable

# JWT Configuration
JWT_SECRET=your_jwt_secret_key
JWT_EXPIRY=24h

# CORS Configuration
CORS_ALLOWED_ORIGINS=http://localhost:3000
```

#### **Frontend (.env)**
```env
# API Configuration
REACT_APP_API_BASE_URL=http://localhost:8080/api

# Feature Flags
REACT_APP_ENABLE_NOTIFICATIONS=true
REACT_APP_ENABLE_EXPORT=true
REACT_APP_ENABLE_FILTERS=true
```

### **Database Configuration**
```sql
-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Set timezone
SET timezone = 'Asia/Jakarta';
```

## 📖 Usage

### **User Workflow**

#### **1. User Registration & Login**
```
Register → Login → Dashboard → Create Request → Track Status
```

#### **2. Creating Requests**
1. Navigate to **Pengajuan** page
2. Select request type (Pengadaan/Perbaikan/Peminjaman)
3. Fill in required fields
4. Add multiple items if needed
5. Submit request

#### **3. Request Types**

##### **Pengadaan (Procurement)**
- Equipment and supplies requests
- Multiple items support
- Quantity and specifications
- Location and purpose

##### **Perbaikan (Repair)**
- Maintenance requests
- Equipment identification
- Work type description
- Location specification

##### **Peminjaman (Borrowing)**
- Equipment borrowing
- Duration specification
- Purpose description
- Return date planning

#### **4. Tracking Requests**
- **Dashboard**: Overview of all requests
- **Riwayat**: Detailed history and filtering
- **Notifications**: Real-time status updates

### **Operator Workflow**

#### **1. Request Review**
1. Access **Persetujuan** page
2. View pending requests
3. Review request details
4. Approve/reject with comments

#### **2. Status Management**
- **DIAJUKAN** → **DISETUJUI/DITOLAK**
- **DISETUJUI** → **DIPROSES**
- **DIPROSES** → **SELESAI**

#### **3. User Management**
- Create new users
- Assign roles and units
- Update user information
- Manage permissions

## 🔌 API Documentation

### **Authentication Endpoints**

#### **POST /api/auth/register**
```http
POST /api/auth/register
Content-Type: application/json

{
  "username": "newuser",
  "password": "securepassword",
  "name": "New User",
  "email": "user@example.com",
  "unit": "IT Department",
  "role": "user"
}
```

#### **POST /api/auth/login**
```http
POST /api/auth/login
Content-Type: application/json

{
  "username": "username",
  "password": "password"
}
```

### **Request Endpoints**

#### **GET /api/requests**
```http
GET /api/requests?page=1&limit=10&status=DISETUJUI
Authorization: Bearer <token>
```

#### **POST /api/requests**
```http
POST /api/requests
Authorization: Bearer <token>
Content-Type: application/json

{
  "jenis_request": "pengadaan",
  "unit": "IT Department",
  "nama_barang": "Laptop",
  "type_model": "Dell Latitude 5520",
  "jumlah": 2,
  "lokasi": "Kantor Pusat",
  "keterangan": "Untuk tim development baru"
}
```

#### **PUT /api/requests/{id}/status**
```http
PUT /api/requests/1/status
Authorization: Bearer <token>
Content-Type: application/json

{
  "status_request": "DISETUJUI",
  "approved_by": "operator1",
  "keterangan": "Request disetujui sesuai budget"
}
```

### **Dashboard Endpoints**

#### **GET /api/dashboard/stats**
```http
GET /api/dashboard/stats
Authorization: Bearer <token>
```

**Response:**
```json
{
  "total_pengajuan": 15,
  "total_persetujuan": 8,
  "total_riwayat": 15,
  "total_pengguna": 25
}
```

## 🗄️ Database Schema

### **Users Table**
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    unit VARCHAR(50) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### **Request Table**
```sql
CREATE TABLE request (
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
);
```

### **Indexes**
```sql
-- Performance indexes
CREATE INDEX idx_request_jenis_request ON request(jenis_request);
CREATE INDEX idx_request_unit ON request(unit);
CREATE INDEX idx_request_status_request ON request(status_request);
CREATE INDEX idx_request_requested_by ON request(requested_by);
CREATE INDEX idx_request_tgl_request ON request(tgl_request);
```

## 🧪 Development

### **Development Commands**

#### **Backend**
```bash
# Run in development mode
go run main.go

# Run tests
go test ./...

# Build binary
go build -o work-request-server

# Run with hot reload (using air)
air
```

#### **Frontend**
```bash
# Start development server
npm start

# Run tests
npm test

# Build for production
npm run build

# Lint code
npm run lint

# Format code
npm run format
```

### **Code Structure**
```
work-request/
├── backend/
│   ├── config/          # Configuration management
│   ├── database/        # Database connection & setup
│   ├── handlers/        # HTTP request handlers
│   ├── middleware/      # Authentication & CORS
│   ├── models/          # Data models & structs
│   ├── repository/      # Database operations
│   ├── routes/          # Route definitions
│   ├── services/        # Business logic
│   └── utils/           # Utility functions
├── frontend/
│   ├── public/          # Static assets
│   ├── src/
│   │   ├── components/  # Reusable components
│   │   ├── contexts/    # React contexts
│   │   ├── hooks/       # Custom hooks
│   │   ├── pages/       # Page components
│   │   ├── services/    # API services
│   │   └── utils/       # Utility functions
│   └── package.json
├── scripts/              # Database & deployment scripts
└── docs/                 # Documentation
```

### **Testing**
```bash
# Backend testing
cd backend
go test -v ./...

# Frontend testing
cd frontend
npm test

# Integration testing
npm run test:integration
```

## 🚀 Deployment

### **Production Build**

#### **Frontend**
```bash
cd frontend
npm run build
# Build artifacts in build/ directory
```

#### **Backend**
```bash
cd backend
go build -o work-request-server
# Binary ready for deployment
```

### **Docker Deployment**
```bash
# Build images
docker build -t work-request-frontend ./frontend
docker build -t work-request-backend ./backend

# Run containers
docker run -d -p 3000:3000 work-request-frontend
docker run -d -p 8080:8080 work-request-backend
```

### **Environment Setup**
```bash
# Production environment variables
export NODE_ENV=production
export GO_ENV=production
export DB_HOST=production-db-host
export DB_PASSWORD=secure-production-password
```

## 🔧 Troubleshooting

### **Common Issues**

#### **1. Database Connection Failed**
```bash
# Check PostgreSQL service
sudo systemctl status postgresql

# Verify connection
psql -h localhost -U username -d database_name

# Check firewall
sudo ufw status
```

#### **2. Frontend Build Errors**
```bash
# Clear node modules
rm -rf node_modules package-lock.json
npm install

# Check Node.js version
node --version  # Should be 18+
```

#### **3. API Authentication Errors**
```bash
# Check JWT secret
echo $JWT_SECRET

# Verify token format
# Should be: Bearer <token>
```

#### **4. CORS Issues**
```bash
# Check backend CORS configuration
# Verify frontend URL in allowed origins
```

### **Debug Steps**
1. **Check Logs**: Backend console and frontend browser console
2. **Verify Environment**: Check all environment variables
3. **Test Database**: Direct database connection
4. **Check Network**: API endpoint accessibility
5. **Verify Dependencies**: All packages installed correctly

### **Performance Issues**
```bash
# Database optimization
EXPLAIN ANALYZE SELECT * FROM request WHERE status_request = 'DISETUJUI';

# Frontend bundle analysis
npm run build --analyze

# Backend profiling
go tool pprof work-request-server cpu.prof
```

## 🤝 Contributing

### **Development Workflow**
1. **Fork** the repository
2. **Create** feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** changes (`git commit -m 'Add amazing feature'`)
4. **Push** to branch (`git push origin feature/amazing-feature`)
5. **Open** Pull Request

### **Code Standards**
- **Go**: Follow Go formatting standards (`gofmt`)
- **React**: Use functional components with hooks
- **CSS**: Follow Tailwind CSS conventions
- **Testing**: Maintain >80% test coverage

### **Commit Convention**
```
feat: add new feature
fix: bug fix
docs: documentation update
style: code formatting
refactor: code refactoring
test: add tests
chore: maintenance tasks
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **React Team** for the amazing frontend framework
- **Go Team** for the efficient backend language
- **Tailwind CSS** for the utility-first CSS framework
- **PostgreSQL** for the robust database system

## 📞 Support

### **Getting Help**
- **Issues**: Create GitHub issue for bugs
- **Discussions**: Use GitHub discussions for questions
- **Documentation**: Check this README and docs folder
- **Email**: Contact maintainers for urgent issues

### **Community**
- **GitHub**: [Repository](https://github.com/your-username/work-request)
- **Discussions**: [GitHub Discussions](https://github.com/your-username/work-request/discussions)
- **Wiki**: [Project Wiki](https://github.com/your-username/work-request/wiki)

---

**Made with ❤️ by the Work Request Team**

*Last updated: January 2024*
