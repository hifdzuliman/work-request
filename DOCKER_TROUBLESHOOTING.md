# 🔧 Docker Troubleshooting Guide

Comprehensive troubleshooting guide for Docker-related issues in the Work Request Management System.

## 🚨 Common Issues & Solutions

### **1. "failed to solve: failed to compute cache key: failed to calculate checksum of ref: '/go.sum': not found"**

This error occurs when Docker can't find the `go.sum` file during the build process.

#### **Solution 1: Fix Go Modules**
```bash
# Navigate to backend directory
cd backend

# Clean Go module cache
go clean -modcache

# Download dependencies
go mod download

# Verify modules
go mod verify

# Tidy modules
go mod tidy
```

#### **Solution 2: Use Fix Scripts**
```bash
# Linux/Mac
./scripts/fix-go-modules.sh

# Windows
scripts\fix-go-modules.bat
```

#### **Solution 3: Manual File Check**
```bash
# Ensure these files exist in backend/
ls -la backend/go.mod
ls -la backend/go.sum
```

#### **Solution 4: Regenerate go.sum**
```bash
cd backend
rm -f go.sum
go mod tidy
```

### **2. Docker Build Context Issues**

#### **Problem**: Files not found during build
```bash
# Check Docker build context
docker build --no-cache -t test-build ./backend

# Check what's being copied
docker build --progress=plain ./backend
```

#### **Solution**: Verify file structure
```bash
# Ensure proper directory structure
tree -I 'node_modules|.git|*.exe|*.dll'
```

### **3. Permission Issues**

#### **Problem**: Permission denied errors
```bash
# Fix file permissions (Linux/Mac)
sudo chown -R $USER:$USER .
chmod +x scripts/*.sh

# Fix Docker permissions
sudo usermod -aG docker $USER
newgrp docker
```

### **4. Port Already in Use**

#### **Problem**: Port conflicts
```bash
# Check what's using the port
sudo lsof -i :8080
sudo lsof -i :3000
sudo lsof -i :5432

# Kill the process
sudo kill -9 <PID>

# Or use different ports in docker-compose.yml
```

## 🛠️ Diagnostic Commands

### **Check Docker Status**
```bash
# Docker info
docker info

# Docker version
docker --version
docker-compose --version

# Running containers
docker ps -a

# Docker system info
docker system df
```

### **Check Service Health**
```bash
# Service status
docker-compose ps

# Service logs
docker-compose logs -f

# Specific service logs
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f postgres
```

### **Check Network Connectivity**
```bash
# Network inspection
docker network ls
docker network inspect work-request_work-request-network

# Test connectivity between containers
docker-compose exec backend ping postgres
docker-compose exec backend ping frontend
```

### **Check Volumes**
```bash
# Volume list
docker volume ls

# Volume inspection
docker volume inspect work-request_postgres_data
```

## 🔍 Step-by-Step Debugging

### **Step 1: Verify Prerequisites**
```bash
# Check Docker installation
docker --version
docker-compose --version

# Check Go installation
go version

# Check Node.js installation
node --version
npm --version
```

### **Step 2: Check File Structure**
```bash
# Verify required files exist
ls -la docker-compose.yml
ls -la backend/go.mod
ls -la backend/go.sum
ls -la frontend/package.json
```

### **Step 3: Test Individual Services**
```bash
# Test PostgreSQL only
docker-compose up -d postgres
docker-compose logs postgres

# Test Backend only
docker-compose up -d postgres backend
docker-compose logs backend

# Test Frontend only
docker-compose up -d postgres backend frontend
docker-compose logs frontend
```

### **Step 4: Check Build Process**
```bash
# Build backend only
docker-compose build --no-cache backend

# Build frontend only
docker-compose build --no-cache frontend

# Check build context
docker build --progress=plain ./backend
```

## 🚀 Quick Fix Commands

### **Complete Reset**
```bash
# Stop all services
docker-compose down

# Remove all containers and images
docker-compose down --rmi all --volumes --remove-orphans

# Clean Docker system
docker system prune -a --volumes

# Rebuild everything
docker-compose build --no-cache
docker-compose up -d
```

### **Fix Go Modules**
```bash
cd backend
go clean -modcache
go mod download
go mod verify
go mod tidy
cd ..
```

### **Fix Frontend Dependencies**
```bash
cd frontend
rm -rf node_modules package-lock.json
npm install
cd ..
```

## 📋 Environment-Specific Issues

### **Windows Issues**
```cmd
# Use Windows line endings
git config --global core.autocrlf true

# Run as Administrator if needed
# Use Windows Subsystem for Linux (WSL) for better compatibility
```

### **macOS Issues**
```bash
# Check Docker Desktop settings
# Ensure sufficient memory allocation (at least 4GB)
# Check file permissions
chmod +x scripts/*.sh
```

### **Linux Issues**
```bash
# Check Docker service
sudo systemctl status docker

# Check user permissions
sudo usermod -aG docker $USER
newgrp docker

# Check firewall
sudo ufw status
```

## 🔧 Advanced Troubleshooting

### **Debug Docker Build**
```bash
# Verbose build output
docker build --progress=plain --no-cache ./backend

# Check build context
docker build --target builder ./backend

# Interactive debugging
docker run -it --rm golang:1.21-alpine sh
```

### **Debug Container Runtime**
```bash
# Enter running container
docker-compose exec backend sh
docker-compose exec frontend sh
docker-compose exec postgres psql -U work_request_user -d work_request_db

# Check container filesystem
docker-compose exec backend ls -la /app
```

### **Network Debugging**
```bash
# Check container network
docker-compose exec backend ip addr
docker-compose exec backend netstat -tulpn

# Test DNS resolution
docker-compose exec backend nslookup postgres
```

## 📚 Useful Resources

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

### **Go Commands Reference**
```bash
# Module management
go mod download               # Download dependencies
go mod verify                 # Verify dependencies
go mod tidy                   # Clean up modules
go clean -modcache           # Clean module cache
go list -m all               # List all modules
```

## 🆘 Still Having Issues?

If you're still experiencing problems:

1. **Check the logs**: `docker-compose logs -f`
2. **Verify file permissions**: Ensure all files are readable
3. **Check Docker version**: Ensure you have Docker 20.10+ and Docker Compose 2.0+
4. **Check system resources**: Ensure sufficient RAM and disk space
5. **Try the fix scripts**: Use the provided troubleshooting scripts
6. **Check network**: Ensure no firewall or proxy issues

### **Contact Support**
- Create an issue with detailed error logs
- Include your operating system and Docker version
- Provide the complete error message and stack trace
- Include the output of `docker-compose ps` and `docker-compose logs`

---

**Remember**: Most Docker issues can be resolved by following the troubleshooting steps above. Start with the basic checks and work your way up to more advanced debugging techniques.
