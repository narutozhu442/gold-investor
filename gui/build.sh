#!/bin/bash
# 打包黄金投资助手为可执行文件
# 支持 Windows (.exe) / Mac (.app) / Linux

echo "========================================"
echo "  黄金投资助手 - 打包工具"
echo "========================================"
echo ""

# 检查 Python
if ! command -v python3 &> /dev/null; then
    echo "错误: 未找到 Python3，请先安装"
    exit 1
fi

# 检查 pip
if ! command -v pip3 &> /dev/null; then
    echo "错误: 未找到 pip3"
    exit 1
fi

# 安装依赖
echo "📦 安装依赖..."
pip3 install pyinstaller requests -q

# 进入 GUI 目录
cd "$(dirname "$0")"

# 打包
echo "🔨 开始打包..."
pyinstaller \
    --onefile \
    --windowed \
    --name "GoldInvestor" \
    --icon "icon.ico" \
    --add-data "icon.ico;." \
    --clean \
    gold_investor_gui.py

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo "  ✅ 打包成功!"
    echo "========================================"
    echo ""
    echo "📁 可执行文件位置:"
    echo "   dist/GoldInvestor"
    echo ""
    echo "🚀 运行方式:"
    echo "   ./dist/GoldInvestor"
    echo ""
else
    echo "❌ 打包失败"
    exit 1
fi
