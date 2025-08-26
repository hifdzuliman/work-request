# 🐳 Docker Setup Guide

Complete Docker configuration for the Work Request Management System including backend, frontend, PostgreSQL, and optional services.

## 📋 Table of Contents

- [Overview](#-overview)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Services](#-services)
- [Configuration](#-configuration)
- [Development](#-development)
- [Production](#-production)
- [Troubleshooting](#-troubleshooting)

## 🎯 Overview

This Docker setup provides a complete containerized environment for the Work Request Management System:

- **PostgreSQL 15**: Database with automatic initialization
- **Go Backend**: RESTful API server
- **React Frontend**: User interface served by Nginx
- **Redis**: Optional session management
- **Nginx**: Reverse proxy and load balancer

## ✅ Prerequisites

- **Docker** 20.10+
- **Docker Compose** 2.0+
- **Git** (for cloning repository)

### Install Docker

#### **Ubuntu/Debian**
```bash
# Update package index
sudo apt-get update

# Install prerequisites
sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

# Add user to docker group
sudo usermod -aG docker $USER

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker
```

#### **macOS**
```bash
# Install Docker Desktop
brew install --cask docker

# Or download from https://www.docker.com/products/docker-desktop
```

#### **Windows**
Download Docker Desktop from https://www.docker.com/products/docker-desktop

## 🚀 Quick Start

### **1. Clone Repository**
```bash
git clone <repository-url>
cd work-request
```

### **2. Start All Services**
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Check service status
docker-compose ps
```

### **3. Access Application**
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8080
- **PostgreSQL**: localhost:5432
- **Default Admin**: admin/admin123

### **4. Stop Services**
```bash
# Stop all services
docker-compose down

# Stop and remove volumes (WARNING: This will delete all data)
docker-compose down -v
```

## 🏗️ Services

### **PostgreSQL Database**
```yaml
postgres:
  image: postgres:15-alpine
  environment:
    POSTGRES_DB: work_request_db
    POSTGRES_USER: work_request_user
    POSTGRES_PASSWORD: work_request_password
  ports:
    - "5432:5432"
  volumes:
    - postgres_data:/var/lib/postgresql/data
    - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init-db.sql
```

**Features:**
- Automatic database initialization
- Sample data insertion
- User permissions setup
- Performance indexes
- Triggers for `updated_at` fields

### **Go Backend**
```yaml
backend:
  build: ./backend
  environment:
    - DB_HOST=postgres
    - DB_USER=work_request_user
    - DB_PASSWORD=work_request_password
  ports:
    - "8080:8080"
  depends_on:
    postgres:
      condition: service_healthy
```

**Features:**
- Multi-stage build optimization
- Non-root user execution
- Health checks
- Environment-based configuration

### **React Frontend**
```yaml
frontend:
  build: ./frontend
  environment:
    - REACT_APP_API_BASE_URL=http://localhost:8080/api
  ports:
    - "3000:80"
  depends_on:
    backend:
      condition: service_healthy
```

**Features:**
- Nginx web server
- Client-side routing support
- Gzip compression
- Security headers
- Static asset caching

### **Redis (Optional)**
```yaml
redis:
  image: redis:7-alpine
  command: redis-server --appendonly yes
  ports:
    - "6379:6379"
  volumes:
    - redis_data:/data
```

**Features:**
- Persistent data storage
- Health checks
- Optional for session management

### **Nginx Reverse Proxy (Optional)**
```yaml
nginx:
  image: nginx:alpine
  ports:
    - "80:80"
    - "443:443"
  volumes:
    - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
```

**Features:**
- Load balancing
- Rate limiting
- SSL termination (configurable)
- Health checks

## ⚙️ Configuration

### **Environment Variables**

#### **Backend Environment**
```env
# Server Configuration
SERVER_PORT=8080
SERVER_HOST=0.0.0.0

# Database Configuration
DB_HOST=postgres
DB_PORT=5432
DB_USER=work_request_user
DB_PASSWORD=work_request_password
DB_NAME=work_request_db
DB_SSL_MODE=disable

# JWT Configuration
JWT_SECRET=your_super_secret_jwt_key_change_in_production
JWT_EXPIRY=24h

# CORS Configuration
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:80,http://frontend:80
```

#### **Frontend Environment**
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
-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Set timezone
SET timezone = 'Asia/Jakarta';

-- Create tables and indexes automatically
-- (handled by init-db.sql)
```

## 🧪 Development

### **Development Commands**

#### **Start Development Environment**
```bash
# Start only essential services
docker-compose up -d postgres backend

# Start frontend in development mode
cd frontend
npm install
npm start
```

#### **Rebuild Services**
```bash
# Rebuild specific service
docker-compose build backend

# Rebuild and restart
docker-compose up -d --build backend

# Rebuild all services
docker-compose build --no-cache
```

#### **View Logs**
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend

# Last 100 lines
docker-compose logs --tail=100 backend
```

#### **Database Operations**
```bash
# Connect to database
docker-compose exec postgres psql -U work_request_user -d work_request_db

# Run SQL script
docker-compose exec -T postgres psql -U work_request_user -d work_request_db < scripts/your-script.sql

# Backup database
docker-compose exec postgres pg_dump -U work_request_user work_request_db > backup.sql

# Restore database
docker-compose exec -T postgres psql -U work_request_user -d work_request_db < backup.sql
```

### **Development Workflow**
```bash
# 1. Start database
docker-compose up -d postgres

# 2. Start backend (with hot reload)
cd backend
go run main.go

# 3. Start frontend (with hot reload)
cd frontend
npm start

# 4. Access application
# Frontend: http://localhost:3000
# Backend: http://localhost:8080
```

## 🚀 Production

### **Production Build**
```bash
# Build production images
docker-compose -f docker-compose.yml -f docker-compose.prod.yml build

# Start production services
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### **Production Configuration**

#### **Environment Variables**
```env
# Production settings
NODE_ENV=production
GO_ENV=production
DB_HOST=production-db-host
DB_PASSWORD=secure-production-password
JWT_SECRET=very-long-secure-jwt-secret-key
```

#### **SSL Configuration**
```bash
# Generate SSL certificates
mkdir -p nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/key.pem \
  -out nginx/ssl/cert.pem

# Uncomment HTTPS section in nginx/nginx.conf
```

#### **Security Considerations**
- Change default passwords
- Use strong JWT secrets
- Enable SSL/TLS
- Configure firewall rules
- Regular security updates

### **Scaling**
```bash
# Scale backend services
docker-compose up -d --scale backend=3

# Scale with load balancer
docker-compose up -d --scale backend=3 --scale frontend=2
```

## 🔧 Troubleshooting

### **Common Issues**

#### **1. Port Already in Use**
```bash
# Check what's using the port
sudo lsof -i :8080

# Kill the process
sudo kill -9 <PID>

# Or use different ports
docker-compose up -d -p 8081:8080 backend
```

#### **2. Database Connection Failed**
```bash
# Check PostgreSQL logs
docker-compose logs postgres

# Check service health
docker-compose ps

# Restart PostgreSQL
docker-compose restart postgres
```

#### **3. Frontend Build Failed**
```bash
# Clear Docker cache
docker system prune -a

# Rebuild frontend
docker-compose build --no-cache frontend

# Check build logs
docker-compose build frontend
```

#### **4. Permission Issues**
```bash
# Fix file permissions
sudo chown -R $USER:$USER .

# Fix Docker permissions
sudo usermod -aG docker $USER
newgrp docker
```

### **Debug Commands**
```bash
# Check service status
docker-compose ps

# Check service health
docker-compose exec backend wget -qO- http://localhost:8080/health

# View service resources
docker stats

# Check network connectivity
docker-compose exec backend ping postgres

# View service logs
docker-compose logs --tail=100 -f
```

### **Performance Issues**
```bash
# Check resource usage
docker stats

# Optimize images
docker system prune -a

# Monitor database performance
docker-compose exec postgres psql -U work_request_user -d work_request_db -c "SELECT * FROM pg_stat_activity;"
```

## 📚 Additional Resources

### **Docker Commands Reference**
```bash
# Container management
docker-compose up -d          # Start services
docker-compose down           # Stop services
docker-compose restart        # Restart services
docker-compose logs -f        # View logs
docker-compose exec           # Execute command in container

# Image management
docker-compose build          # Build images
docker-compose pull           # Pull latest images
docker system prune           # Clean up unused resources
```

### **Useful Scripts**
```bash
# Start development environment
./scripts/dev-start.sh

# Start production environment
./scripts/prod-start.sh

# Database backup
./scripts/backup-db.sh

# Database restore
./scripts/restore-db.sh
```

### **Monitoring and Logging**
```bash
# View real-time logs
docker-compose logs -f --tail=100

# Monitor resource usage
docker stats

# Check service health
docker-compose ps
```

## 🎉 Conclusion

This Docker setup provides a complete, production-ready environment for the Work Request Management System. The configuration includes:

- ✅ **Automatic database initialization** with sample data
- ✅ **Health checks** for all services
- ✅ **Production-ready** configurations
- ✅ **Security best practices** implementation
- ✅ **Easy scaling** and management
- ✅ **Comprehensive logging** and monitoring

For production deployment, remember to:
1. Change default passwords
2. Configure SSL certificates
3. Set up proper backup strategies
4. Monitor system resources
5. Keep images updated

Happy containerizing! 🐳
