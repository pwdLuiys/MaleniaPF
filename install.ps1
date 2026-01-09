
$ErrorActionPreference = "Stop"

Write-Host "⚔️  MaleniaPF is preparing your PC..." -ForegroundColor Magenta

function Test-ChromeInstalled {
    $paths = @(
        "C:\Program Files\Google\Chrome\Application\chrome.exe",
        "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
        "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
    )
    
    foreach ($path in $paths) {
        if (Test-Path $path) {
            return $true
        }
    }
    return $false
}

function Ensure-Browser {
    if (Test-ChromeInstalled) {
        Write-Host "Chrome detected" -ForegroundColor Green
        return
    }

    Write-Host "Trying to install chrome" -ForegroundColor Yellow

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "[1] winget."
        try {
            winget install --id Google.Chrome -e --silent --accept-source-agreements --accept-package-agreements
            
            if (Test-ChromeInstalled) { 
                Write-Host "Sucess via Winget." -ForegroundColor Green
                return 
            }
        } catch {
            Write-Host "Winget failed" -ForegroundColor DarkYellow
        }
    }

    Write-Host "[2]Msi..."
    $msiPath = "$env:TEMP\ChromeEnterprise.msi"
    $msiUrl = "https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7B97321481-8077-9683-5095-714249117622%7D%26lang%3Den%26browser%3D4%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dtrue%26ap%3Dx64-stable-statsdef_1%2Fdl%2Fchrome%2Finstall%2Fgooglechromestandaloneenterprise64.msi"

    try {
        Invoke-WebRequest -Uri $msiUrl -OutFile $msiPath
        Write-Host "   -> installing msi"
        
        $proc = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$msiPath`" /qn /norestart" -Verb RunAs -PassThru
        $proc.WaitForExit()

        Remove-Item $msiPath -ErrorAction SilentlyContinue

        if (Test-ChromeInstalled) { 
            Write-Host "Sucess via MSI." -ForegroundColor Green
            return 
        }
    } catch {
        Write-Host "MSI failed: $_" -ForegroundColor Red
    }

    Write-Host "[3]Chocolatey"
    try {
        if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
            Write-Host "   -> Chocolatey engine..."
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            $env:Path += ";$env:ALLUSERSPROFILE\chocolatey\bin"
        }
        
        choco install googlechrome -y --no-progress --ignore-checksums

        if (Test-ChromeInstalled) { 
            Write-Host "Sucess via Chocolatey." -ForegroundColor Green
            return 
        }
    } catch {
        Write-Host "None of them did work" -ForegroundColor Red
    }
}

try {
    Ensure-Browser

    if (-not (Test-ChromeInstalled)) {
        Write-Host "We must not continue." -ForegroundColor Red
        Exit
    }

    $tempPath = "$env:TEMP\MaleniaPF.exe"
    $url = "https://github.com/pwdLuiys/MaleniaPF/releases/download/1.0/MaleniaPF.exe" 

    Write-Host "Downloading MaleniaPF" -ForegroundColor Cyan
    Invoke-WebRequest -Uri $url -OutFile $tempPath

    Write-Host "starting..." -ForegroundColor Green
    Start-Process -FilePath $tempPath -Wait

} catch {
    Write-Host "Error Fatal: $_" -ForegroundColor Red
}