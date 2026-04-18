# start_server.ps1
# This script starts a local web server so you can view the site on your phone.

# 1. Get Local IP Address
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -match "Wi-Fi|Ethernet" -and $_.IPAddress -like "192.168.*" } | Select-Object -First 1).IPAddress

if (-not $ip) {
    # Fallback to simple lookup if the above fails
    $ip = (Get-NetIPAddress -AddressFamily IPv4 -PrefixOrigin Dhcp).IPAddress | Select-Object -First 1
}

$port = 8000
$url = "http://$($ip):$($port)"

Clear-Host
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "   MOBILE ACCESS ENABLED" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Connect your phone to the same Wi-Fi as this PC."
Write-Host "2. Open Chrome/Safari on your phone."
Write-Host "3. Type this EXACT address:"
Write-Host ""
Write-Host "   $url" -ForegroundColor Green -BackgroundColor Black
Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop the server." -ForegroundColor Yellow
Write-Host ""

# 2. Start Python Server
python -m http.server $port
