@echo off
echo.
echo ========================================
echo    Getting SHA-1 for Google Sign-In
echo ========================================
echo.

echo Method 1: Using keytool (most reliable)
echo ========================================
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android | findstr SHA1

echo.
echo Method 2: Using Gradle
echo ========================================
cd android
call gradlew signingReport | findstr SHA1

echo.
echo ========================================
echo Copy the SHA1 value above and add it to Firebase Console
echo ========================================
pause
