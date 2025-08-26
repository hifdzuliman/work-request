# Password Hash Generator for Web Work Request Backend
# PowerShell Script

param(
    [string]$Password = "",
    [switch]$Generate,
    [int]$Length = 12,
    [string]$Verify = "",
    [string]$Hash = ""
)

Write-Host "Password Hash Generator for Web Work Request Backend" -ForegroundColor Green
Write-Host ""

if ($Generate) {
    # Generate a random password and its hash
    Write-Host "Generating random password with length: $Length" -ForegroundColor Yellow
    cd $PSScriptRoot\..
    go run cmd/password/main.go -generate -length=$Length
    return
}

if ($Verify -and $Hash) {
    # Verify password against hash
    Write-Host "Verifying password against hash..." -ForegroundColor Yellow
    cd $PSScriptRoot\..
    go run cmd/password/main.go -verify="$Verify" -hash="$Hash"
    return
}

if ($Password) {
    # Hash the provided password
    Write-Host "Generating hash for password: $Password" -ForegroundColor Yellow
    cd $PSScriptRoot\..
    go run cmd/password/main.go -password="$Password"
    return
}

# Show usage if no valid parameters provided
Write-Host "Usage:" -ForegroundColor Cyan
Write-Host "  Generate hash for a password:" -ForegroundColor White
Write-Host "    .\generate-password.ps1 -Password 'yourpassword'" -ForegroundColor Gray
Write-Host ""
Write-Host "  Generate a random password with hash:" -ForegroundColor White
Write-Host "    .\generate-password.ps1 -Generate -Length 16" -ForegroundColor Gray
Write-Host ""
Write-Host "  Verify a password against a hash:" -ForegroundColor White
Write-Host "    .\generate-password.ps1 -Verify 'password' -Hash 'hashstring'" -ForegroundColor Gray
Write-Host ""
Write-Host "Examples:" -ForegroundColor Cyan
Write-Host "  .\generate-password.ps1 -Password 'admin123'" -ForegroundColor Gray
Write-Host "  .\generate-password.ps1 -Generate -Length 20" -ForegroundColor Gray
Write-Host "  .\generate-password.ps1 -Verify 'admin123' -Hash '\$2a\$10\$...'" -ForegroundColor Gray
Write-Host ""
Write-Host "Note: Use single quotes around passwords with spaces" -ForegroundColor Yellow
