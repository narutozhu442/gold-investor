# 黄金投资助手 - 桌面版打包指南

## 快速开始

### Windows 用户

#### 方法一：直接下载（推荐）
1. 从 [Releases](https://github.com/narutozhu442/gold-investor/releases) 下载 `黄金投资助手.exe`
2. 双击运行，无需安装

#### 方法二：自行打包
```batch
# 克隆仓库
git clone https://github.com/narutozhu442/gold-investor.git
cd gold-investor/gui

# 运行打包脚本
build.bat

# 打包完成后，在 dist 目录找到 黄金投资助手.exe
```

### Mac 用户

```bash
# 克隆仓库
git clone https://github.com/narutozhu442/gold-investor.git
cd gold-investor/gui

# 运行打包脚本
bash build.sh

# 打包完成后，在 dist 目录找到 GoldInvestor
# 可以将其移动到应用程序文件夹
```

### Linux 用户

```bash
# 克隆仓库
git clone https://github.com/narutozhu442/gold-investor.git
cd gold-investor/gui

# 运行打包脚本
bash build.sh

# 运行程序
./dist/GoldInvestor
```

## 开发环境要求

- Python 3.8+
- tkinter（Python 自带）
- pyinstaller
- requests

## 安装依赖

```bash
pip install pyinstaller requests
```

## 打包配置

### Windows (单文件 EXE)

```bash
pyinstaller \
    --onefile \
    --windowed \
    --name "黄金投资助手" \
    --icon "icon.ico" \
    gold_investor_gui.py
```

### Mac (App Bundle)

```bash
pyinstaller \
    --onefile \
    --windowed \
    --name "GoldInvestor" \
    --icon "icon.icns" \
    gold_investor_gui.py
```

### 参数说明

- `--onefile`: 打包成单个文件
- `--windowed`: 不显示命令行窗口（GUI应用）
- `--name`: 输出文件名
- `--icon`: 应用图标
- `--clean`: 清理临时文件

## 分发

打包完成后：

### Windows
- 文件：`dist/黄金投资助手.exe`
- 大小：约 15-20 MB
- 用户只需这一个文件即可运行

### Mac
- 文件：`dist/GoldInvestor`
- 可以打包成 `.app` 或 `.dmg`

### Linux
- 文件：`dist/GoldInvestor`
- 需要确保用户有执行权限：`chmod +x GoldInvestor`

## 自动更新

未来版本将支持自动更新：
1. 程序启动时检查 GitHub Releases
2. 有新版本时提示用户
3. 一键下载并替换

## 常见问题

### Q: 运行提示缺少 DLL？
A: Windows 用户需要安装 [Visual C++ Redistributable](https://aka.ms/vs/17/release/vc_redist.x64.exe)

### Q: Mac 提示"无法打开，因为无法验证开发者"？
A: 前往 系统偏好设置 → 安全性与隐私 → 允许从以下位置下载的App → 仍要打开

### Q: 如何修改默认配置？
A: 编辑 `~/.gold_investor/config.json` 文件

## 许可证

MIT License
