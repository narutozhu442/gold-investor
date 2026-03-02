#!/bin/bash
# 黄金投资助手 - 一键安装脚本
# 支持：Linux / macOS

echo "========================================"
echo "  🪙 黄金投资助手 - 安装程序"
echo "========================================"
echo ""

# 检查系统
OS=$(uname -s)
echo "检测到系统: $OS"

# 创建安装目录
INSTALL_DIR="$HOME/.gold_investor"
mkdir -p "$INSTALL_DIR"

echo ""
echo "📁 安装目录: $INSTALL_DIR"
echo ""

# 下载程序
echo "⬇️  下载程序..."

# 使用 GitHub 原始文件
GITHUB_RAW="https://raw.githubusercontent.com/narutozhu442/gold-investor/main"

# 下载 GUI 程序
curl -fsSL "$GITHUB_RAW/gui/gold_investor_gui.py" -o "$INSTALL_DIR/gold_investor_gui.py" 2>/dev/null

if [ $? -ne 0 ]; then
    echo "❌ 下载失败，请检查网络连接"
    exit 1
fi

# 下载启动脚本
cat > "$INSTALL_DIR/launch.sh" << 'EOF'
#!/bin/bash
cd "$HOME/.gold_investor"
python3 gold_investor_gui.py &
EOF

chmod +x "$INSTALL_DIR/launch.sh"

# 创建桌面快捷方式
if [ "$OS" = "Darwin" ]; then
    # macOS
    DESKTOP_DIR="$HOME/Desktop"
    cat > "$DESKTOP_DIR/黄金投资助手.command" << EOF
#!/bin/bash
cd "$INSTALL_DIR"
python3 gold_investor_gui.py
EOF
    chmod +x "$DESKTOP_DIR/黄金投资助手.command"
    echo "🖥️  已创建桌面快捷方式: ~/Desktop/黄金投资助手.command"
else
    # Linux
    DESKTOP_DIR="$HOME/Desktop"
    cat > "$DESKTOP_DIR/gold-investor.desktop" << EOF
[Desktop Entry]
Name=黄金投资助手
Comment=黄金投资监控工具
Exec=python3 $INSTALL_DIR/gold_investor_gui.py
Icon=applications-accessories
Terminal=false
Type=Application
Categories=Office;Finance;
EOF
    chmod +x "$DESKTOP_DIR/gold-investor.desktop"
    echo "🖥️  已创建桌面快捷方式: ~/Desktop/gold-investor.desktop"
fi

# 创建命令行快捷方式
if [ -d "$HOME/.local/bin" ]; then
    cat > "$HOME/.local/bin/gold-investor" << EOF
#!/bin/bash
python3 $INSTALL_DIR/gold_investor_gui.py
EOF
    chmod +x "$HOME/.local/bin/gold-investor"
    echo "⌨️  已创建命令: gold-investor"
fi

echo ""
echo "========================================"
echo "  ✅ 安装完成!"
echo "========================================"
echo ""
echo "🚀 启动方式:"
echo "   1. 双击桌面快捷方式"
echo "   2. 终端运行: $INSTALL_DIR/launch.sh"
echo ""
echo "⚙️  配置文件: ~/.gold_investor/config.json"
echo ""
echo "📝 使用说明:"
echo "   1. 填写成本价和持仓量"
echo "   2. 点击'刷新价格'获取实时金价"
echo "   3. 点击'分析盈亏'查看收益"
echo ""

# 检查 Python
if ! command -v python3 &> /dev/null; then
    echo "⚠️  警告: 未检测到 Python3，请安装后使用"
    echo "   macOS: brew install python3"
    echo "   Ubuntu/Debian: sudo apt install python3 python3-tk"
    echo "   CentOS/RHEL: sudo yum install python3 tkinter"
else
    echo "🐍 Python3 已安装: $(python3 --version)"
    
    # 检查 tkinter
    if python3 -c "import tkinter" 2>/dev/null; then
        echo "✅ tkinter 已安装"
        
        # 询问是否立即启动
        echo ""
        read -p "是否立即启动程序? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "🚀 启动中..."
            python3 "$INSTALL_DIR/gold_investor_gui.py" &
        fi
    else
        echo "⚠️  缺少 tkinter 模块，请安装:"
        echo "   macOS: brew install python-tk"
        echo "   Ubuntu/Debian: sudo apt install python3-tk"
        echo "   CentOS/RHEL: sudo yum install python3-tkinter"
    fi
fi

echo ""
echo "感谢使用黄金投资助手! 🪙"
echo ""
