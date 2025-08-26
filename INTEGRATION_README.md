# Frontend-Backend Integration Guide

## Overview
This document explains how the frontend React application is integrated with the backend Go server.

## Architecture

### Frontend (React)
- **Location**: `frontend/` directory
- **Port**: 3000 (development)
- **Framework**: React 18 with React Router
- **Styling**: Tailwind CSS

### Backend (Go)
- **Location**: `backend/` directory
- **Port**: 8080
- **Framework**: Gin web framework
- **Database**: PostgreSQL

## Integration Points

### 1. API Service Layer
- **File**: `frontend/src/services/api.js`
- **Purpose**: Centralized API communication with backend
- **Features**:
  - Automatic token management
  - Error handling
  - Request/response formatting

### 2. Authentication Integration
- **File**: `frontend/src/contexts/AuthContext.js`
- **Features**:
  - JWT token storage
  - Automatic token validation
  - User session management

### 3. CORS Configuration
- **File**: `backend/middleware/middleware.go`
- **Features**:
  - Cross-origin request handling
  - Preflight request support
  - Secure headers

### 4. Proxy Configuration
- **File**: `frontend/package.json`
- **Feature**: Development proxy to backend API

## API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration

### Users
- `GET /api/users/me` - Get current user
- `GET /api/users` - Get all users
- `GET /api/users/:id` - Get user by ID

### Work Requests
- `POST /api/work-requests` - Create work request
- `GET /api/work-requests` - Get all work requests
- `GET /api/work-requests/my-requests` - Get user's requests
- `GET /api/work-requests/:id` - Get request by ID
- `PUT /api/work-requests/:id/status` - Update request status
- `DELETE /api/work-requests/:id` - Delete request

## Getting Started

### 1. Start Backend
```bash
cd backend
go run main.go
```

### 2. Start Frontend
```bash
cd frontend
npm start
```

### 3. Or Use Integrated Script
```bash
start-integrated.bat
```

## Testing Integration

### Integration Test Page
- **URL**: `http://localhost:3000/integration-test`
- **Features**:
  - Backend health check
  - API endpoint testing
  - Connection status display

### Manual Testing
1. Open browser to `http://localhost:3000`
2. Navigate to `/integration-test`
3. Click test buttons to verify connectivity

## Environment Configuration

### Frontend
- **API URL**: Set via `REACT_APP_API_URL` environment variable
- **Default**: `http://localhost:8080/api`

### Backend
- **Port**: Set via `SERVER_PORT` environment variable
- **Default**: `8080`

## Development Workflow

### 1. Backend Changes
- Modify Go code in `backend/` directory
- Server auto-reloads on file changes
- Test API endpoints directly

### 2. Frontend Changes
- Modify React components in `frontend/src/`
- Hot reload enabled for development
- API calls automatically use proxy

### 3. Integration Testing
- Use integration test page
- Check browser console for errors
- Verify API responses

## Troubleshooting

### Common Issues

#### 1. CORS Errors
- Ensure backend CORS middleware is enabled
- Check frontend proxy configuration
- Verify backend is running on correct port

#### 2. API Connection Failed
- Check backend server status
- Verify API endpoint URLs
- Check network connectivity

#### 3. Authentication Issues
- Verify JWT token format
- Check token expiration
- Ensure proper authorization headers

### Debug Steps
1. Check backend logs for errors
2. Verify frontend console for API errors
3. Test API endpoints directly (e.g., Postman)
4. Check network tab in browser dev tools

## Production Deployment

### Frontend Build
```bash
cd frontend
npm run build
```

### Backend Build
```bash
cd backend
go build -o web-work-request-backend main.go
```

### Environment Variables
- Set `REACT_APP_API_URL` to production backend URL
- Configure backend environment variables
- Update CORS origins for production domains

## Security Considerations

### Frontend
- API keys stored in environment variables
- No sensitive data in client-side code
- HTTPS in production

### Backend
- JWT token validation
- Role-based access control
- Input validation and sanitization
- CORS origin restrictions

## Performance Optimization

### Frontend
- API response caching
- Lazy loading of components
- Optimized bundle size

### Backend
- Database query optimization
- Response compression
- Connection pooling
- Rate limiting

## Monitoring and Logging

### Frontend
- Console logging for debugging
- Error boundary components
- Performance monitoring

### Backend
- Structured logging
- Health check endpoints
- Metrics collection
- Error tracking

