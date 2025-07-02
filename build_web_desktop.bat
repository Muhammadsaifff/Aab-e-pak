@echo off
title Building Aab-e-Pak Web Desktop App
color 0A

echo.
echo ========================================
echo    Building Web Desktop App
echo ========================================
echo.

echo 🔧 Cleaning previous builds...
flutter clean

echo.
echo 📦 Getting dependencies...
flutter pub get

echo.
echo 🌐 Building web app for desktop...
flutter build web --release --web-renderer html

echo.
echo ========================================
echo    Build Complete!
echo ========================================
echo.

if exist "build\web\index.html" (
    echo ✅ Web desktop app built successfully!
    echo.
    echo 📁 Location: build\web\
    echo 🌐 Entry point: index.html
    echo.
    echo You can now run the web app by:
    echo 1. Opening build\web\index.html in your browser
    echo 2. Or serving it with a local web server
    echo.
    
    set /p choice="Would you like to open the app in your browser now? (y/n): "
    if /i "%choice%"=="y" (
        echo.
        echo 🚀 Opening Aab-e-Pak Web Desktop App...
        start "" "build\web\index.html"
    )
    
    echo.
    echo 💡 Pro Tip: For better performance, serve with:
    echo    python -m http.server 8000 --directory build\web
    echo    Then open: http://localhost:8000
) else (
    echo ❌ Build failed! Check the output above for errors.
)

echo.
pause
