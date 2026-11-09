@echo off
cd /d "C:\scrcpy-win64-v5.0"

echo Connecting to Xiaomi Fire TV...
adb connect 192.168.29.46:5555

timeout /t 2 /nobreak >nul

echo Starting TV audio...
scrcpy.exe --no-video --no-control

pause
