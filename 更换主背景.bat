<# :
@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title 一键替换主背景脚本 (图片+视频版)

:: 1. 获取当前脚本所在绝对目录
set "SCRIPT_DIR=%~dp0"

:: 2. 判断是否有文件拖入到图标上
if not "%~1"=="" goto :GotFile
echo [提示] 请将需要替换的图片或视频文件拖入此窗口，然后按回车键。
echo.
echo 支持的图片格式: .jpg, .jpeg, .png
echo 支持的视频格式: .webm
echo.
set /p "SOURCE_FILE="
for /f "delims=" %%A in ("%SOURCE_FILE%") do set "SOURCE_FILE=%%~A"
goto :FileReady
:GotFile
set "SOURCE_FILE=%~1"
:FileReady

:: 3. 提取文件信息并设为环境变量
for %%F in ("%SOURCE_FILE%") do set "FILE_EXT=%%~xF"
set "CSS_FILE=%SCRIPT_DIR%libraryroot.custom.css"

:: 4. 检查文件类型并定义模式
set "MODE="
if /I "%FILE_EXT%"==".jpg" set "MODE=IMAGE"
if /I "%FILE_EXT%"==".jpeg" set "MODE=IMAGE"
if /I "%FILE_EXT%"==".png" set "MODE=IMAGE"
if /I "%FILE_EXT%"==".webm" set "MODE=VIDEO"

if not defined MODE (
    echo [错误] 不支持的文件格式: %FILE_EXT%
    echo 仅支持 .jpg, .jpeg, .png 和 .webm
    pause
    exit /b
)

:: 5. 提前获取 Steam 安装路径 (图片需要删视频，视频需要复制)
set "SteamPath="
FOR /F "tokens=2* skip=2" %%a in ('reg query "HKCU\Software\Valve\Steam" /v "SteamPath" 2^>nul') do set "SteamPath=%%b"
:: 修正 Valve 注册表路径中的正斜杠为反斜杠，防止 CMD 报错
set "SteamPath=!SteamPath:/=\!"

:: 6. 扁平化路由跳转，彻底杜绝 CMD 括号嵌套引起的闪退
if "!MODE!"=="IMAGE" goto ProcessImage
if "!MODE!"=="VIDEO" goto ProcessVideo

:: =======================================
:: 图片处理模块
:: =======================================
:ProcessImage
echo [状态] 检测到图片文件，正在清理旧的 main 格式文件...

:: 清理当前目录旧图
for %%x in (jpg jpeg png webm) do (
    if /I not "%SOURCE_FILE%"=="%SCRIPT_DIR%main.%%x" (
        if exist "%SCRIPT_DIR%main.%%x" del /f /q "%SCRIPT_DIR%main.%%x"
    )
)

:: 【清理 SteamUI 视频】
if defined SteamPath (
    if exist "!SteamPath!\steamui\main.webm" (
        echo [状态] 正在删除 steamui 目录中的残余视频 main.webm...
        del /f /q "!SteamPath!\steamui\main.webm"
    )
)

echo [状态] 正在复制新图片...
if /I not "%SOURCE_FILE%"=="%SCRIPT_DIR%main%FILE_EXT%" (
    copy /y "%SOURCE_FILE%" "%SCRIPT_DIR%main%FILE_EXT%" >nul
)

:: 调用 PowerShell 代码修改 CSS
powershell -NoProfile -ExecutionPolicy Bypass "Invoke-Command -ScriptBlock ([Scriptblock]::Create((Get-Content -LiteralPath '%~f0' -Encoding UTF8 -Raw)))"
pause
exit /b

:: =======================================
:: 视频处理模块
:: =======================================
:ProcessVideo
echo [状态] 检测到视频文件，正在处理...

if not exist "!SteamPath!" (
    echo [错误] 找不到 Steam 路径！请确认 Steam 是否已正常安装。
    echo 尝试读取的路径: !SteamPath!
    echo.
    echo 可将webm视频文件重命名为main并手动复制到steam/steamui
    echo 请按任意键继续......
    pause >nul
    exit /b
)

echo [状态] 成功获取 Steam 路径: !SteamPath!

:: 确保 steamui 文件夹存在 (正常情况下都会存在)
if not exist "!SteamPath!\steamui" mkdir "!SteamPath!\steamui"

echo [状态] 正在复制视频至 steamui 目录并重命名为 main.webm...
copy /y "%SOURCE_FILE%" "!SteamPath!\steamui\main.webm" >nul

echo [成功] 视频已成功复制并覆盖至 SteamUI 目录！
pause
exit /b
#>

# =========================================================
# 下方为 PowerShell 脚本核心部分 (仅处理图片的 CSS 修改)
# =========================================================
$cssFile = $env:CSS_FILE
$ext = $env:FILE_EXT

# 设置保存时的编码为 UTF-8 (无 BOM)
$utf8NoBom = New-Object System.Text.UTF8Encoding $false

if (Test-Path -LiteralPath $cssFile) {
    Write-Host "- 正在安全修改 CSS 文件中的图片后缀..." -ForegroundColor Cyan
    
    $txt = Get-Content -LiteralPath $cssFile -Encoding UTF8 -Raw
    $txt = $txt -replace 'main\.(jpg|jpeg|png)', ("main" + $ext)
    
    [System.IO.File]::WriteAllText($cssFile, $txt, $utf8NoBom)
    Write-Host "[成功] 图片背景替换完成！旧的 main 背景已全部清理。" -ForegroundColor Green
} else {
    Write-Host "[错误] 当前目录下找不到 libraryroot.custom.css ！" -ForegroundColor Red
}