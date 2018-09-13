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

reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=x86 || set OS=x64

pushd %~dp0
REM the replacement mstsc files should be in the same directory as this script.

REM Take ownsership and grant everyone access to the MSTSC files.
takeown /f "%SystemRoot%\System32\mstsc.exe"
icacls "%SystemRoot%\System32\mstsc.exe" /grant Everyone:F
takeown /f "%SystemRoot%\System32\mstscax.dll"
icacls "%SystemRoot%\System32\mstscax.dll" /grant Everyone:F

REM Make backups to a folder in C:\ drive
copy "%SystemRoot%\System32\mstsc.exe" "%SystemRoot%\System32\mstsc.exe.bak"
copy "%SystemRoot%\System32\mstscax.dll" "%SystemRoot%\System32\mstscax.dll.bak"

REM Copy the new files from current directory over the system32 ones
copy win10b1511%OS%\mstsc.exe "%SystemRoot%\System32\mstsc.exe" /Y
copy win10b1511%OS%\mstscax.dll "%SystemRoot%\System32\mstscax.dll" /Y

REM remove everyone permission
icacls "%SystemRoot%\System32\mstsc.exe" /remove Everyone
icacls "%SystemRoot%\System32\mstscax.dll" /remove Everyone

REM set owner back to trusted installer.
icacls "%SystemRoot%\System32\mstsc.exe" /grant Administrators:f
icacls "%SystemRoot%\System32\mstscax.exe" /grant Administrators:f
icacls "%SystemRoot%\System32\mstsc.exe" /setowner "NT Service\TrustedInstaller"
icacls "%SystemRoot%\System32\mstscax.dll" /setowner "NT Service\TrustedInstaller"

popd

ECHO Files have been replaced
PING 127.0.0.1 > NUL 2>&1
EXIT /B 1
