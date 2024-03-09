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

# Execute the python.ps1 script
Write-Host "Install Python" -ForegroundColor Green
$scriptPath = Join-Path -Path $downloadDirectory -ChildPath "python.ps1"
& $scriptPath

# enable winrm
Write-Host "Enable Winrm" -ForegroundColor Green
$scriptPath = Join-Path -Path $downloadDirectory -ChildPath "winrm.ps1"
& $scriptPath

# Execute the chrome.ps1 script
Write-Host "Install chrome" -ForegroundColor Green
$scriptPath = Join-Path -Path $downloadDirectory -ChildPath "chrome.ps1"
& $scriptPath

# Execute the bginfo.ps1 script
Write-Host "Installing BGinfo" -ForegroundColor Green
$scriptPath = Join-Path -Path $downloadDirectory -ChildPath "bginfo.ps1"
& $scriptPath

 
