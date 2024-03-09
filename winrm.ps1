
#Show current state of winrm
Write-Host "Winrm config:" -ForegroundColor Green
winrm get winrm/config

#Enable winrm
Write-Host "winrm quickconfig" -ForegroundColor Green
winrm quickconfig
