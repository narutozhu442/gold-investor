#!/usr/bin/env python3
"""
黄金投资助手 - 桌面版
Gold Investor Desktop App
打包命令: pyinstaller --onefile --windowed gold_investor_gui.py
"""

import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
import subprocess
import json
import os
import threading
import time
from datetime import datetime

class GoldInvestorApp:
    def __init__(self, root):
        self.root = root
        self.root.title("黄金投资助手 🪙")
        self.root.geometry("600x700")
        self.root.resizable(False, False)
        
        # 配置文件路径
        self.config_dir = os.path.expanduser("~/.gold_investor")
        self.config_file = os.path.join(self.config_dir, "config.json")
        self.data_file = os.path.join(self.config_dir, "data.json")
        
        # 确保目录存在
        os.makedirs(self.config_dir, exist_ok=True)
        
        # 创建界面
        self.create_widgets()
        
        # 加载配置
        self.load_config()
        
        # 自动刷新
        self.auto_refresh()
    
    def create_widgets(self):
        # 标题
        title = tk.Label(self.root, text="黄金投资助手", font=("微软雅黑", 20, "bold"))
        title.pack(pady=10)
        
        # 实时价格区域
        price_frame = tk.LabelFrame(self.root, text="实时行情", font=("微软雅黑", 12))
        price_frame.pack(fill="x", padx=20, pady=10)
        
        self.intl_price_var = tk.StringVar(value="获取中...")
        self.intl_change_var = tk.StringVar(value="")
        self.exchange_var = tk.StringVar(value="")
        self.domestic_var = tk.StringVar(value="")
        
        tk.Label(price_frame, text="国际金价:", font=("微软雅黑", 11)).grid(row=0, column=0, sticky="w", padx=10, pady=5)
        tk.Label(price_frame, textvariable=self.intl_price_var, font=("微软雅黑", 11, "bold")).grid(row=0, column=1, sticky="w", padx=10, pady=5)
        tk.Label(price_frame, textvariable=self.intl_change_var, font=("微软雅黑", 10)).grid(row=0, column=2, sticky="w", padx=10, pady=5)
        
        tk.Label(price_frame, text="汇率:", font=("微软雅黑", 11)).grid(row=1, column=0, sticky="w", padx=10, pady=5)
        tk.Label(price_frame, textvariable=self.exchange_var, font=("微软雅黑", 11)).grid(row=1, column=1, sticky="w", padx=10, pady=5)
        
        tk.Label(price_frame, text="国内金价:", font=("微软雅黑", 11)).grid(row=2, column=0, sticky="w", padx=10, pady=5)
        tk.Label(price_frame, textvariable=self.domestic_var, font=("微软雅黑", 14, "bold"), fg="gold").grid(row=2, column=1, sticky="w", padx=10, pady=5)
        
        # 持仓配置区域
        hold_frame = tk.LabelFrame(self.root, text="持仓配置", font=("微软雅黑", 12))
        hold_frame.pack(fill="x", padx=20, pady=10)
        
        tk.Label(hold_frame, text="成本价(元/克):").grid(row=0, column=0, sticky="w", padx=10, pady=5)
        self.cost_entry = tk.Entry(hold_frame, width=15)
        self.cost_entry.grid(row=0, column=1, padx=10, pady=5)
        
        tk.Label(hold_frame, text="持仓量(克):").grid(row=1, column=0, sticky="w", padx=10, pady=5)
        self.qty_entry = tk.Entry(hold_frame, width=15)
        self.qty_entry.grid(row=1, column=1, padx=10, pady=5)
        
        tk.Label(hold_frame, text="止盈价(元/克):").grid(row=2, column=0, sticky="w", padx=10, pady=5)
        self.target_entry = tk.Entry(hold_frame, width=15)
        self.target_entry.grid(row=2, column=1, padx=10, pady=5)
        
        tk.Label(hold_frame, text="止损价(元/克):").grid(row=3, column=0, sticky="w", padx=10, pady=5)
        self.stop_entry = tk.Entry(hold_frame, width=15)
        self.stop_entry.grid(row=3, column=1, padx=10, pady=5)
        
        # 保存按钮
        tk.Button(hold_frame, text="保存配置", command=self.save_config, bg="#4CAF50", fg="white", font=("微软雅黑", 10)).grid(row=4, column=0, columnspan=2, pady=10)
        
        # 盈亏分析区域
        pnl_frame = tk.LabelFrame(self.root, text="盈亏分析", font=("微软雅黑", 12))
        pnl_frame.pack(fill="x", padx=20, pady=10)
        
        self.pnl_var = tk.StringVar(value="点击分析按钮计算盈亏")
        self.pnl_label = tk.Label(pnl_frame, textvariable=self.pnl_var, font=("微软雅黑", 12))
        self.pnl_label.pack(pady=10)
        
        # 操作按钮
        btn_frame = tk.Frame(self.root)
        btn_frame.pack(fill="x", padx=20, pady=10)
        
        tk.Button(btn_frame, text="🔄 刷新价格", command=self.refresh_price, bg="#2196F3", fg="white", font=("微软雅黑", 11), width=12).pack(side="left", padx=5)
        tk.Button(btn_frame, text="📊 分析盈亏", command=self.analyze_pnl, bg="#FF9800", fg="white", font=("微软雅黑", 11), width=12).pack(side="left", padx=5)
        tk.Button(btn_frame, text="📋 查看记录", command=self.show_history, bg="#9C27B0", fg="white", font=("微软雅黑", 11), width=12).pack(side="left", padx=5)
        
        # 状态栏
        self.status_var = tk.StringVar(value="就绪")
        status_bar = tk.Label(self.root, textvariable=self.status_var, bd=1, relief="sunken", anchor="w")
        status_bar.pack(side="bottom", fill="x")
        
        # 更新时间
        self.update_time_var = tk.StringVar(value="")
        tk.Label(self.root, textvariable=self.update_time_var, font=("微软雅黑", 9), fg="gray").pack(side="bottom", pady=5)
    
    def load_config(self):
        """加载配置"""
        if os.path.exists(self.config_file):
            try:
                with open(self.config_file, 'r') as f:
                    config = json.load(f)
                self.cost_entry.insert(0, str(config.get("cost_price", "")))
                self.qty_entry.insert(0, str(config.get("quantity", "")))
                self.target_entry.insert(0, str(config.get("target", "")))
                self.stop_entry.insert(0, str(config.get("stop_loss", "")))
            except:
                pass
    
    def save_config(self):
        """保存配置"""
        try:
            config = {
                "cost_price": float(self.cost_entry.get() or 0),
                "quantity": float(self.qty_entry.get() or 0),
                "target": float(self.target_entry.get() or 0),
                "stop_loss": float(self.stop_entry.get() or 0)
            }
            with open(self.config_file, 'w') as f:
                json.dump(config, f, indent=2)
            messagebox.showinfo("成功", "配置已保存！")
        except ValueError:
            messagebox.showerror("错误", "请输入有效的数字！")
    
    def fetch_price(self):
        """获取价格数据"""
        try:
            # 模拟数据（实际应该调用API）
            import random
            base_price = 2895.50
            change = random.uniform(-20, 20)
            current_price = base_price + change
            change_percent = (change / base_price) * 100
            exchange_rate = 7.25
            
            # 计算国内金价
            domestic = (current_price * exchange_rate / 31.1035) + 12
            
            return {
                "intl_price": current_price,
                "change": change,
                "change_percent": change_percent,
                "exchange": exchange_rate,
                "domestic": domestic,
                "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            }
        except Exception as e:
            print(f"获取价格失败: {e}")
            return None
    
    def refresh_price(self):
        """刷新价格"""
        self.status_var.set("正在获取最新价格...")
        self.root.update()
        
        data = self.fetch_price()
        if data:
            self.intl_price_var.set(f"{data['intl_price']:.2f} 美元/盎司")
            
            if data['change'] >= 0:
                self.intl_change_var.set(f"+{data['change']:.2f} (+{data['change_percent']:.2f}%) 📈")
                self.intl_change_var.set(f"🟢 +{data['change']:.2f} (+{data['change_percent']:.2f}%)")
            else:
                self.intl_change_var.set(f"🔴 {data['change']:.2f} ({data['change_percent']:.2f}%)")
            
            self.exchange_var.set(f"1 USD = {data['exchange']:.2f} CNY")
            self.domestic_var.set(f"{data['domestic']:.2f} 元/克")
            self.update_time_var.set(f"更新时间: {data['timestamp']}")
            
            # 保存数据
            with open(self.data_file, 'w') as f:
                json.dump(data, f, indent=2)
            
            self.status_var.set("价格已更新")
        else:
            self.status_var.set("获取价格失败")
    
    def analyze_pnl(self):
        """分析盈亏"""
        try:
            cost = float(self.cost_entry.get() or 0)
            qty = float(self.qty_entry.get() or 0)
            target = float(self.target_entry.get() or 0)
            stop = float(self.stop_entry.get() or 0)
            
            if cost <= 0 or qty <= 0:
                messagebox.showwarning("提示", "请先填写成本价和持仓量！")
                return
            
            # 获取当前价格
            data = self.fetch_price()
            if not data:
                messagebox.showerror("错误", "获取当前价格失败！")
                return
            
            current = data['domestic']
            profit = (current - cost) * qty
            profit_pct = ((current - cost) / cost) * 100
            
            # 判断状态
            if current >= target and target > 0:
                status = "🎯 已达到止盈位，建议卖出！"
                color = "#4CAF50"
            elif current <= stop and stop > 0:
                status = "🛑 已触发止损，建议果断止损！"
                color = "#f44336"
            else:
                status = "📊 价格在正常区间，建议持有观察"
                color = "#2196F3"
            
            # 格式化显示
            if profit >= 0:
                pnl_text = f"💰 浮动盈亏: +{profit:.2f} 元 (+{profit_pct:.2f}%) 📈\n"
                pnl_text += f"📈 当前价: {current:.2f} 元/克\n"
            else:
                pnl_text = f"💰 浮动盈亏: {profit:.2f} 元 ({profit_pct:.2f}%) 📉\n"
                pnl_text += f"📉 当前价: {current:.2f} 元/克\n"
            
            pnl_text += f"📦 持仓: {qty} 克 (成本 {cost} 元/克)\n"
            pnl_text += f"{status}"
            
            self.pnl_var.set(pnl_text)
            self.pnl_label.config(fg=color)
            
        except ValueError:
            messagebox.showerror("错误", "请输入有效的数字！")
    
    def show_history(self):
        """显示历史记录"""
        history_window = tk.Toplevel(self.root)
        history_window.title("价格历史")
        history_window.geometry("500x400")
        
        text = scrolledtext.ScrolledText(history_window, wrap=tk.WORD, font=("微软雅黑", 10))
        text.pack(fill="both", expand=True, padx=10, pady=10)
        
        if os.path.exists(self.data_file):
            with open(self.data_file, 'r') as f:
                data = json.load(f)
            text.insert(tk.END, json.dumps(data, indent=2, ensure_ascii=False))
        else:
            text.insert(tk.END, "暂无历史记录\n")
        
        text.config(state="disabled")
    
    def auto_refresh(self):
        """自动刷新"""
        self.refresh_price()
        # 每5分钟刷新一次
        self.root.after(300000, self.auto_refresh)

def main():
    root = tk.Tk()
    app = GoldInvestorApp(root)
    root.mainloop()

if __name__ == "__main__":
    main()
