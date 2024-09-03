@echo off
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit
cd /d %~dp0
FOR /F "tokens=2* skip=2" %%a in ('reg query "HKCU\Software\Valve\Steam" /v "SteamPath"') do set SteamPath=%%b
REM If return value is not an exist path(Err Msg)
if not exist "%SteamPath%" (
    echo No steam detected. Please run steam at least once.
    pause
    exit
)
for %%I in (.) do set CurDirName=%%~nxI
if exist "%SteamPath%\steamui\skins\%CurDirName%" (
    goto Override
) else (
    goto Apply
)
exit

:Override
set /P Override=Skin already existed, Override?[y/N]
if "%Override%"=="y" goto Apply 
if "%Override%"=="Y" goto Apply
exit

:Apply
del /f /q "%SteamPath%\steamui\skins\%CurDirName%"
mkdir "%SteamPath%\steamui\skins"
xcopy /e /y "..\%CurDirName%\" "%SteamPath%\steamui\skins\%CurDirName%\"
del /f /q "%SteamPath%\steamui\skins\%CurDirName%\Install.cmd"
echo Enjoy your new steam! :^)
PAUSE