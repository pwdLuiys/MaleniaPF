from GPUs import verifyHardware
import time
# ENTRY POINT (Where it all begins)
# PONTO DE ENTRADA (Onde as garotas molham suas calcinhas)
if __name__ == "__main__":
    print("="*40)
    print("   MaleniaPF - Post Format Tool")
    print("="*40)
    
    option = input('Start automated driver download? [C to continue, any other key to quit]: ').upper().strip()
    
    if option == 'C':
        verifyHardware()
        print("\nAll operations finished.")
        input("Press Enter to exit...")
    else:
        print('Quitting...')
        time.sleep(2)