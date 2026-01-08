$ErrorActionPreference = "Stop"

Write-Host "⚔️  MaleniaPF: Blade of Miquella is preparing your PC..." -ForegroundColor Magenta

# 1. Garantir que o Chrome existe, é.... eu sei que o chrome talvez você não queira... mas é so desinstalar depois confia no pai (fazer pelo edge é feio)
$chromeExists = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App` Paths\chrome.exe -ErrorAction SilentlyContinue)
if (!$chromeExists) {
    Write-Host "installing Chrome webdriver" -ForegroundColor Yellow
    winget install --id Google.Chrome -e --silent --accept-source-agreements --accept-package-agreements
}

# 2. Definir onde baixar o MaleniaPF.exe
$tempPath = "$env:TEMP\MaleniaPF.exe"

# --- SUBSTITUA O LINK ABAIXO PELO LINK QUE VOCÊ COPIOU NO PASSO 3 ---
$url = "https://github.com/pwdLuiys/MaleniaPF/releases/download/1.0/MaleniaPF.exe"

Write-Host "Downloading..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $url -OutFile $tempPath

# 3. Executar a ferramenta
Write-Host "Hardware detection..." -ForegroundColor Green
Start-Process -FilePath $tempPath -Wait

# Limpeza opcional
# Remove-Item $tempPath