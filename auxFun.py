import os
import glob
import time


# HELPER FUNCTIONS (The ones doing the dirty work)
# FUNÇÕES AUXILIARES (uns negocio pra usar depois)

def cleanOldFiles(destinFolder, pattern):
    print(f"Cleaning files matching: {pattern}...")
    filesToDelete = glob.glob(os.path.join(destinFolder, pattern))
    
    for file in filesToDelete:
        try:
            os.remove(file)
            print(f"   -> Deleted: {os.path.basename(file)}")
        except Exception as e:
            print(f"   -> Error deleting {file}: {e}")

#Função pra esperar o download AMD acabar, vai que a internet do cara é um lixo?
#E com timeOut pq se esse cara nao baixar um negocio de 50mb em menos de 15 minutos também não merece
def waitToDownload(folder, maxTimeOut=900):
    print("Monitoring download progress...")
    secs = 0
    
    while secs < maxTimeOut:
        time.sleep(1)
        secs += 1
        
        # Check if temporary file still exists / Verifica se arquivo temporário ainda existe
        filesCrdownload = glob.glob(os.path.join(folder, "*.crdownload"))
        
        if filesCrdownload:
            # Still downloading, be patient / Ainda baixando, seja paciente
            if secs % 5 == 0:
                print(f"   ...Downloading ({secs}s)")
        else:
            # No more .crdownload? Give it a moment to settle / Sem .crdownload? Dá um tempo pra sentar e ficar tranquilidade extrema rapaiz
            time.sleep(2)
            
            # Check if the final .exe arrived / Verifica se o .exe final chegou
            exes = glob.glob(os.path.join(folder, "*minimalsetup*.exe"))
            if exes:
                return True  # Success! / Sucesso!
            
    # Timeout reached, probably failed / Timeout atingido, provavelmente falhou
    return False

#Funçãozinha pra fazer o seguinte: Vamos pegar a pasta do usuario padrão do sistema, ou o que se encontra agora, vou decidir depois.
#Depois disso, eu vou criar uma pastazinha MaleniaPF dentro da pasta de usuario, la vão ter as pastas bin e downloads, obviamente o bin estatará o arquivo MaleinaPF.exe e downloads são os varios drivers ou programas que vamo baixar.
def getPath():
    #Vamo pegar a pasta do usuario agora.
    userPath = os.environ['USERPROFILE']

    #Vamo agora definir uma base pra onde os arquivinho ligeiro irao.. iram? seila portugues ta complexo
    basePath = os.path.join(userPath, 'MaleniaPF')

    #Definir onde fica os download
    downloadPath = os.path.join(basePath, 'Downloads')

    #Claro, que a gente precisa criar essa porcaria se ela não existir... porque se não a gente ficaria criando 101231231231 pastas
    if not os.path.exists(downloadPath):
        os.makedirs(downloadPath)
    
    return downloadPath