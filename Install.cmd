@echo off
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit
cd /d %~dp0
for /F %%c in ('echo prompt $E ^| cmd') do set "esc=%%c"

set     "Red="41;97m""
set    "Gray="100;97m""
set   "Black="30m""
set   "Green="42;97m""
set    "Blue="44;97m""
set  "Yellow="43;97m""
set "Magenta="45;97m""

set    "_Red="40;91m""
set  "_Green="40;92m""
set   "_Blue="40;94m""
set  "_White="40;37m""
set "_Yellow="40;93m""

FOR /F "tokens=2* skip=2" %%a in ('reg query "HKCU\Software\Valve\Steam" /v "SteamPath"') do set SteamPath=%%b
REM If return value is not an exist path(Err Msg)
if not exist "%SteamPath%" (
    call :Error
    echo �밴���������......&pause>nul
    exit
)
for %%I in (.) do set CurDirName=%%~nxI
if exist "%SteamPath%\steamui\skins\%CurDirName%" (
    goto Override
) else (
    goto Apply
)
exit

:_color2
echo %esc%[%~1%~2%esc%[%~3%~4%esc%[0m
exit /b

:Error
echo.
call :_color2 %_White% "" %Red% "Ƥ����װʧ�ܣ����ֶ���������myskin�ļ��е�steam/steamui/skins"
echo.
exit /b

:Override
set /P Override=��Ƥ���Ѵ��ڣ��Ƿ񸲸ǣ�[y/N]
if "%Override%"=="y" goto Apply 
if "%Override%"=="Y" goto Apply
exit

:Apply
del /f /q "%SteamPath%\steamui\skins\%CurDirName%"
mkdir "%SteamPath%\steamui\skins"
xcopy /e /y "..\%CurDirName%\" "%SteamPath%\steamui\skins\%CurDirName%\"
del /f /q "%SteamPath%\steamui\skins\%CurDirName%\Install.cmd"
echo.
if exist "%SteamPath%\steamui\skins\%CurDirName%\skin.json" (
    if exist "%SteamPath%\steamui\skins\%CurDirName%\libraryroot.custom.css" (
        if exist "%SteamPath%\steamui\skins\%CurDirName%\webkit.css" (
            echo.
            call :_color2 %_White% "" %Green% "Ƥ����װ�ɹ�"
            echo.
            echo �밴���س���ǰ���Զ���......&pause>nul
            cd /d "%SteamPath%\steamui\skins\%CurDirName%"
            start skintool.exe .
        ) else (
            call :Error
            echo �밴���س�����skins�ļ���......&pause>nul
            cd /d "%SteamPath%\steamui\skins"
            start explorer.exe .
        )
    ) else (
        call :Error
        echo �밴���س�����skins�ļ���......&pause>nul
        cd /d "%SteamPath%\steamui\skins"
        start explorer.exe .
    )
) else (
    call :Error
    echo �밴���س�����skins�ļ���......&pause>nul
    cd /d "%SteamPath%\steamui\skins"
    start explorer.exe .
)
ping 127.0.0.1 -n 1 > nul
del "%~f0"