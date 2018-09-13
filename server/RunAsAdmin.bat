@echo off
echo Administrative permissions required. Detecting permissions...

REM Checking Administrative permissions
net session >nul 2>&1
if %errorLevel% == 0 (
	echo Success: Administrative permissions confirmed.
) else (
	ECHO you are NOT Administrator. Exiting...
    PING 127.0.0.1 > NUL 2>&1
    EXIT /B 1
)

Taskkill.exe /im rdpclip.exe

pushd %~dp0

REM the replacement mstsc files should be in the same directory as this script.
takeown /f "%SystemRoot%\System32\rdpclip.exe"
icacls "%SystemRoot%\System32\rdpclip.exe" /grant Everyone:F

REM Make backups to a folder in C:\ drive
copy "%SystemRoot%\System32\rdpclip.exe" "%SystemRoot%\System32\rdpclip.exe.bak"

REM Copy the new files from current directory over the system32 ones
copy rdpclip.exe "%SystemRoot%\System32\rdpclip.exe" /Y

REM remove everyone permission
icacls "%SystemRoot%\System32\rdpclip.exe" /remove Everyone

REM set owner back to trusted installer.
icacls "%SystemRoot%\System32\rdpclip.exe" /grant Administrators:f
icacls "%SystemRoot%\System32\rdpclip.exe" /setowner "NT Service\TrustedInstaller"

popd

ECHO Files have been replaced
PING 127.0.0.1 > NUL 2>&1
EXIT /B 1
