@echo off
title Get SHA-1 Fingerprint for Firebase
color 0A

echo.
echo ========================================
echo    Getting SHA-1 Fingerprint
echo ========================================
echo.

cd /d "%~dp0"

echo 🔍 Getting SHA-1 fingerprint for Firebase setup...
echo.

cd android

echo Method 1: Using Gradle (Recommended)
echo =====================================
call gradlew signingReport

echo.
echo.
echo Method 2: Using Keytool (Alternative)
echo =====================================
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android 2>nul

if errorlevel 1 (
    echo.
    echo ⚠️  Debug keystore not found at default location.
    echo This is normal if you haven't built an APK yet.
    echo.
    echo Please run: flutter build apk
    echo Then run this script again.
)

echo.
echo ========================================
echo    Instructions
echo ========================================
echo.
echo 1. Copy the SHA1 value from above
echo 2. Go to Firebase Console: https://console.firebase.google.com
echo 3. Select your project: aab-e-pak-app
echo 4. Go to Project Settings (gear icon)
echo 5. Find your Android app
echo 6. Click "Add fingerprint"
echo 7. Paste the SHA1 value
echo 8. Click Save
echo 9. Download updated google-services.json
echo 10. Replace android/app/google-services.json
echo 11. Rebuild your APK
echo.

pause
