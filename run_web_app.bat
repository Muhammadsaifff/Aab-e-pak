@echo off
title Aab-e-Pak Web Server
color 0A

echo.
echo ========================================
echo    🚀 Aab-e-Pak Web App Server
echo ========================================
echo.

cd /d "%~dp0"

:: Check if web build exists
if not exist "build\web\index.html" (
    echo ❌ Web build not found! Building now...
    echo.
    flutter build web
    if errorlevel 1 (
        echo ❌ Build failed! Please check for errors.
        pause
        exit /b 1
    )
    echo ✅ Build completed!
    echo.
)

echo 🌐 Starting web server...
echo 📱 Your app will open at: http://localhost:8080
echo ⏹️  Press Ctrl+C to stop the server
echo.

:: Try Python method first
python simple_server.py 2>nul

if errorlevel 1 (
    echo Python method failed, trying Flutter method...
    echo.

    :: Use Flutter as fallback
    flutter run -d web-server --web-port 8080

    if errorlevel 1 (
        echo.
        echo ❌ All methods failed!
        echo.
        echo Please try:
        echo 1. Install Python: https://www.python.org/downloads/
        echo 2. Double-click simple_server.py
        echo.
        pause
    )
)

pause
