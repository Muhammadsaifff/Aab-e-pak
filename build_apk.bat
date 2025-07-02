@echo off
echo ========================================
echo    Building Aab-e-Pak APK
echo ========================================
echo.

echo Checking Flutter and Android setup...
flutter doctor
if %errorlevel% neq 0 (
    echo.
    echo WARNING: Flutter doctor found issues.
    echo Please resolve them before building APK.
    echo Run setup_android.bat for help.
    pause
    exit /b 1
)

echo.
echo Cleaning project...
flutter clean

echo.
echo Getting dependencies...
flutter pub get

echo.
echo Building release APK...
echo This may take several minutes...
flutter build apk --release

if %errorlevel% eq 0 (
    echo.
    echo ========================================
    echo    BUILD SUCCESSFUL!
    echo ========================================
    echo.
    echo APK Location: build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo You can now:
    echo 1. Install the APK on Android devices
    echo 2. Share the APK file
    echo 3. Upload to Google Play Store
    echo.
    
    if exist "build\app\outputs\flutter-apk\app-release.apk" (
        echo Opening APK folder...
        explorer "build\app\outputs\flutter-apk\"
    )
) else (
    echo.
    echo ========================================
    echo    BUILD FAILED!
    echo ========================================
    echo.
    echo Please check the error messages above.
    echo Common solutions:
    echo 1. Run: flutter clean
    echo 2. Run: flutter pub get
    echo 3. Check Android SDK installation
    echo 4. Run: flutter doctor --android-licenses
)

echo.
pause
