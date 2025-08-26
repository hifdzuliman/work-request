# Test Routing and Prevent 301 Redirects
Write-Host "Testing Routing Configuration..." -ForegroundColor Green
Write-Host ""

# Test 1: Health Check (Public endpoint)
Write-Host "1. Testing Public Endpoint (Health Check)..." -ForegroundColor Yellow
try {
    $healthResponse = Invoke-RestMethod -Uri "http://localhost:8080/health" -Method GET
    Write-Host "✅ Health check successful: $($healthResponse.message)" -ForegroundColor Green
} catch {
    Write-Host "❌ Health check failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Test Users endpoint without auth (should get 401, not 301)
Write-Host ""
Write-Host "2. Testing Users Endpoint without Auth (should get 401, not 301)..." -ForegroundColor Yellow
try {
    $usersResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/users" -Method GET -MaximumRedirection 0
    
    Write-Host "❌ Unexpected success! Should have failed with 401" -ForegroundColor Red
    Write-Host "   Status Code: $($usersResponse.StatusCode)" -ForegroundColor Cyan
} catch {
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode
        Write-Host "✅ Correct response: Status $statusCode" -ForegroundColor Green
        
        if ($statusCode -eq 401) {
            Write-Host "   ✅ Got 401 Unauthorized (expected)" -ForegroundColor Green
        } elseif ($statusCode -eq 301) {
            Write-Host "   ❌ Got 301 Moved Permanently (routing issue!)" -ForegroundColor Red
        } else {
            Write-Host "   ⚠️ Got $statusCode (unexpected)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ Request failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Test 3: Test Users endpoint with OPTIONS (CORS preflight)
Write-Host ""
Write-Host "3. Testing CORS Preflight for Users endpoint..." -ForegroundColor Yellow
try {
    $headers = @{
        "Origin" = "http://localhost:3000"
        "Access-Control-Request-Method" = "GET"
        "Access-Control-Request-Headers" = "Authorization,Content-Type"
    }
    
    $preflightResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/users" -Method OPTIONS -Headers $headers -MaximumRedirection 0
    
    Write-Host "✅ CORS Preflight successful!" -ForegroundColor Green
    Write-Host "   Status Code: $($preflightResponse.StatusCode)" -ForegroundColor Cyan
    Write-Host "   Access-Control-Allow-Origin: $($preflightResponse.Headers['Access-Control-Allow-Origin'])" -ForegroundColor Cyan
} catch {
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode
        Write-Host "❌ CORS Preflight failed with status: $statusCode" -ForegroundColor Red
        
        if ($statusCode -eq 301) {
            Write-Host "   ❌ 301 redirect detected - routing issue!" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ CORS Preflight failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Test 4: Login to get token
Write-Host ""
Write-Host "4. Testing Login for Protected Endpoint..." -ForegroundColor Yellow

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
    Write-Host "Cannot test protected endpoints without authentication" -ForegroundColor Yellow
    Read-Host "Press Enter to continue..."
    exit 1
}

# Test 5: Test Users endpoint with auth (should work, no redirect)
Write-Host ""
Write-Host "5. Testing Users Endpoint with Auth (should work, no redirect)..." -ForegroundColor Yellow

try {
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
        "Origin" = "http://localhost:3000"
    }
    
    $usersResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/users" -Method GET -Headers $headers -MaximumRedirection 0
    
    Write-Host "✅ Users endpoint access successful!" -ForegroundColor Green
    Write-Host "   Status Code: $($usersResponse.StatusCode)" -ForegroundColor Cyan
    Write-Host "   Access-Control-Allow-Origin: $($usersResponse.Headers['Access-Control-Allow-Origin'])" -ForegroundColor Cyan
    
    # Parse response content
    $users = $usersResponse.Content | ConvertFrom-Json
    Write-Host "   Found $($users.Count) users" -ForegroundColor Cyan
    
} catch {
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode
        Write-Host "❌ Users endpoint access failed with status: $statusCode" -ForegroundColor Red
        
        if ($statusCode -eq 301) {
            Write-Host "   ❌ 301 redirect detected - routing issue!" -ForegroundColor Red
        } elseif ($statusCode -eq 401) {
            Write-Host "   ❌ 401 Unauthorized - check token validity" -ForegroundColor Red
        } elseif ($statusCode -eq 403) {
            Write-Host "   ❌ 403 Forbidden - check user permissions" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Users endpoint access failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Test 6: Test route structure
Write-Host ""
Write-Host "6. Testing Route Structure..." -ForegroundColor Yellow

$testRoutes = @(
    "http://localhost:8080/api/users",
    "http://localhost:8080/api/users/",
    "http://localhost:8080/api/work-requests",
    "http://localhost:8080/api/work-requests/"
)

foreach ($route in $testRoutes) {
    try {
        $response = Invoke-WebRequest -Uri $route -Method GET -MaximumRedirection 0 -ErrorAction SilentlyContinue
        Write-Host "   $route -> Status: $($response.StatusCode)" -ForegroundColor Cyan
    } catch {
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode
            if ($statusCode -eq 301) {
                Write-Host "   $route -> ❌ 301 REDIRECT DETECTED!" -ForegroundColor Red
            } else {
                Write-Host "   $route -> Status: $statusCode" -ForegroundColor Cyan
            }
        } else {
            Write-Host "   $route -> Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "Routing Test completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Expected Results:" -ForegroundColor Yellow
Write-Host "✅ No 301 redirects should occur" -ForegroundColor Green
Write-Host "✅ Users endpoint should return 401 without auth" -ForegroundColor Green
Write-Host "✅ Users endpoint should return 200 with valid auth" -ForegroundColor Green
Write-Host "✅ CORS headers should be present" -ForegroundColor Green
Write-Host ""
Write-Host "If you see 301 redirects:" -ForegroundColor Red
Write-Host "1. Check route configuration" -ForegroundColor Yellow
Write-Host "2. Verify middleware order" -ForegroundColor Yellow
Write-Host "3. Check for conflicting routes" -ForegroundColor Yellow

Read-Host "Press Enter to continue..."

