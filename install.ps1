#I need to be 100% that the user experience is good so... the program will be downloading the chrome web-driver for the use of selenium
#But Luiys, we'll have chrome... idfc this is a postformat tool, this is literally a post-formating tool
#This archive ensure that u have chrome-web-driver AND winget/chocolatey (we gonna need them after...)
$ErrorActionPreference = "Stop"

Write-Host "MaleniaPF is preparing your PC..." -ForegroundColor Magenta

function Install-Chrome-MSI {
    Write-Host "Try: [4/4] Final Fallback: Downloading Chrome MSI (Sandbox Safe)..." -ForegroundColor Cyan
    $msiPath = "$env:TEMP\Chrome.msi"
    #We dont need the updated version... just a version that works
    $msiUrl = "https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7B97321481-8077-9683-5095-714249117622%7D%26lang%3Den%26browser%3D4%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dtrue%26ap%3Dx64-stable-statsdef_1%2Fdl%2Fchrome%2Finstall%2Fgooglechromestandaloneenterprise64.msi"

    try {
        Invoke-WebRequest -Uri $msiUrl -OutFile $msiPath
        Write-Host "   -> Installing MSI silently..."
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$msiPath`" /qn /norestart" -Verb RunAs -Wait
        Write-Host "Chrome installed via MSI." -ForegroundColor Green
        return $true
    } catch {
        Write-Host "MSI Installation failed: $_" -ForegroundColor Red
        return $false
    }
}

function Ensure-Browser {
    #Lets see if u already have that chrome checky chekcy
    if (Get-Command chrome.exe -ErrorAction SilentlyContinue) {
        Write-Host "1/4] Chrome detected locally." -ForegroundColor Green
        return
    }
    
    $paths = @(
        "C:\Program Files\Google\Chrome\Application\chrome.exe",
        "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
    )
    foreach ($path in $paths) {
        if (Test-Path $path) {
            Write-Host "[1/4] Chrome detected at $path." -ForegroundColor Green
            return
        }
    }

    Write-Host "Chrome not found. Starting installation sequence..." -ForegroundColor Yellow

    #Lets try via winget
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "[2/4] Attempting Winget installation..."
        try {
            winget install --id Google.Chrome -e --silent --accept-source-agreements --accept-package-agreements
            if (Get-Command chrome.exe -ErrorAction SilentlyContinue) { return }
        } catch {
            Write-Host "Winget failed. Proceeding to next method..." -ForegroundColor DarkYellow
        }
    } else {
        Write-Host "Winget not found." -ForegroundColor DarkYellow
    }

    #winget did not work? lets try chocolatey
    Write-Host "[3/4] Attempting Chocolatey installation..."
    try {
        if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            $env:Path += ";$env:ALLUSERSPROFILE\chocolatey\bin"
        }
        
        #try to install that
        choco install googlechrome -y --no-progress --ignore-checksums
        return
    } catch {
        Write-Host "Chocolatey failed (Likely Sandbox limitation). Proceeding to Final Fallback..." -ForegroundColor DarkYellow
    }

    $success = Install-Chrome-MSI
    if (-not $success) {
        Write-Host "FATAL: Could not install Chrome by any method." -ForegroundColor Red
        Exit
    }
}

# main ''code''

try {
    Ensure-Browser

    $tempPath = "$env:TEMP\MaleniaPF.exe"
    $url = "https://raw.githubusercontent.com/pwdLuiys/MaleniaPF/refs/heads/main/install.ps1" 

    Write-Host "⬇Downloading MaleniaPF Tool..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $url -OutFile $tempPath

    Write-Host "Launching MaleniaPF..." -ForegroundColor Green
    Start-Process -FilePath $tempPath -Wait

} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}