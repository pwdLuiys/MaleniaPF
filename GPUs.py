#Tremzera
import os
import time
import urllib.request
import wget
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from auxFun import cleanOldFiles, waitToDownload, getPath
import wmi, cpuinfo

# TO DO:
# Optmise and make work on Windows sandbox (for all possibilities)
# The truth is too make this work on Windows sandbox, i do need to configure the install.ps1 code, not this one... shit, next time maybe?

#OBS: Fiquei com preguiça de comentar todo o código então comentei as partes mais importantes e o resto pedi pra uma IA de procedencia duvidosa comentar. (SO COMENTAR PLMDS NÃO SOU VIBE CODER, por mais que eu tenha aprendido a usar selenium em uma... mas não vem ao caso tmj! o resto foi com o Dr-Chuck(Professor em michigan), o cara é brabo.) Abraços pra voce meu amigo.

#MAIN FUNCTIONS (Where the magic happens... or doesn't)
#FUNÇÕES PRINCIPAIS aqui separarmos os homosapiens dos homo sapiens sapiens

def downloadAmd():
    #It also works with CPUS, so im gonna just re use it
    print("\n[AMD MODULE] Starting process...")
    downloadPath = getPath()
    print(f'Downloads folder created in: {downloadPath}')

    # Step 1: Cleanup time! / Passo 1: limpa saporra se tiver arquivo ruim pra não confundir na hora de instalar
    cleanOldFiles(downloadPath, "*.crdownload")
    cleanOldFiles(downloadPath, "*minimalsetup*.exe")

    # Step 2: Configure our headless Chrome / Passo 2: Configurar nosso Chrome invisível
    ##AMD VAI SE FUDE COM ESSE SITE SEU AI
    chromeOptions = Options()
    chromeOptions.add_argument("--headless=new")  # No window, we're sneaky / Sem janel pros cara não fechar achando que é virus (mal sabe eles que é)
    chromeOptions.add_argument("--window-size=1920,1080")  # Standard size just in case / Tamanho padrão por via das dúvidas
    
    # User-Agent to avoid being blocked (pretending to be a real human, shhh)
    # User-Agent pra não ser bloqueado, não grita AMD
    userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    chromeOptions.add_argument(f'user-agent={userAgent}')
    
    # Download preferences (where to save, don't ask questions, just do it)
    # Preferências de download (onde salvar, não faça perguntas, só faça)
    prefs = {
        "download.default_directory": downloadPath,
        "download.prompt_for_download": False,  # No popups please / Sem popups por favor
        "safebrowsing.enabled": True,
        "profile.default_content_setting_values.automatic_downloads": 1  # Auto-download everything / Auto-baixa tudo
    }
    chromeOptions.add_experimental_option("prefs", prefs)
    chromeOptions.add_argument("--safebrowsing-disable-download-protection")  # Stop warning about exe files / Para de avisar sobre arquivos exe

    # Install ChromeDriver automatically (webdriver-manager does the heavy lifting)
    # Instala ChromeDriver automaticamente (webdriver-manager faz o trabalho pesado)
    service = Service(ChromeDriverManager().install())
    browser = webdriver.Chrome(service=service, options=chromeOptions)

    try:
        print("Accessing AMD website...")
        browser.get('https://www.amd.com/en/support/download/drivers.html#search-browse-drivers')

        time.sleep(5)  # Let the page load, no rush / Deixa a página carregar, sem pressa

        # Find all anchor tags / Encontra todas as tags de link
        elements = browser.find_elements(By.TAG_NAME, 'a')
        downloadStarted = False

        print(f"   -> Found {len(elements)} links. Searching for installer...")

        # Loop through all links looking for the installer
        # Percorre todos os links procurando o instalador
        for ele in elements:
            href = ele.get_attribute('href')
            
            # Security check: must be .exe AND minimal setup (we don't want random executables)
            # Checagem de segurança: tem que ser .exe E minimalsetup (Esse trem é um sufixo padrão dos .exes da AMD se não me egano) (não queremos executáveis aleatórios)
            if href and '.exe' in href and 'minimalsetup' in href.lower():
                print(f"Link found: {href}")
                
                # Click using JavaScript (sometimes regular click fails)
                # Clica usando JavaScript (às vezes click normal falha)
                browser.execute_script("arguments[0].click();", ele)
                
                time.sleep(5)  # Give it time to start / Dá tempo pra começar
                downloadStarted = True
                break  # Found it, we're done here / Achou, terminamos aqui
        
        if downloadStarted:
            success = waitToDownload(downloadPath)
            if success:
                print("AMD Download - SUCCESS")
            else:
                print("AMD Download - FAILED (Timeout)")
        else:
            print("No valid download link found.")
            # Debug screenshot if nothing found / Screenshot de debug se não achou nada
            browser.save_screenshot("debug_amd_error.png")

    except Exception as e:
        print(f"Error in AMD module: {e}")

    finally:
        browser.quit()  # Always close the browser, good manners / Sempre fecha o navegador, boa educação

def downloadNvidia():
    # GOD BLESS NVIDIA
    # ou não vai se fude com esse seus trem de IA e deixar os negocio mais caro
    print("\n[NVIDIA MODULE] Starting process...")
    currentFolder = getPath()
    print(f'Downloaded in {currentFolder}')
    
    # Step 1: Delete old NVIDIA installers / Passo 1: Apagar instaladores velhos da NVIDIA
    cleanOldFiles(currentFolder, "*NVIDIA*.exe")

    # Step 2: Web scraping magic / Passo 2 magica do web-s
    try:
        url = 'https://www.nvidia.com/en-us/software/nvidia-app/'
        print("Accessing NVIDIA website...")
        
        # Add headers so we don't look like a bot (we totally are though)
        # Adiciona headers pra não parecer bot (mas somos totalmente)
        headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
        req = urllib.request.Request(url, headers=headers)
        html = urllib.request.urlopen(req).read()
        
        # Parse the HTML with BeautifulSoup / Parseia o HTML com BeautifulSoup
        soup = BeautifulSoup(html, 'html.parser')
        tags = soup('a')  # Get all anchor tags / Pega todas as tags de link
        
        linkFinal = None

        # Search for the download link containing both 'download' and '.exe'
        # Procura pelo link de download contendo 'download' e '.exe'
        for tag in tags:
            href = str(tag.get('href', None))
            
            if 'download' in href and '.exe' in href:
                linkFinal = href
                print(f"Link found: {linkFinal}")
                break  # Got it, let's move on / Pegamos, vamos em frente

        if linkFinal:
            print("Downloading via Wget...")
            wget.download(linkFinal, out=currentFolder)  # wget handles the download nicely / wget cuida do download direitinho e joga na pasta que a gente quer
            print("\nNVIDIA Download - SUCCESS")
        else:
            print("No NVIDIA link found.")

    except Exception as e:
        print(f"Error in NVIDIA module: {e}")

def downloadIntel():
    #It also works with CPUS, so im gonna just re use it
    currentFolder = getPath()
    cleanOldFiles(currentFolder, "*Intel*.exe")
    cleanOldFiles(currentFolder, "*Intel-Driver*.exe")

    try:
        url = 'https://www.intel.com/content/www/us/en/support/detect.html'
        html = urllib.request.urlopen(url).read()
        soup = BeautifulSoup(html, 'html.parser')

        tags = soup('a')
        sucess = False

        for tag in tags:
                downloadB = str(tag.get('href', None))
                if 'installer' in downloadB:
                    downloadButton = downloadB
                    sucess = True
        if sucess:
            wget.download(downloadButton, out=currentFolder)
        else:
            print("Didn't find any download link")
    except Exception as e:
        print(f'Error in Intel module! {e}')

def verifyHardware():
    print("\nScanning Hardware...")
    
    try:
        # Connect to WMI / Conecta ao WMI
        connSys = wmi.WMI()
        gpus = connSys.Win32_VideoController()  # Get all video controllers / Pega todos os controladores de vídeo

        amdFound = False
        nvidiaFound = False
        intelFound = False

        print('   Hardware List:')
        for gpu in gpus:
            gpuName = gpu.Name
            print(f'   -> {gpuName}')

            # Check if it's NVIDIA or AMD/Radeon or Intel
            # Verifica se é NVIDIA ou AMD/Radeon ou Intel
            if 'NVIDIA' in gpuName.upper():
                nvidiaFound = True
            if 'AMD' in gpuName.upper() or 'RADEON' in gpuName.upper():
                amdFound = True
            if 'INTEL' in gpuName.upper():
                intelFound = True
            
        
        print("-" * 30)
        
        # Now download drivers based on what we found
        # Agora baixa os drivers baseado no que encontramos
        if nvidiaFound:
            print("NVIDIA GPU Detected.")
            downloadNvidia()
        
        if amdFound:
            print("AMD GPU Detected.")
            downloadAmd()
        
        if intelFound:
            print("Intel GPU Detected")
            downloadIntel()
            
        if not nvidiaFound and not amdFound and not intelFound:
            print("No dedicated GPU (AMD/NVIDIA/Intel) found.")
            print("WTF ARE U USING?")

        # CPU PART
        cpu = cpuinfo.get_cpu_info() # Get CPU info...
        tryCpuCatch = cpu.get('vendor_id_raw', '').lower() #Lets find the vender_id_raw peace on the dict, and if it is authenticamd is AMD, else is intel.


        cpuIsIntel = False
        cpuIsAmd = False
        if 'authenticamd' in tryCpuCatch:
            print(f'{cpu['brand_raw']}...')
            cpuIsAmd = True
        if 'genuineintel' in tryCpuCatch:
            print(f'{cpu['brand_raw']}')
            cpuIsIntel = True
        

        if cpuIsAmd:
            if amdFound:
                print('Chipset driver included in GPU package, skipping...')
            else:
                print('Downloading cpu chipset...')
                downloadAmd()
        if cpuIsIntel:
            if intelFound:
                print('Chipset driver included in GPU package, skipping...')
            else:
                print('Downloading cpu chipset...')
                downloadIntel()

    except Exception as error:
        print(f'Hardware Scan Error: {error}')