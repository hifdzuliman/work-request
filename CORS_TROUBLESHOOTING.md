# CORS Troubleshooting Guide

## 🚨 **Masalah CORS di Halaman Pengguna**

### **Gejala:**
- Frontend tidak bisa load data pengguna
- Error CORS di browser console
- Network request blocked oleh browser
- "Access to fetch at 'http://localhost:8080/api/users' from origin 'http://localhost:3000' has been blocked by CORS policy"

## 🔍 **Root Cause Analysis**

### **1. CORS Policy Blocking**
Browser memblokir request karena:
- Origin tidak diizinkan
- Method tidak diizinkan
- Headers tidak diizinkan
- Preflight request gagal

### **2. Backend CORS Configuration**
- Middleware CORS tidak diterapkan dengan benar
- Header CORS tidak lengkap
- Preflight request tidak ditangani

### **3. Route Structure Issues**
- Protected routes grouping yang salah
- Middleware order yang tidak tepat

## 🛠️ **Solusi yang Telah Diterapkan**

### **1. Fixed Route Structure**
```go
// Before (problematic)
protected := api.Group("/")  // This caused issues

// After (fixed)
protected := api.Group("")   // Clean group without slash
```

### **2. Enhanced CORS Middleware**
```go
func CORSMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        c.Header("Access-Control-Allow-Origin", "*")
        c.Header("Access-Control-Allow-Credentials", "true")
        c.Header("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, Accept, Origin, Cache-Control, X-Requested-With, User-Agent")
        c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS, PATCH")
        c.Header("Access-Control-Max-Age", "86400") // 24 hours

        if c.Request.Method == "OPTIONS" {
            c.AbortWithStatus(http.StatusNoContent)
            return
        }

        c.Next()
    }
}
```

### **3. Proper Middleware Order**
```go
func SetupRoutes(handler *handlers.Handler) *gin.Engine {
    r := gin.Default()
    
    // CORS middleware applied FIRST
    r.Use(middleware.CORSMiddleware())
    
    // Then other routes
    // ...
}
```

## 🧪 **Testing CORS Fix**

### **1. Run CORS Test Script**
```bash
.\test-cors.ps1
```

### **2. Manual Testing**
```bash
# Test preflight request
curl -X OPTIONS http://localhost:8080/api/users \
  -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Authorization,Content-Type" \
  -v

# Test actual request
curl -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Origin: http://localhost:3000" \
  http://localhost:8080/api/users
```

### **3. Browser Console Check**
1. Open `http://localhost:3000/pengguna`
2. Open Developer Tools (F12)
3. Check Console tab for CORS errors
4. Check Network tab for failed requests

## 🔧 **Verification Steps**

### **Step 1: Backend Health Check**
```bash
curl http://localhost:8080/health
```
Expected: `{"status":"ok","message":"Web Work Request API is running"}`

### **Step 2: CORS Headers Check**
```bash
curl -I -H "Origin: http://localhost:3000" http://localhost:8080/api/users
```
Expected headers:
- `Access-Control-Allow-Origin: *`
- `Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS, PATCH`
- `Access-Control-Allow-Headers: Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, Accept, Origin, Cache-Control, X-Requested-With, User-Agent`

### **Step 3: Preflight Request Test**
```bash
curl -X OPTIONS -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Authorization" \
  http://localhost:8080/api/users
```
Expected: Status 204 (No Content)

### **Step 4: Authenticated Request Test**
```bash
# First login to get token
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"hifdzul","password":"admin123"}'

# Then test users endpoint
curl -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Origin: http://localhost:3000" \
  http://localhost:8080/api/users
```

## 🚀 **Frontend Testing**

### **1. Clear Browser Cache**
- Hard refresh (Ctrl+F5)
- Clear localStorage and sessionStorage
- Clear browser cache

### **2. Check Authentication**
- Ensure user is logged in
- Check if token exists in localStorage
- Verify token is not expired

### **3. Test User Management**
- Navigate to `/pengguna`
- Check if users load without CORS errors
- Try create/edit/delete operations

## 🐛 **Common CORS Issues & Solutions**

### **Issue 1: "No 'Access-Control-Allow-Origin' header"**
**Solution:**
- Ensure CORS middleware is applied
- Check middleware order in routes
- Verify CORS headers are set

### **Issue 2: "Method not allowed"**
**Solution:**
- Add missing HTTP methods to CORS middleware
- Check if OPTIONS method is handled
- Verify route method definitions

### **Issue 3: "Headers not allowed"**
**Solution:**
- Add missing headers to `Access-Control-Allow-Headers`
- Include `Authorization` header
- Add `Content-Type` header

### **Issue 4: "Preflight request failed"**
**Solution:**
- Handle OPTIONS method properly
- Return 204 status for preflight
- Set proper CORS headers before aborting

## 📋 **CORS Configuration Checklist**

- [ ] CORS middleware applied to all routes
- [ ] CORS middleware applied BEFORE other middleware
- [ ] All required headers included
- [ ] All HTTP methods allowed
- [ ] OPTIONS method handled properly
- [ ] Preflight requests return 204
- [ ] Origin header allowed
- [ ] Credentials allowed if needed

## 🔒 **Security Considerations**

### **Development vs Production**
```go
// Development (current)
c.Header("Access-Control-Allow-Origin", "*")

// Production (recommended)
allowedOrigins := []string{"https://yourdomain.com", "https://app.yourdomain.com"}
origin := c.Request.Header.Get("Origin")
if contains(allowedOrigins, origin) {
    c.Header("Access-Control-Allow-Origin", origin)
}
```

### **Credentials Handling**
```go
// If using cookies/sessions
c.Header("Access-Control-Allow-Credentials", "true")

// If not using credentials
c.Header("Access-Control-Allow-Credentials", "false")
```

## 📞 **Support & Debugging**

### **If CORS Still Fails:**

1. **Check Backend Logs**
   ```bash
   cd backend
   go run main.go
   ```

2. **Verify CORS Headers**
   ```bash
   .\test-cors.ps1
   ```

3. **Check Browser Network Tab**
   - Look for failed requests
   - Check response headers
   - Verify request headers

4. **Test with Different Tools**
   - Postman
   - Insomnia
   - curl command line

### **Debug Commands**
```bash
# Test CORS
.\test-cors.ps1

# Test user management
.\test-user-management.ps1

# Check backend health
curl http://localhost:8080/health
```

## ✅ **Expected Result After Fix**

- ✅ No CORS errors in browser console
- ✅ Users data loads successfully
- ✅ Create/edit/delete operations work
- ✅ All API endpoints accessible
- ✅ Preflight requests handled properly

CORS issue seharusnya sudah teratasi dengan perbaikan yang telah diterapkan!

