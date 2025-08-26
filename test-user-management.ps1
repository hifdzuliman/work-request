# Test User Management CRUD Operations
Write-Host "Testing User Management CRUD Operations..." -ForegroundColor Green
Write-Host ""

# Test 1: Health Check
Write-Host "1. Testing Backend Health..." -ForegroundColor Yellow
try {
    $healthResponse = Invoke-RestMethod -Uri "http://localhost:8080/health" -Method GET
    Write-Host "✅ Backend is running: $($healthResponse.message)" -ForegroundColor Green
} catch {
    Write-Host "❌ Backend health check failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please make sure backend is running on port 8080" -ForegroundColor Yellow
    Read-Host "Press Enter to continue..."
    exit 1
}

# Test 2: Login to get token
Write-Host ""
Write-Host "2. Getting authentication token..." -ForegroundColor Yellow

$loginData = @{
    username = "hifdzul"
    password = "admin123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    $token = $loginResponse.token
    Write-Host "✅ Login successful! Token obtained" -ForegroundColor Green
} catch {
    Write-Host "❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    Read-Host "Press Enter to continue..."
    exit 1
}

# Test 3: Get all users
Write-Host ""
Write-Host "3. Testing Get All Users..." -ForegroundColor Yellow

try {
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    $usersResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/users" -Method GET -Headers $headers
    Write-Host "✅ Get all users successful!" -ForegroundColor Green
    Write-Host "   Found $($usersResponse.Count) users" -ForegroundColor Cyan
    
    if ($usersResponse.Count -gt 0) {
        Write-Host "   First user: $($usersResponse[0].name) ($($usersResponse[0].username))" -ForegroundColor Cyan
    }
} catch {
    Write-Host "❌ Get all users failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Create new user
Write-Host ""
Write-Host "4. Testing Create User..." -ForegroundColor Yellow

$newUserData = @{
    username = "testuser"
    password = "testpass123"
    name = "Test User"
    email = "testuser@example.com"
    unit = "Test Department"
    role = "user"
} | ConvertTo-Json

try {
    $createResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/users" -Method POST -Body $newUserData -Headers $headers
    Write-Host "✅ Create user successful!" -ForegroundColor Green
    Write-Host "   User ID: $($createResponse.user.id)" -ForegroundColor Cyan
    Write-Host "   Username: $($createResponse.user.username)" -ForegroundColor Cyan
    $newUserId = $createResponse.user.id
} catch {
    Write-Host "❌ Create user failed: $($_.Exception.Message)" -ForegroundColor Red
    $newUserId = $null
}

# Test 5: Get user by ID (if created successfully)
if ($newUserId) {
    Write-Host ""
    Write-Host "5. Testing Get User by ID..." -ForegroundColor Yellow
    
    try {
        $userResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/users/$newUserId" -Method GET -Headers $headers
        Write-Host "✅ Get user by ID successful!" -ForegroundColor Green
        Write-Host "   User: $($userResponse.name) ($($userResponse.username))" -ForegroundColor Cyan
    } catch {
        Write-Host "❌ Get user by ID failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Test 6: Update user (if created successfully)
if ($newUserId) {
    Write-Host ""
    Write-Host "6. Testing Update User..." -ForegroundColor Yellow
    
    $updateUserData = @{
        name = "Updated Test User"
        email = "updated@example.com"
        unit = "Updated Department"
        role = "operator"
    } | ConvertTo-Json
    
    try {
        $updateResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/users/$newUserId" -Method PUT -Body $updateUserData -Headers $headers
        Write-Host "✅ Update user successful!" -ForegroundColor Green
        Write-Host "   Message: $($updateResponse.message)" -ForegroundColor Cyan
    } catch {
        Write-Host "❌ Update user failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Test 7: Delete user (if created successfully)
if ($newUserId) {
    Write-Host ""
    Write-Host "7. Testing Delete User..." -ForegroundColor Yellow
    
    try {
        $deleteResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/users/$newUserId" -Method DELETE -Headers $headers
        Write-Host "✅ Delete user successful!" -ForegroundColor Green
        Write-Host "   Message: $($deleteResponse.message)" -ForegroundColor Cyan
    } catch {
        Write-Host "❌ Delete user failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Test 8: Verify user is deleted
if ($newUserId) {
    Write-Host ""
    Write-Host "8. Verifying user deletion..." -ForegroundColor Yellow
    
    try {
        $userResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/users/$newUserId" -Method GET -Headers $headers
        Write-Host "❌ User still exists after deletion!" -ForegroundColor Red
    } catch {
        if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Host "✅ User successfully deleted (404 Not Found)" -ForegroundColor Green
        } else {
            Write-Host "❌ Unexpected error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "User Management CRUD Test completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Test the frontend user management page" -ForegroundColor Cyan
Write-Host "2. Navigate to: http://localhost:3000/pengguna" -ForegroundColor Cyan
Write-Host "3. Try creating, editing, and deleting users" -ForegroundColor Cyan
Write-Host "4. Check browser console for any errors" -ForegroundColor Cyan

Read-Host "Press Enter to continue..."

