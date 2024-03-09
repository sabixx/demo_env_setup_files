# download Python
Write-Host "download phython" -ForegroundColor Green
Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.9.4/python-3.9.4-amd64.exe" -OutFile "$Env:USERPROFILE\Downloads\python-3.9.4-amd64.exe"

# Install python
Write-Host "install phyton" -ForegroundColor Green
Start-Process -FilePath "$Env:USERPROFILE\Downloads\python-3.9.4-amd64.exe" -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait

# Install pywinrm for ansible
Write-Host "instal pywinrm" -ForegroundColor Green
& "C:\Program Files\Python39\Scripts\pip.exe" install pywinrm
