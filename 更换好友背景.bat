<# :
@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title 一键替换好友列表背景脚本

:: 1. 获取当前脚本所在绝对目录
set "SCRIPT_DIR=%~dp0"

:: 2. 判断是否有文件拖入到图标上
if not "%~1"=="" goto :GotFile
echo [提示] 请将需要替换的图片文件拖入此窗口，然后按回车键。
echo.
echo 支持的图片格式: .jpg, .jpeg, .png
echo.
set /p "SOURCE_FILE="
for /f "delims=" %%A in ("%SOURCE_FILE%") do set "SOURCE_FILE=%%~A"
goto :FileReady
:GotFile
set "SOURCE_FILE=%~1"
:FileReady

:: 3. 提取文件信息并设为环境变量
for %%F in ("%SOURCE_FILE%") do set "FILE_EXT=%%~xF"
set "CSS_FILE=%SCRIPT_DIR%friends.custom.css"

:: 4. 检查文件类型
set "IS_VALID=0"
if /I "%FILE_EXT%"==".jpg" set "IS_VALID=1"
if /I "%FILE_EXT%"==".jpeg" set "IS_VALID=1"
if /I "%FILE_EXT%"==".png" set "IS_VALID=1"

if "!IS_VALID!"=="0" (
    echo [错误] 不支持的文件格式: %FILE_EXT%
    echo 仅支持 .jpg, .jpeg, .png
    pause
    exit /b
)

:: 5. 智能清理与复制
echo.
echo [状态] 检测到图片文件，正在清理旧的 friends 格式文件...

:: 安全清理：遍历可能的后缀，只要它不是你正在拖入的文件本身，就删掉它
for %%x in (jpg jpeg png) do (
    if /I not "%SOURCE_FILE%"=="%SCRIPT_DIR%friends.%%x" (
        if exist "%SCRIPT_DIR%friends.%%x" del /f /q "%SCRIPT_DIR%friends.%%x"
    )
)

echo [状态] 正在复制新图片...
:: 避免同目录拖拽产生“不能覆盖自身”的报错
if /I not "%SOURCE_FILE%"=="%SCRIPT_DIR%friends%FILE_EXT%" (
    copy /y "%SOURCE_FILE%" "%SCRIPT_DIR%friends%FILE_EXT%" >nul
)

:: 6. 无缝调用下方的 PowerShell 核心代码处理 CSS 后缀
powershell -NoProfile -ExecutionPolicy Bypass "Invoke-Command -ScriptBlock ([Scriptblock]::Create((Get-Content -LiteralPath '%~f0' -Encoding UTF8 -Raw)))"

pause
exit /b
#>

# =========================================================
# 下方为 PowerShell 脚本核心部分 (自动处理正则与 UTF-8 编码)
# =========================================================
$cssFile = $env:CSS_FILE
$ext = $env:FILE_EXT

# 设置保存时的编码为 UTF-8 (无 BOM)
$utf8NoBom = New-Object System.Text.UTF8Encoding $false

if (Test-Path -LiteralPath $cssFile) {
    Write-Host "- 正在安全修改 CSS 文件中的图片后缀..." -ForegroundColor Cyan
    
    # 强制以 UTF-8 格式读取，保护中文注释不乱码
    $txt = Get-Content -LiteralPath $cssFile -Encoding UTF8 -Raw
    
    # 正则替换：将 friends.jpg / friends.png 等替换为新的后缀
    $txt = $txt -replace 'friends\.(jpg|jpeg|png)', ("friends" + $ext)
    
    [System.IO.File]::WriteAllText($cssFile, $txt, $utf8NoBom)
    Write-Host "[成功] 好友背景替换完成！旧的 friends 图片已全部清理。" -ForegroundColor Green
} else {
    Write-Host "[错误] 当前目录下找不到 friends.custom.css ！" -ForegroundColor Red
}