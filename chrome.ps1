 # Function to check if Chrome is installed by querying the registry
function IsChromeInstalled {
    $path64 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $path32 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"

    $chrome = Get-ItemProperty $path64, $path32 -ErrorAction SilentlyContinue | 
              Where-Object { $_.DisplayName -like "*Google Chrome*" }

    return $chrome -ne $null
}

# Check if Chrome is installed
if (-not (IsChromeInstalled)) {
    $chromeInstallerUrl = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"
    $installerPath = "$env:TEMP\chrome_installer.exe"
    
    Write-Host "Downloading and installing Chrome.."

    # Download the installer
    Invoke-WebRequest -Uri $chromeInstallerUrl -OutFile $installerPath

    # Run the installer
    Start-Process -FilePath $installerPath -Args "/silent /install" -Wait

    # Clean up the installer
    Remove-Item -Path $installerPath

    # Check again after installation attempt
    if (IsChromeInstalled) {
        Write-Host "Google Chrome is installed."
    } else {
        Write-Host "Failed to install Google Chrome."
    }
} else {
    Write-Host "Google Chrome is already installed."
}
 
