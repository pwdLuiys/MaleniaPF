$ErrorActionPreference = "Stop"

Write-Host "⚔️  MaleniaPF is preparing your PC..." -ForegroundColor Magenta

# --- 1. FUNÇÕES DO CHROME (Mantive sua lógica, só corrigi typos "Sucess" -> "Success") ---

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

function EnsureBrowser {
    if (Test-ChromeInstalled) {
        Write-Host "✅ Chrome detected" -ForegroundColor Green
        return
    }

    Write-Host "🌐 Trying to install chrome..." -ForegroundColor Yellow

    # TENTATIVA 1: WINGET
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "📦 [1] Attempting Winget..."
        try {
            winget install --id Google.Chrome -e --silent --accept-source-agreements --accept-package-agreements
            
            if (Test-ChromeInstalled) { 
                Write-Host "✅ Success via Winget." -ForegroundColor Green
                return 
            }
        } catch {
            Write-Host "⚠️ Winget failed." -ForegroundColor DarkYellow
        }
    }

    # TENTATIVA 2: MSI (Sandbox Friendly)
    Write-Host "📦 [2] Attempting MSI Direct Download..."
    $msiPath = "$env:TEMP\ChromeEnterprise.msi"
    $msiUrl = "https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7B97321481-8077-9683-5095-714249117622%7D%26lang%3Den%26browser%3D4%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dtrue%26ap%3Dx64-stable-statsdef_1%2Fdl%2Fchrome%2Finstall%2Fgooglechromestandaloneenterprise64.msi"

    try {
        Invoke-WebRequest -Uri $msiUrl -OutFile $msiPath
        Write-Host "   -> Installing MSI..."
        
        $proc = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$msiPath`" /qn /norestart" -Verb RunAs -PassThru
        $proc.WaitForExit()

        Remove-Item $msiPath -ErrorAction SilentlyContinue

        if (Test-ChromeInstalled) { 
            Write-Host "✅ Success via MSI." -ForegroundColor Green
            return 
        }
    } catch {
        Write-Host "❌ MSI failed: $_" -ForegroundColor Red
    }

    # TENTATIVA 3: CHOCOLATEY
    Write-Host "📦 [3] Attempting Chocolatey..."
    try {
        if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
            Write-Host "   -> Installing Chocolatey engine..."
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            $env:Path += ";$env:ALLUSERSPROFILE\chocolatey\bin"
        }
        
        choco install googlechrome -y --no-progress --ignore-checksums

        if (Test-ChromeInstalled) { 
            Write-Host "✅ Success via Chocolatey." -ForegroundColor Green
            return 
        }
    } catch {
        Write-Host "❌ None of the installation methods worked." -ForegroundColor Red
    }
}

# --- 2. EXECUÇÃO PRINCIPAL E ORGANIZAÇÃO DE PASTAS ---

try {
    # 2.1 Garante o Navegador antes de tudo
    EnsureBrowser

    if (-not (Test-ChromeInstalled)) {
        Write-Host "❌ FATAL: Chrome not found and installation failed. Aborting." -ForegroundColor Red
        Exit
    }

    # 2.2 Configuração das Pastas (AQUI ESTÁ A MUDANÇA)
    # Define a estrutura: Usuário -> MaleniaPF -> bin & Downloads
    $baseDir = "$env:USERPROFILE\MaleniaPF"
    $binDir  = "$baseDir\bin"
    $dlDir   = "$baseDir\Downloads"
    $exePath = "$binDir\MaleniaPF.exe"

    Write-Host "📂 Organizing folders at: $baseDir" -ForegroundColor Cyan
    
    # Cria as pastas se não existirem (-Force não dá erro se já existir)
    New-Item -ItemType Directory -Path $binDir -Force | Out-Null
    New-Item -ItemType Directory -Path $dlDir -Force | Out-Null

    # 2.3 Download
    $url = "https://github.com/pwdLuiys/MaleniaPF/releases/download/1.1/MaleniaPF.exe" 

    Write-Host "⬇️  Downloading MaleniaPF to 'bin' folder..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $url -OutFile $exePath

    # 2.4 Execução
    Write-Host "🚀 Starting MaleniaPF..." -ForegroundColor Green
    
    # Executa definindo o diretório de trabalho como a pasta bin
    Start-Process -FilePath $exePath -WorkingDirectory $binDir -Wait

    Write-Host "✨ Done. Check '$dlDir' for your drivers." -ForegroundColor Green

} catch {
    Write-Host "❌ Fatal Error: $_" -ForegroundColor Red
}