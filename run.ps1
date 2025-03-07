# Define the directory for downloading and extracting the zip file
$downloadDirectory = "C:\install"

# Create the download directory if it doesn't exist
Write-Host "create download directory" -ForegroundColor Green
if (-not (Test-Path -Path $downloadDirectory)) {
    New-Item -Path $downloadDirectory -ItemType Directory
}

# Function to download file from URL
function DownloadFile($url, $outputPath) {
    Invoke-WebRequest -Uri $url -OutFile $outputPath
}

# GitHub repository details
$owner = "sabixx"
$repo = "demo_env_setup_files"
$apiUrl = "https://api.github.com/repos/$owner/$repo/contents/"

# Fetch repository contents
$response = Invoke-RestMethod -Uri $apiUrl -Method Get

# Base directory to save files
if (-not (Test-Path -Path $downloadDirectory)) {
    New-Item -ItemType Directory -Path $downloadDirectory
}

# Loop through each item in the repository
Write-Host "Downloading files from github" -ForegroundColor Green
foreach ($item in $response) {
    $filePath = Join-Path -Path $downloadDirectory -ChildPath $item.name
    DownloadFile $item.download_url $filePath
}

# Execute the python.ps1 script -- not requierd ansible works without it
#Write-Host "Python..." -ForegroundColor Green
#$scriptPath = Join-Path -Path $downloadDirectory -ChildPath "python.ps1"
#& $scriptPath

# add runs as admin to context menu
Write-Host "RunAsAdmin Context Menu..." -ForegroundColor Green
$scriptPath = Join-Path -Path $downloadDirectory -ChildPath "run_as_contextmenu.ps1"
& $scriptPath


# enable winrm
Write-Host "Winrm..." -ForegroundColor Green
$scriptPath = Join-Path -Path $downloadDirectory -ChildPath "winrm.ps1"
& $scriptPath

# Execute the chrome.ps1 script
Write-Host "Chrome..." -ForegroundColor Green
$scriptPath = Join-Path -Path $downloadDirectory -ChildPath "chrome.ps1"
& $scriptPath

# Execute the bginfo.ps1 script
Write-Host "BGinfo..." -ForegroundColor Green
$scriptPath = Join-Path -Path $downloadDirectory -ChildPath "bginfo.ps1"
& $scriptPath


Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Exit the script
exit

