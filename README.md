# Fire TV to Laptop Wireless Audio via ADB + scrcpy

Route audio from an Amazon/Xiaomi Fire TV to a Windows laptop over the local Wi-Fi network, while the TV continues displaying the video normally.

## What this project does

This setup uses:

```text
Fire TV
   │
   │ Wi-Fi / ADB
   ▼
Windows Laptop
   │
   │ scrcpy audio forwarding
   ▼
USB-C / Wired Earphones
```

The TV keeps playing the video on its own screen. The laptop is used only as the audio output device.

## Requirements

- Amazon Fire TV / Fire OS TV with ADB debugging enabled
- Windows laptop
- Fire TV and laptop connected to the same Wi-Fi network
- Android SDK Platform-Tools (`adb`)
- scrcpy 5.x or compatible version
- Wired earphones/headphones connected to the laptop

## Tested setup

The working setup used:

- Windows 11
- scrcpy 5.0
- ADB over Wi-Fi on port `5555`
- Fire TV running Android 11
- USB-C wired earphones connected to the laptop

## One-time Fire TV setup

On the Fire TV:

1. Enable Developer Options.
2. Enable ADB debugging.
3. Make sure the TV and laptop are connected to the same Wi-Fi network.
4. Note that the TV's IP address may change later, so this project uses ADB mDNS discovery instead of permanently storing an IP address.

## Install / folder setup

Place the scrcpy files in:

```text
C:\scrcpy-win64-v5.0
```

The folder should contain `scrcpy.exe` and the required ADB executable/files.

## Test the connection manually

Open Command Prompt and run:

```cmd
cd /d "C:\scrcpy-win64-v5.0"
```

Check connected ADB devices:

```cmd
adb devices
```

If the TV is already connected, it should appear similar to:

```text
192.168.x.x:5555    device
```

You can also connect manually with:

```cmd
adb connect TV_IP:5555
```

Example:

```cmd
adb connect 192.168.29.204:5555
```

## Audio-only scrcpy command

The key command is:

```cmd
scrcpy.exe --no-video --no-control
```

This starts scrcpy without displaying the TV video on the laptop and without controlling the TV from the laptop.

The TV continues displaying the video normally while its audio is forwarded to the laptop.

## Automatic connection script

The main script is:

```bat
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
```

Save it as:

```text
TV-Audio-Auto.bat
```

## How the automatic discovery works

The script runs:

```cmd
adb mdns services
```

ADB reports devices advertising ADB over the local network.

The script looks for:

```text
_adb._tcp
```

and extracts the current IP address and port.

For example:

```text
_adb._tcp    192.168.29.204:5555
```

The script then runs:

```cmd
adb connect 192.168.29.204:5555
```

and finally starts:

```cmd
scrcpy.exe --no-video --no-control
```

Because the IP is discovered each time, the script does not need a permanently hard-coded Fire TV IP address.

## Daily use

1. Turn on the Fire TV.
2. Connect the laptop to the same Wi-Fi.
3. Connect the wired earphones to the laptop.
4. Double-click:

```text
TV-Audio-Auto.bat
```

5. Wait for scrcpy to start.
6. Play content on the TV.

The video stays on the TV and the audio is heard through the laptop's connected earphones.

## Troubleshooting

### Fire TV is not found

Check:

- TV is powered on.
- Laptop and TV are on the same Wi-Fi network.
- ADB debugging is enabled.
- The TV has not changed to a different network.
- Windows Firewall is not blocking local ADB communication.

Run:

```cmd
adb mdns services
```

A working discovery result should contain an entry similar to:

```text
_adb._tcp    192.168.x.x:5555
```

### `adb devices` shows no device

Try:

```cmd
adb mdns services
```

Then manually connect using the discovered address:

```cmd
adb connect IP_ADDRESS:5555
```

Then:

```cmd
adb devices
```

### scrcpy does not start

Confirm that the working directory is:

```text
C:\scrcpy-win64-v5.0
```

Then test:

```cmd
scrcpy.exe --no-video --no-control
```

### Audio works but video is also shown on the laptop

Make sure the command contains:

```text
--no-video
```

The complete command is:

```cmd
scrcpy.exe --no-video --no-control
```

## Important notes

- The Fire TV and laptop must be on the same local network.
- The TV's IP address can change when DHCP leases change.
- The automatic script avoids relying on the previous fixed IP address.
- ADB debugging must remain enabled for this method to work.
- This method forwards the TV audio to the laptop; it does not require an HDMI capture device.
- The TV itself continues to display the video.

## Backup method

A fixed-IP connection can still be useful as a backup:

```bat
@echo off
cd /d "C:\scrcpy-win64-v5.0"

echo Connecting to Xiaomi Fire TV...
adb connect 192.168.29.46:5555

timeout /t 2 /nobreak >nul

echo Starting TV audio...
scrcpy.exe --no-video --no-control

pause
```

If the Fire TV receives a different IP, update the IP in this backup script or use `TV-Audio-Auto.bat` instead.

## Project files

Recommended repository structure:

```text
fire-tv-laptop-audio/
├── README.md
├── TV-Audio-Auto.bat
└── TV-Audio-Working.bat
```

Do not commit the entire scrcpy/Android SDK binaries to the repository unless you intentionally want to distribute them. The README can document where to obtain the required tools.

## License

Add a license appropriate for the repository before publishing. This project is primarily a configuration and automation script; scrcpy and Android Platform-Tools remain under their respective upstream licenses.
