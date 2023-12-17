# Define the directory for downloading and extracting the zip file
$downloadDirectory = "C:\install"

# Create the download directory if it doesn't exist
if (-not (Test-Path -Path $downloadDirectory)) {
    New-Item -Path $downloadDirectory -ItemType Directory
}

# Download Mulish
$fontZipUrl = "https://fonts.google.com/download?family=Mulish"
$zipFilePath = Join-Path -Path $downloadDirectory -ChildPath "Mulish.zip"
Invoke-WebRequest -Uri $fontZipUrl -OutFile $zipFilePath

# Extract the zip file
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

# Download URL for BGInfo
$bgInfoUrl = "https://download.sysinternals.com/files/BGInfo.zip"
$bgInfoOutput = "$downloadDirectory\BGInfo.zip"

# Download and extract BGInfo
Invoke-WebRequest -Uri $bgInfoUrl -OutFile $bgInfoOutput
Expand-Archive -LiteralPath $bgInfoOutput -DestinationPath $downloadDirectory -Force

# Find the BGInfo executable path
$bgInfoPath = Get-ChildItem -Path $downloadDirectory -Recurse -Filter BGInfo.exe | Select-Object -ExpandProperty FullName

# Assume custom.bgi is already created and placed in the same folder as BGInfo.exe
$customConfigPath = "$downloadDirectory\custom.bgi"

# Run BGInfo once immediately with custom config
#& $bgInfoPath $customConfigPath /timer:0

# Create a Scheduled Task to run BGInfo at logon with custom config
Register-ScheduledTask -Xml (Get-Content "C:\install\BGInfoLogonTask.xml" | Out-String) -TaskName "BGInfoLogon" -Force

Start-ScheduledTask -TaskName "BGInfoLogon" 
 
& $downloadDirectory\custom.bgi
