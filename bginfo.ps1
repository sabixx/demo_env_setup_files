 # Define the directory for downloading and extracting the zip file
$downloadDirectory = "C:\install"

# Create the download directory if it doesn't exist
if (-not (Test-Path -Path $downloadDirectory)) {
    New-Item -Path $downloadDirectory -ItemType Directory
}

# Define the specific font files to install
$fontFiles = @("Mulish-Black.ttf", "Mulish-Bold.ttf", "Mulish-Italic.ttf", "Mulish-Light.ttf")

# Download Mulish
$fontZipUrl = "https://fonts.google.com/download?family=Mulish"
$zipFilePath = Join-Path -Path $downloadDirectory -ChildPath "Mulish.zip"
Invoke-WebRequest -Uri $fontZipUrl -OutFile $zipFilePath

# Extract the zip file
Expand-Archive -Path "$zipFilePath" -DestinationPath $downloadDirectory -Force

# Define the directory where the Mulish font files are extracted
$fontDirectory = Join-Path -Path $downloadDirectory -ChildPath "\static"

function Install-Font {  
param  
(  
    [System.IO.FileInfo]$fontFile  
)  
      
    try { 

        #get font name
        $gt = [Windows.Media.GlyphTypeface]::new($fontFile.FullName)
        $family = $gt.Win32FamilyNames['en-us']
        if ($null -eq $family) { $family = $gt.Win32FamilyNames.Values.Item(0) }
        $face = $gt.Win32FaceNames['en-us']
        if ($null -eq $face) { $face = $gt.Win32FaceNames.Values.Item(0) }
        $fontName = ("$family $face").Trim() 
           
        switch ($fontFile.Extension) {  
			".ttf" {$fontName = "$fontName (TrueType)"}  
            ".otf" {$fontName = "$fontName (OpenType)"}  
        }  

        write-host "Installing font: $fontFile with font name '$fontName'"

        If (!(Test-Path ("$($env:windir)\Fonts\" + $fontFile.Name))) {  
            write-host "Copying font: $fontFile"
            Copy-Item -Path $fontFile.FullName -Destination ("$($env:windir)\Fonts\" + $fontFile.Name) -Force 
        } else {  write-host "Font already exists: $fontFile" }

        If (!(Get-ItemProperty -Name $fontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -ErrorAction SilentlyContinue)) {  
			write-host "Registering font: $fontFile"
            New-ItemProperty -Name $fontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $fontFile.Name -Force -ErrorAction SilentlyContinue | Out-Null  
        } else {  write-host "Font already registered: $fontFile" }
           
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($oShell) | out-null 
        Remove-Variable oShell               
             
	} catch {            
		write-host "Error installing font: $fontFile. " $_.exception.message
	}
	
 } 
 
 
# Loop through each font file and install
foreach ($fontFile in $fontFiles) {
    $filePath = Join-Path -Path $fontDirectory -ChildPath $fontFile

    # Check if the font file exists
    if (Test-Path -Path $filePath) {
        # Install the font using Install-Font function
        Install-Font -fontFile (Get-Item $filePath)
    } else {
        Write-Output "Font file not found: $fontFile"
    }
}

# Download URL for BGInfo
$bgInfoUrl = "https://download.sysinternals.com/files/BGInfo.zip"
$bgInfoOutput = "$installFolder\BGInfo.zip"

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
 
