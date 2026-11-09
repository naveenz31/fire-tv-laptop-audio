@echo off
setlocal

cd /d "C:\scrcpy-win64-v5.0"

echo.
echo ==========================================
echo       Xiaomi Fire TV - Auto Audio
echo ==========================================
echo.
echo Looking for Fire TV...
echo.

set "TV_ADDR="

for /f "tokens=3" %%A in ('adb mdns services ^| findstr "_adb._tcp"') do (
    set "TV_ADDR=%%A"
    goto :FOUND
)

:FOUND

if "%TV_ADDR%"=="" (
    echo.
    echo ==========================================
    echo       Fire TV NOT FOUND
    echo ==========================================
    echo.
    echo Make sure:
    echo - Fire TV is ON
    echo - Laptop and TV are on the same Wi-Fi
    echo - ADB debugging is enabled
    echo.
    pause
    exit /b
)

echo Fire TV found at: %TV_ADDR%
echo.
echo Connecting...

adb connect %TV_ADDR%

timeout /t 2 /nobreak >nul

echo.
echo Starting TV audio...
echo.

scrcpy.exe --no-video --no-control

echo.
echo Audio connection ended.
pause
