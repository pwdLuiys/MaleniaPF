MaleniaPF (Malenia Post-Format Tool)

MaleniaPF is an automation tool designed to solve the first and most annoying problem of anyone who has just formatted their Windows: the endless hunt for video drivers. The name is a tribute to Malenia from Elden Ring because installing AMD drivers sometimes feels like a boss fight with two phases where you die at the end due to a version mismatch.

Currently, the project focuses on intelligent hardware detection and the automatic download of official NVIDIA and AMD installers.
How It Works

The tool operates in three distinct layers to ensure you don't have to open a browser and deal with ads or confusing dropdown menus:

    Hardware Detection: The script uses WMI (Windows Management Instrumentation) to query the operating system about which graphics cards are connected. It identifies whether you have an NVIDIA GPU, an AMD/Radeon GPU, or both (for the brave souls using hybrid setups).

    NVIDIA Strategy: It uses simple Web Scraping with BeautifulSoup to locate the latest NVIDIA App executable. This is the most civilized part of the code, as NVIDIA's website doesn't try to block your entry like it's a fortified castle.

    AMD Strategy: Since AMD's website has several protections against automation and uses dynamic element loading, the tool uses Selenium in headless (invisible) mode. It simulates human behavior to navigate to the "Auto-Detect Tool" link and performs the download.

Quick Installation (Administrator Mode)

To make life easier for those who don't want to install Python or configure environment variables on a freshly formatted PC, the tool can be invoked directly via PowerShell.

Copy and paste the command below into your PowerShell as Administrator:
PowerShell

irm https://raw.githubusercontent.com/pwdLuiys/MaleniaPF/refs/heads/main/install.ps1 | iex

What this command does:

    Checks if Google Chrome is installed (required for the AMD Selenium engine). If not, it uses Winget to install it silently.

    Downloads the latest version of the executable (MaleniaPF.exe) to your temporary folder.

    Runs the detection and starts the downloads automatically.

System Requirements

    Operating System: Windows 10 or Windows 11.

    Privileges: Administrator access (required for Winget and WMI to function correctly).

    Browser: Google Chrome or Microsoft Edge (installed automatically if necessary via the installation script).

Technical Notes and Security

    Temporary Files: The tool performs an automatic cleanup of residual .crdownload files and old installers in the execution folder to avoid version conflicts.

    Security: MaleniaPF does not install the drivers automatically for security reasons and user choice. It only ensures that the official and verified installers are in your folder, ready to be executed.

    Timeout: The download monitoring has a limit of 900 seconds. If your internet is wood-powered and takes more than 15 minutes, the script will terminate the session for safety.

Roadmap

The plan for MaleniaPF is to evolve from a "driver downloader" into the ultimate tool for skipping tedious setup tasks:

    Support for Intel integrated GPUs.

    Winget integration for bulk software installation (VSCode, Discord, Steam, Spotify, etc.).

    Script to disable telemetry and unnecessary Windows "bloat."

    Silent installation of essential runtimes (DirectX, Visual C++ Redistributables).