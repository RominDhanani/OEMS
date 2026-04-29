# Fix-OfficeExpenseConnectivity.ps1
# This script opens Port 5000 in the Windows Firewall to allow mobile devices to connect.

Write-Host "Checking for existing Firewall rules for Port 5000..." -ForegroundColor Cyan

$rule = Get-NetFirewallRule -DisplayName "Office Expense Backend (Port 5000)" -ErrorAction SilentlyContinue

if ($rule) {
    Write-Host "Rule already exists. Updating..." -ForegroundColor Yellow
    Set-NetFirewallRule -DisplayName "Office Expense Backend (Port 5000)" -LocalPort 5000 -Protocol TCP -Action Allow -Enabled True
} else {
    Write-Host "Creating new Firewall rule for Port 5000..." -ForegroundColor Green
    New-NetFirewallRule -DisplayName "Office Expense Backend (Port 5000)" -Direction Inbound -LocalPort 5000 -Protocol TCP -Action Allow -Enabled True
}

Write-Host "Firewall port 5000 is now open for local network access." -ForegroundColor Green
Write-Host "Please ensure your phone is on the SAME Wi-Fi as this PC." -ForegroundColor White
Write-Host "PC IP Address: 192.168.0.193" -ForegroundColor Yellow
