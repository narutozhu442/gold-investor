# 🪙 黄金投资助手 (Gold Investor)

> OpenClaw Skill - 专业的黄金投资监控和分析工具

[![OpenClaw](https://img.shields.io/badge/Powered%20by-OpenClaw-orange)](https://openclaw.ai)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## ✨ 功能

- 📊 **实时金价** - 国际金价(XAU/USD)、国内金价(AU9999)
- 💱 **汇率监控** - USD/CNY 实时汇率
- 📈 **涨跌提醒** - 价格变动超过阈值自动通知
- 💰 **持仓分析** - 自动计算盈亏、对比止盈止损
- 📰 **市场动态** - 地缘冲突、美联储政策影响分析

## 🚀 快速开始

### 1. 安装 Skill

```bash
# 克隆到 OpenClaw skills 目录
git clone https://github.com/narutozhu442/gold-investor.git ~/.openclaw/skills/gold-investor
```

### 2. 配置持仓

创建配置文件 `~/.openclaw/skills/gold-investor/config.json`：

```json
{
  "holdings": {
    "type": "纸黄金",
    "costPrice": 480.5,
    "quantity": 10,
    "targetProfit": 520.0,
    "stopLoss": 460.0
  },
  "alert": {
    "enabled": true,
    "threshold": 2.0
  }
}
```

### 3. 开始使用

```bash
# 查询实时金价
~/.openclaw/skills/gold-investor/scripts/gold-price.sh price

# 分析持仓盈亏
~/.openclaw/skills/gold-investor/scripts/gold-price.sh analyze
```

## 📊 使用效果

```
========================================
  📊 黄金价格行情
========================================

💰 国际金价 (XAU/USD)
   价格: 2895.50 美元/盎司
   涨跌: +15.30 (+0.53%) 📈

💱 汇率 (USD/CNY)
   1 美元 = 7.25 人民币

🇨🇳 国内金价估算 (AU9999)
   约 687.42 元/克

📅 更新时间: 2026-03-02 21:30:00
========================================
```

## 🔧 高级用法

### 设置定时监控

添加到 crontab：
```bash
# 每小时检查一次
0 * * * * ~/.openclaw/skills/gold-investor/scripts/gold-price.sh price >> ~/gold-price.log 2>&1
```

### 结合 OpenClaw 使用

在 OpenClaw 中直接调用：
```
帮我查看今天的金价
分析一下我的黄金持仓
金价涨跌超过2%时提醒我
```

## 📁 文件结构

```
gold-investor/
├── SKILL.md                 # Skill 文档
├── README.md                # 本文件
├── scripts/
│   └── gold-price.sh        # 金价获取脚本
└── config.json              # 持仓配置（用户创建）
```

## ⚠️ 免责声明

**投资有风险，本工具仅供参考，不构成投资建议。**

## 🤝 贡献

欢迎提交 Issue 和 PR！

## 📜 License

MIT License

---

⭐ 如果本项目帮到你，请点个 Star！
