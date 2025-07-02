@echo off
title Install Visual Studio Build Tools for Flutter Windows
color 0A

echo.
echo ========================================
echo    Visual Studio Build Tools Setup
echo ========================================
echo.

echo This script will help you install Visual Studio Build Tools
echo required for building native Windows Flutter apps.
echo.

echo 📋 What you need to install:
echo    ✅ Visual Studio Build Tools 2022
echo    ✅ Desktop development with C++ workload
echo    ✅ Windows 10/11 SDK
echo    ✅ CMake tools for Visual Studio
echo.

echo 🔗 Download Links:
echo.
echo Option 1 - Visual Studio Community (Free, Full IDE):
echo https://visualstudio.microsoft.com/vs/community/
echo.
echo Option 2 - Build Tools Only (Smaller, Command Line):
echo https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022
echo.

set /p choice="Would you like me to open the download page? (y/n): "
if /i "%choice%"=="y" (
    echo.
    echo 🌐 Opening Visual Studio download page...
    start "" "https://visualstudio.microsoft.com/vs/community/"
    echo.
    echo 📋 Installation Instructions:
    echo.
    echo 1. Download Visual Studio Community 2022
    echo 2. Run the installer
    echo 3. Select "Desktop development with C++" workload
    echo 4. Make sure these are checked:
    echo    - Windows 10/11 SDK (latest version)
    echo    - CMake tools for Visual Studio
    echo    - MSVC v143 - VS 2022 C++ x64/x86 build tools
    echo 5. Click Install (this may take 30-60 minutes)
    echo.
    echo After installation, restart your computer and run:
    echo flutter doctor
    echo.
    echo You should see: ✅ Visual Studio - develop for Windows
)

echo.
echo 💡 Alternative: If you already have Visual Studio installed,
echo    make sure you have the "Desktop development with C++" workload.
echo    You can modify your installation through Visual Studio Installer.
echo.

pause
