@echo off
title Building Aab-e-Pak Windows Desktop App
color 0A

echo.
echo ========================================
echo    Building Windows Desktop App
echo ========================================
echo.

echo 🔧 Cleaning previous builds...
flutter clean

echo.
echo 📦 Getting dependencies...
flutter pub get

echo.
echo 🖥️ Building Windows desktop app...
flutter build windows --release

echo.
echo ========================================
echo    Build Complete!
echo ========================================
echo.

if exist "build\windows\x64\runner\Release\aab_e_pak.exe" (
    echo ✅ Windows app built successfully!
    echo.
    echo 📁 Location: build\windows\x64\runner\Release\
    echo 🚀 Executable: aab_e_pak.exe
    echo.
    echo You can now run the desktop app by double-clicking:
    echo build\windows\x64\runner\Release\aab_e_pak.exe
    echo.
    
    set /p choice="Would you like to run the app now? (y/n): "
    if /i "%choice%"=="y" (
        echo.
        echo 🚀 Starting Aab-e-Pak Desktop App...
        start "" "build\windows\x64\runner\Release\aab_e_pak.exe"
    )
) else (
    echo ❌ Build failed! Check the output above for errors.
    echo.
    echo Common issues:
    echo - Make sure Visual Studio Build Tools are installed
    echo - Ensure Windows SDK is available
    echo - Check that all dependencies are compatible
)

echo.
pause
