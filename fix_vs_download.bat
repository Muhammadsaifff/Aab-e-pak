@echo off
title Fix Visual Studio Download Issues
color 0C

echo.
echo ========================================
echo    Visual Studio Download Fix
echo ========================================
echo.

echo 🚨 Visual Studio download stuck at 0b?
echo Let's try some quick fixes!
echo.

echo 🔧 Fix 1: Clear Visual Studio Cache
echo =====================================
set vs_cache="%ProgramData%\Microsoft\VisualStudio\Packages"
if exist %vs_cache% (
    echo Clearing Visual Studio cache...
    rmdir /s /q %vs_cache%
    echo ✅ Cache cleared!
) else (
    echo ℹ️  No cache found to clear.
)

echo.
echo 🔧 Fix 2: Reset Network Components
echo ===================================
echo Resetting Windows network stack...
netsh winsock reset
netsh int ip reset
ipconfig /flushdns
echo ✅ Network components reset!

echo.
echo 🔧 Fix 3: Alternative Download Methods
echo ======================================
echo.
echo Option A: Try Winget (Windows Package Manager)
echo ----------------------------------------------
winget --version >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ Winget is available!
    echo.
    set /p use_winget="Install Visual Studio Build Tools via Winget? (y/n): "
    if /i "%use_winget%"=="y" (
        echo Installing Visual Studio Build Tools...
        winget install Microsoft.VisualStudio.2022.BuildTools
        echo.
        echo Installing C++ workload...
        winget install Microsoft.VisualStudio.2022.BuildTools --override "--quiet --wait --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.Windows10SDK.19041"
    )
) else (
    echo ❌ Winget not available. Install from Microsoft Store.
)

echo.
echo Option B: Direct ISO Download
echo -----------------------------
echo 1. Go to: https://my.visualstudio.com/Downloads
echo 2. Sign in with Microsoft account (free)
echo 3. Download Visual Studio Community 2022 ISO
echo 4. Mount and install with C++ workload
echo.

set /p open_iso="Open ISO download page? (y/n): "
if /i "%open_iso%"=="y" (
    start "" "https://my.visualstudio.com/Downloads"
)

echo.
echo Option C: Chocolatey Package Manager
echo ------------------------------------
where choco >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ Chocolatey is available!
    set /p use_choco="Install Visual Studio Build Tools via Chocolatey? (y/n): "
    if /i "%use_choco%"=="y" (
        choco install visualstudio2022buildtools --package-parameters "--add Microsoft.VisualStudio.Workload.VCTools"
    )
) else (
    echo ❌ Chocolatey not installed.
    echo Install from: https://chocolatey.org/install
)

echo.
echo 🔧 Fix 4: Network Troubleshooting
echo ==================================
echo.
echo Try these if download still fails:
echo 1. 📱 Use mobile hotspot instead of WiFi
echo 2. 🛡️  Temporarily disable antivirus
echo 3. 🌐 Try different DNS (8.8.8.8, 1.1.1.1)
echo 4. ⏰ Download at different time (less congestion)
echo 5. 🏢 If corporate network, contact IT
echo.

echo 🔧 Fix 5: Minimal Installation Command
echo =======================================
echo.
echo If you have the installer but it's not working, try:
echo.
echo vs_buildtools.exe --quiet --wait --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.Windows10SDK.19041
echo.

echo.
echo ========================================
echo    After Successful Installation
echo ========================================
echo.
echo 1. Restart your computer
echo 2. Run: flutter doctor
echo 3. Should see: ✅ Visual Studio - develop for Windows
echo 4. Run: build_windows.bat
echo 5. Get your native Windows .exe file!
echo.

echo 💡 Still having issues? Check VS_DOWNLOAD_FIXES.md for more solutions.
echo.

pause
