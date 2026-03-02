@echo off
chcp 65001 >nul
title 黄金投资助手 - 安装程序

echo ========================================
echo   🪙 黄金投资助手 - Windows 安装程序
echo ========================================
echo.

REM 检查 Python
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 未检测到 Python
    echo.
    echo 📥 请先安装 Python 3.8 或更高版本:
    echo    https://www.python.org/downloads/
    echo.
    echo ⚠️  安装时请勾选 "Add Python to PATH"
    echo.
    pause
    exit /b 1
)

echo ✅ Python 已安装
python --version
echo.

REM 设置安装目录
set "INSTALL_DIR=%USERPROFILE%\.gold_investor"
set "GITHUB_RAW=https://raw.githubusercontent.com/narutozhu442/gold-investor/main"

echo 📁 安装目录: %INSTALL_DIR%
echo.

REM 创建目录
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
if not exist "%INSTALL_DIR%\scripts" mkdir "%INSTALL_DIR%\scripts"

REM 下载程序
echo ⬇️  下载程序...

curl -fsSL "%GITHUB_RAW%/gui/gold_investor_gui.py" -o "%INSTALL_DIR%\gold_investor_gui.py"
if errorlevel 1 (
    echo ❌ 下载失败，请检查网络连接
    pause
    exit /b 1
)

echo ✅ 主程序下载完成

REM 创建启动脚本
echo 📝 创建启动脚本...
(
echo @echo off
echo chcp 65001 ^>nul
echo cd /d "%INSTALL_DIR%"
echo python gold_investor_gui.py
echo pause
) > "%INSTALL_DIR%\启动.bat"

REM 创建桌面快捷方式
echo 🖥️  创建桌面快捷方式...

set "DESKTOP=%USERPROFILE%\Desktop"
set "SHORTCUT=%DESKTOP%\黄金投资助手.lnk"

REM 使用 PowerShell 创建快捷方式
powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%SHORTCUT%'); $Shortcut.TargetPath = '%INSTALL_DIR%\启动.bat'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.IconLocation = '%SystemRoot%\System32\shell32.dll,13'; $Shortcut.Save()"

echo ✅ 桌面快捷方式已创建

REM 添加到 PATH（可选）
echo.
set /p ADD_PATH="是否添加到系统PATH? (y/n): "
if /i "%ADD_PATH%"=="y" (
    setx PATH "%PATH%;%INSTALL_DIR%" /M >nul 2>&1
    if errorlevel 1 (
        echo ⚠️  需要管理员权限，跳过
    ) else (
        echo ✅ 已添加到 PATH
    )
)

echo.
echo ========================================
echo   ✅ 安装完成!
echo ========================================
echo.
echo 🚀 启动方式:
echo    1. 双击桌面"黄金投资助手"图标
echo    2. 运行: %INSTALL_DIR%\启动.bat
echo.
echo ⚙️  配置文件: %INSTALL_DIR%\config.json
echo.
echo 📝 使用说明:
echo    1. 填写成本价和持仓量
echo    2. 点击"刷新价格"获取实时金价
echo    3. 点击"分析盈亏"查看收益
echo.

REM 询问是否立即启动
echo.
set /p LAUNCH="是否立即启动程序? (y/n): "
if /i "%LAUNCH%"=="y" (
    echo.
    echo 🚀 启动中...
    start "" "%INSTALL_DIR%\启动.bat"
)

echo.
echo 感谢使用黄金投资助手! 🪙
echo.
pause
