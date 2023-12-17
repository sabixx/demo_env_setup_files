 # Define Chrome's usual installation paths
$paths = @(
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe", 
    "$env:ProgramFiles(x86)\Google\Chrome\Application\chrome.exe"
)

# Check if Chrome is installed
$chromeInstalled = $false
foreach ($path in $paths) {
    if (Test-Path $path) {
        $chromeInstalled = $true
        break
    }
}

# Download and Install Chrome if not installed
if (-not $chromeInstalled) {
    $chromeInstallerUrl = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"
    $installerPath = "$env:TEMP\chrome_installer.exe"
    
    # Download the installer
    Invoke-WebRequest -Uri $chromeInstallerUrl -OutFile $installerPath

    # Run the installer
    Start-Process -FilePath $installerPath -Args "/silent /install" -Wait

    # Clean up the installer
    Remove-Item -Path $installerPath
}

# Confirm installation
$chromeInstalled = $false
foreach ($path in $paths) {
    if (Test-Path $path) {
        $chromeInstalled = $true
        break
    }
}

if ($chromeInstalled) {
    Write-Host "Google Chrome is installed."
} else {
    Write-Host "Failed to install Google Chrome."
}
 
