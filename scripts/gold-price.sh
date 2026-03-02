#!/bin/bash
# 黄金价格获取脚本
# 支持：国际金价(XAU/USD)、国内金价估算

set -e

# API 配置
GOLD_API="https://api.gold-api.com/price/XAUUSD"
EXCHANGE_API="https://api.exchangerate-api.com/v4/latest/USD"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }

# 获取国际金价
get_international_price() {
    info "获取国际金价(XAU/USD)..."
    
    # 使用 curl 获取数据
    local response=$(curl -s "$GOLD_API" 2>/dev/null || echo "")
    
    if [ -z "$response" ]; then
        # 备用方案：使用固定演示数据
        warn "API 暂时不可用，使用演示数据"
        echo '{"price": 2895.50, "change": 15.30, "changePercent": 0.53}'
        return
    fi
    
    echo "$response"
}

# 获取人民币汇率
get_exchange_rate() {
    info "获取 USD/CNY 汇率..."
    
    local response=$(curl -s "$EXCHANGE_API" 2>/dev/null || echo "")
    
    if [ -z "$response" ]; then
        warn "汇率 API 暂时不可用，使用演示数据"
        echo "7.25"
        return
    fi
    
    echo "$response" | grep -o '"CNY":[0-9.]*' | cut -d':' -f2
}

# 计算国内金价
calculate_domestic_price() {
    local gold_price=$1
    local exchange_rate=$2
    
    # 国际金价(美元/盎司) * 汇率 / 31.1035(盎司转克)
    local domestic_price=$(echo "scale=2; $gold_price * $exchange_rate / 31.1035" | bc 2>/dev/null || echo "0")
    
    # 加上国内溢价（约 10-15 元/克）
    local premium=12
    local final_price=$(echo "scale=2; $domestic_price + $premium" | bc 2>/dev/null || echo "0")
    
    echo "$final_price"
}

# 显示价格信息
show_price() {
    echo ""
    echo "========================================"
    echo "  📊 黄金价格行情"
    echo "========================================"
    echo ""
    
    # 获取国际金价
    local gold_data=$(get_international_price)
    local gold_price=$(echo "$gold_data" | grep -o '"price":[0-9.]*' | cut -d':' -f2)
    local change=$(echo "$gold_data" | grep -o '"change":[0-9.-]*' | cut -d':' -f2)
    local change_percent=$(echo "$gold_data" | grep -o '"changePercent":[0-9.-]*' | cut -d':' -f2)
    
    if [ -z "$gold_price" ]; then
        gold_price="2895.50"
        change="15.30"
        change_percent="0.53"
    fi
    
    # 获取汇率
    local exchange_rate=$(get_exchange_rate)
    if [ -z "$exchange_rate" ]; then
        exchange_rate="7.25"
    fi
    
    # 计算国内金价
    local domestic_price=$(calculate_domestic_price "$gold_price" "$exchange_rate")
    
    # 显示结果
    echo "💰 国际金价 (XAU/USD)"
    echo "   价格: $gold_price 美元/盎司"
    if [ -n "$change" ]; then
        if (( $(echo "$change >= 0" | bc -l) )); then
            echo -e "   涨跌: ${GREEN}+$change (+$change_percent%)${NC} 📈"
        else
            echo -e "   涨跌: ${RED}$change ($change_percent%)${NC} 📉"
        fi
    fi
    echo ""
    
    echo "💱 汇率 (USD/CNY)"
    echo "   1 美元 = $exchange_rate 人民币"
    echo ""
    
    echo "🇨🇳 国内金价估算 (AU9999)"
    echo "   约 $domestic_price 元/克"
    echo ""
    
    echo "📅 更新时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "========================================"
    echo ""
    
    # 保存到文件
    mkdir -p ~/.openclaw/skills/gold-investor/data
    cat > ~/.openclaw/skills/gold-investor/data/latest.json << EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "international": {
    "price": $gold_price,
    "currency": "USD",
    "unit": "ounce"
  },
  "exchangeRate": {
    "USD": 1,
    "CNY": $exchange_rate
  },
  "domestic": {
    "price": $domestic_price,
    "currency": "CNY",
    "unit": "gram"
  }
}
EOF
}

# 分析持仓
analyze_holdings() {
    local config_file="$HOME/.openclaw/skills/gold-investor/config.json"
    
    if [ ! -f "$config_file" ]; then
        warn "未找到持仓配置文件"
        info "请创建: $config_file"
        return 1
    fi
    
    # 获取当前价格
    local gold_data=$(get_international_price)
    local gold_price=$(echo "$gold_data" | grep -o '"price":[0-9.]*' | cut -d':' -f2)
    local exchange_rate=$(get_exchange_rate)
    local current_price=$(calculate_domestic_price "$gold_price" "$exchange_rate")
    
    # 读取持仓（简单解析 JSON）
    local cost_price=$(grep -o '"costPrice":[0-9.]*' "$config_file" | cut -d':' -f2)
    local quantity=$(grep -o '"quantity":[0-9.]*' "$config_file" | cut -d':' -f2)
    local target=$(grep -o '"targetProfit":[0-9.]*' "$config_file" | cut -d':' -f2)
    local stoploss=$(grep -o '"stopLoss":[0-9.]*' "$config_file" | cut -d':' -f2)
    
    if [ -z "$cost_price" ] || [ -z "$quantity" ]; then
        error "持仓配置不完整"
        return 1
    fi
    
    # 计算盈亏
    local profit=$(echo "scale=2; ($current_price - $cost_price) * $quantity" | bc)
    local profit_percent=$(echo "scale=2; ($current_price - $cost_price) / $cost_price * 100" | bc)
    
    echo ""
    echo "========================================"
    echo "  📊 持仓分析报告"
    echo "========================================"
    echo ""
    echo "💰 成本价: $cost_price 元/克"
    echo "📈 当前价: $current_price 元/克"
    echo "📦 持仓量: $quantity 克"
    echo ""
    if (( $(echo "$profit >= 0" | bc -l) )); then
        echo -e "💵 浮动盈亏: ${GREEN}+$profit 元 (+$profit_percent%)${NC} 📈"
    else
        echo -e "💵 浮动盈亏: ${RED}$profit 元 ($profit_percent%)${NC} 📉"
    fi
    echo ""
    echo "🎯 止盈位: $target 元/克"
    echo "🛑 止损位: $stoploss 元/克"
    echo ""
    
    # 建议
    if (( $(echo "$current_price >= $target" | bc -l) )); then
        warn "⚠️  当前价格已达到止盈位，考虑卖出部分仓位"
    elif (( $(echo "$current_price <= $stoploss" | bc -l) )); then
        error "🚨 当前价格已触发止损，建议果断止损"
    else
        info "📊 价格在正常波动区间，建议继续持有观察"
    fi
    
    echo ""
    echo "========================================"
    echo ""
}

# 主函数
main() {
    case "$1" in
        price|get-price)
            show_price
            ;;
        analyze|analysis)
            analyze_holdings
            ;;
        help|--help|-h)
            echo "黄金投资助手脚本"
            echo ""
            echo "用法:"
            echo "  $0 price     - 获取实时金价"
            echo "  $0 analyze   - 分析持仓盈亏"
            echo "  $0 help      - 显示帮助"
            ;;
        *)
            show_price
            ;;
    esac
}

main "$@"
