Here is the revised README in English. I have removed all emojis and stripped out the humor to keep it clean, professional, and direct, suitable for a technical portfolio or general public usage.
MaleniaPF - Post-Format Automation Tool

MaleniaPF is a utility designed to streamline the system configuration process after a fresh Windows installation. Its primary function is to automate the detection of hardware components (GPU and CPU) and download the appropriate official drivers, eliminating the need for manual navigation through manufacturer websites.

This tool is designed to be robust, handling environment dependencies automatically to ensure execution on a clean operating system.
Key Features

    Automated Hardware Detection: Uses Windows Management Instrumentation (WMI) to identify NVIDIA, AMD, and Intel graphics cards, as well as processor architecture.

    Intelligent Download Strategies:

        NVIDIA: Direct scraping of the NVIDIA App installer.

        AMD: Headless browser automation (Selenium) to navigate AMD's dynamic support pages and bypass bot protection.

        Intel: Detection and retrieval of the latest Intel Driver & Support Assistant.

    Environment Management: The launcher script automatically checks for and installs necessary dependencies (such as Google Chrome for the Selenium engine) using Winget, MSI, or Chocolatey.

    Organized File Structure: Automatically creates a dedicated workspace in the user's directory to keep executables and downloads separate.

Quick Installation

The tool is designed to run via a single PowerShell command, which handles directory creation, dependency checking, and execution.

    Open PowerShell as Administrator.

    Run the following command:

PowerShell

irm https://raw.githubusercontent.com/pwdLuiys/MaleniaPF/main/install.ps1 | iex

What happens when you run this command?

    Dependency Check: The script verifies if Google Chrome is installed (required for AMD driver retrieval). If missing, it attempts to install it via Winget, direct MSI download, or Chocolatey.

    Environment Setup: It creates the directory structure at %USERPROFILE%\MaleniaPF.

    Deployment: Downloads the latest MaleniaPF.exe release to the bin folder.

    Execution: Launches the tool to scan hardware and download drivers.

Directory Structure

To ensure a clean user environment, the tool organizes files as follows:
Plaintext

C:\Users\YourUsername\MaleniaPF\
│
├── bin\
│   └── MaleniaPF.exe      # The main application executable
│
└── Downloads\
    ├── NVIDIA_Installer.exe
    ├── amd_software_adrenalin.exe
    └── intel_driver_assistant.exe

Technical Details

The application logic is divided into specific modules based on the hardware vendor:

    Hardware Scanning: The tool queries Win32_VideoController via WMI to determine if dedicated (NVIDIA/AMD/Intel Arc) or integrated (Intel UHD/Iris) graphics are present.

    CPU Chipset Logic: If an AMD CPU is detected but a non-AMD GPU is present, the tool will still trigger the AMD download module to ensure chipset drivers are obtained.

    Download Management:

        Uses wget for static links (NVIDIA/Intel).

        Uses Selenium with a custom Chrome WebDriver for dynamic links (AMD).

        Includes automatic cleanup of partial downloads (.crdownload) and previous installer versions to prevent conflicts.

Requirements

    OS: Windows 10 or Windows 11 (x64).

    Permissions: Administrator privileges are required for the installation script to manage dependencies.

    Connection: Active internet connection required for scraping and downloading.

Disclaimer

This tool downloads the official installers from manufacturer websites but does not execute the driver installation silently. This is a design choice to ensure system stability and give the user control over the final installation step, as graphics driver updates often require screen flickering or system restarts.
Roadmap

Future updates planned for the project:

    Integration with Winget for bulk installation of essential software (VSCode, Browsers, Utilities).

    System debloating scripts (telemetry removal).

    Silent installation options for standard runtimes (DirectX, Visual C++ Redistributables).

License

This project is licensed under the MIT License.