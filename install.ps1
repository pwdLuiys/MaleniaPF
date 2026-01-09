#I need to be 100% that the user experience is good so... the program will be downloading the chrome web-driver for the use of selenium
#But Luiys, we'll have chrome... idfc this is a postformat tool, this is literally a post-formating tool
#This archive ensure that u have chrome-web-driver AND winget/chocolatey (we gonna need them after...)
$ErrorActionPreference = "Stop"

try {
    Import-Module Microsoft.PowerShell.Archive -ErrorAction SilentlyContinue
} catch {}

Write-Host "MaleniaPF is preparing your PC..." -ForegroundColor Magenta

function iBrowser {
    if (Get-Command chrome.exe -ErrorAction SilentlyContinue) {
        Write-Host "Chrome detected" -ForegroundColor Green
        return
    }

    Write-Host "installing chrome... yea thats right (u can uninstall it after)" -ForegroundColor Yellow
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "Using Winget to install Chrome..."
        winget install --id Google.Chrome -e --silent --accept-source-agreements --accept-package-agreements
    } 
    else {
        Write-Host "Winget not found. Installing Chocolatey as fallback..." -ForegroundColor Cyan
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        
        $env:Path += ";$env:ALLUSERSPROFILE\chocolatey\bin"
        
        Write-Host "Using Chocolatey to install Chrome..."
        choco install googlechrome -y --no-progress
    }
}


try {
    iBrowser

    $tempPath = "$env:TEMP\MaleniaPF.exe"
    $url = "LINK_DO_SEU_GITHUB_RELEASE"

    Write-Host "⬇Downloading MaleniaPF main tool..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $url -OutFile $tempPath

    Write-Host "Launching hardware detection..." -ForegroundColor Green
    Start-Process -FilePath $tempPath -Wait

} catch {
    Write-Host "An unexpected error occurred: $_" -ForegroundColor Red
}