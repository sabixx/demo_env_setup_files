# Define the directory for downloading and extracting the zip file
# when changing this BGInfoLogonTask.xml must be changed as well
$downloadDirectory = "C:\install"

# Create the download directory if it doesn't exist
if (-not (Test-Path -Path $downloadDirectory)) {
    New-Item -Path $downloadDirectory -ItemType Directory
}

# Download Mulish
Write-Host "Download Mulish" -ForegroundColor Green
$fontZipUrl = "https://fonts.google.com/download?family=Mulish"
$zipFilePath = Join-Path -Path $downloadDirectory -ChildPath "Mulish.zip"
Invoke-WebRequest -Uri $fontZipUrl -OutFile $zipFilePath

# Extract the zip file
Write-Host "Extract Mulish" -ForegroundColor Green
Expand-Archive -Path "$zipFilePath" -DestinationPath $downloadDirectory -Force

# Define the directory where the Mulish font files are extracted
#$fontDirectory = Join-Path -Path $downloadDirectory -ChildPath "\static"

# Define the specific font files to install
$fontFiles = @("Mulish-Black.ttf", "Mulish-Bold.ttf", "Mulish-Italic.ttf")

function Add-Font {
    Param([string]$fontfile)
    Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;

    public class Fonts {
        [DllImport("gdi32.dll")]
        public static extern int AddFontResource(string lpszFilename);
    }
"@
    [Fonts]::AddFontResource($fontfile)
}

cd c:/install/static
Add-Font "Mulish-Regular.ttf"
Add-Font "Mulish-Black.ttf"
Add-Font "Mulish-Bold.ttf"
Add-Font "Mulish-Italic.ttf"

#Do not execute BGInfo when it already exists.
$runBGInfoFirstTime = $True

# Check if the file exists
if (Test-Path -Path "$downloadDirectory\custom.bgi") {
    $runBGInfoFirstTime = $False
} 


# Download URL for BGInfo
$bgInfoUrl = "https://download.sysinternals.com/files/BGInfo.zip"
$bgInfoOutput = "$downloadDirectory\BGInfo.zip"

# Download and extract BGInfo
Write-Host "Download GBInfo" -ForegroundColor Green
Invoke-WebRequest -Uri $bgInfoUrl -OutFile $bgInfoOutput
Expand-Archive -LiteralPath $bgInfoOutput -DestinationPath $downloadDirectory -Force


# Find the BGInfo executable path
$bgInfoPath = Get-ChildItem -Path $downloadDirectory -Recurse -Filter BGInfo.exe | Select-Object -ExpandProperty FullName

# Assume custom.bgi is already created and placed in the same folder as BGInfo.exe
$customConfigPath = "$downloadDirectory\custom.bgi"

# Accept BGInfo EULA
$keyPath = "HKCU:\Software\Sysinternals\BGInfo"
If (-not (Test-Path $keyPath)) {
    New-Item -Path $keyPath -Force
}
Set-ItemProperty -Path "HKCU:\Software\Sysinternals\BGInfo" -Name "EulaAccepted" -Value 1 -Type DWord

# Run BGInfo once immediately with custom config
& $bgInfoPath $customConfigPath /timer:0

# Create a Scheduled Task to run BGInfo at logon with custom config
Register-ScheduledTask -Xml (Get-Content "C:\install\BGInfoLogonTask.xml" | Out-String) -TaskName "BGInfoLogon" -Force
Start-ScheduledTask -TaskName "BGInfoLogon" 


if ($runBGInfoFirstTime)) {
    Write-Host "Running BGInfo" -ForegroundColor Green
    & $downloadDirectory\custom.bgi
}

