@echo off
chcp 65001 >nul
echo ========================================
echo   黄金投资助手 - Windows 打包工具
echo ========================================
echo.

REM 检查 Python
python --version >nul 2>&1
if errorlevel 1 (
    echo 错误: 未找到 Python，请先安装
    pause
    exit /b 1
)

REM 安装依赖
echo 📦 安装依赖...
pip install pyinstaller requests -q

REM 下载图标（如果没有）
if not exist "icon.ico" (
    echo 🎨 创建默认图标...
    copy nul icon.ico >nul
)

REM 打包
echo 🔨 开始打包...
pyinstaller ^
    --onefile ^
    --windowed ^
    --name "黄金投资助手" ^
    --icon "icon.ico" ^
    --clean ^
    gold_investor_gui.py

if %errorlevel% == 0 (
    echo.
    echo ========================================
    echo   ✅ 打包成功!
    echo ========================================
    echo.
    echo 📁 可执行文件位置:
    echo    dist\黄金投资助手.exe
    echo.
    echo 🚀 运行方式:
    echo    双击 dist\黄金投资助手.exe 运行
    echo.
    echo 📦 分发方式:
    echo    将 dist\黄金投资助手.exe 发送给用户即可
    echo.
    pause
) else (
    echo ❌ 打包失败
    pause
    exit /b 1
)
