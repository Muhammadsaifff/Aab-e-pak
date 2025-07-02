@echo off
echo ========================================
echo    Aab-e-Pak Web App Server
echo ========================================
echo.

cd /d "%~dp0"

if not exist "build\web\index.html" (
    echo ❌ Web build not found!
    echo Building web version now...
    flutter build web
    if errorlevel 1 (
        echo ❌ Build failed!
        pause
        exit /b 1
    )
)

echo 🚀 Starting web server...
echo 📱 Your app will open at: http://localhost:8080
echo ⏹️  Press Ctrl+C to stop the server
echo.

cd build\web

:: Try Python 3 first
python -c "import http.server; import webbrowser; import socketserver; import os; os.chdir('.'); webbrowser.open('http://localhost:8080'); socketserver.TCPServer(('', 8080), http.server.SimpleHTTPRequestHandler).serve_forever()" 2>nul

if errorlevel 1 (
    :: Try Python 2 if Python 3 fails
    python -m SimpleHTTPServer 8080 2>nul
    
    if errorlevel 1 (
        :: If Python is not available, try using Node.js
        echo Python not found, trying alternative method...
        echo.
        echo Please install Python from: https://www.python.org/downloads/
        echo Or use the Flutter method: run_web_app.bat
        echo.
        pause
        exit /b 1
    )
)

pause
