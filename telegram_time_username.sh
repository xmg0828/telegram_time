#!/bin/bash

# Telegram自动更新时间用户名安装脚本 - 系统原生版本

# 作者: Claude

# 设置颜色

GREEN=’\033[0;32m’
YELLOW=’\033[1;33m’
RED=’\033[0;31m’
BLUE=’\033[0;34m’
NC=’\033[0m’

echo -e “${BLUE}====================================${NC}”
echo -e “${BLUE}  Telegram 时间用户名更新器安装脚本  ${NC}”
echo -e “${BLUE}====================================${NC}”
echo “”

# 检查是否为root用户运行

if [ “$EUID” -ne 0 ]; then
echo -e “${RED}请使用root权限运行此脚本${NC}”
echo “例如: sudo bash $0”
exit 1
fi

# 更新系统并安装依赖

echo -e “${YELLOW}正在更新系统并安装依赖…${NC}”
apt update
apt install -y python3 python3-pip curl

# 强制安装Python包（忽略外部管理警告）

echo -e “${YELLOW}安装Python依赖包…${NC}”
pip3 install telethon pytz –break-system-packages –force-reinstall

# 创建工作目录

WORK_DIR=”/opt/telegram-time”
echo -e “${YELLOW}创建工作目录: $WORK_DIR${NC}”
mkdir -p $WORK_DIR

# 获取API凭据

echo “”
echo -e “${GREEN}请输入您的Telegram API凭据${NC}”
echo -e “${YELLOW}获取地址: https://my.telegram.org/apps${NC}”
echo “”
read -p “请输入API ID: “ API_ID
read -s -p “请输入API Hash: “ API_HASH
echo “”

# 验证输入

if [ -z “$API_ID” ] || [ -z “$API_HASH” ]; then
echo -e “${RED}错误: API ID和API Hash不能为空！${NC}”
exit 1
fi

# 选择时区

echo “”
echo -e “${GREEN}请选择时区${NC}”
echo “1) 亚洲/上海 (中国时间)”
echo “2) 亚洲/香港”
echo “3) 亚洲/新加坡”
echo “4) 自定义”
read -p “选择 [1-4]: “ TIMEZONE_CHOICE

case $TIMEZONE_CHOICE in

1. TIMEZONE=“Asia/Shanghai” ;;
1. TIMEZONE=“Asia/Hong_Kong” ;;
1. TIMEZONE=“Asia/Singapore” ;;
1. 

```
read -p "请输入时区 (例如: Asia/Tokyo): " TIMEZONE
if [ -z "$TIMEZONE" ]; then
    TIMEZONE="Asia/Shanghai"
fi
;;
```

*)
echo -e “${RED}无效选择，使用默认时区${NC}”
TIMEZONE=“Asia/Shanghai”
;;
esac

# 选择时间格式

echo “”
echo -e “${GREEN}请选择时间显示格式${NC}”
echo “1) 🍼 22:05 (简洁样式)”
echo “2) 🕙 22:05 PM (12小时制)”
echo “3) ⚡ 22:05:30 (带秒数)”
echo “4) 📅 12-06 22:05 (带日期)”
echo “5) 🔥 周五 22:05 (带星期)”
echo “6) 自定义表情”
read -p “选择 [1-6]: “ FORMAT_CHOICE

# 自定义表情

CUSTOM_EMOJI=“🍼”
if [ “$FORMAT_CHOICE” -eq 6 ]; then
echo “”
read -p “请输入自定义表情 (例如: 🔥): “ CUSTOM_EMOJI
if [ -z “$CUSTOM_EMOJI” ]; then
CUSTOM_EMOJI=“🍼”
fi
fi

# 选择更新频率

echo “”
echo -e “${GREEN}请选择更新频率${NC}”
echo -e “${YELLOW}注意: 过于频繁可能导致账号限制${NC}”
echo “1) 每分钟”
echo “2) 每5分钟 (推荐)”
echo “3) 每30分钟”
read -p “选择 [1-3]: “ FREQ_CHOICE

case $FREQ_CHOICE in

1. UPDATE_FREQ=60 ;;
1. UPDATE_FREQ=300 ;;
1. UPDATE_FREQ=1800 ;;
   *) UPDATE_FREQ=300 ;;
   esac

# 创建Python脚本

echo -e “${YELLOW}创建Python脚本…${NC}”
cat > “$WORK_DIR/time_username.py” << EOF
#!/usr/bin/env python3
import asyncio
import logging
import os
import sys
from datetime import datetime
try:
import pytz
from telethon import TelegramClient, functions
except ImportError as e:
print(f”导入错误: {e}”)
print(“请运行: pip3 install telethon pytz –break-system-packages”)
sys.exit(1)

# 配置日志

logging.basicConfig(
level=logging.INFO,
format=’%(asctime)s - %(levelname)s - %(message)s’,
handlers=[
logging.FileHandler(”$WORK_DIR/time_username.log”),
logging.StreamHandler()
]
)
logger = logging.getLogger(**name**)

# 配置

API_ID = ‘$API_ID’
API_HASH = ‘$API_HASH’
TIMEZONE_STR = ‘$TIMEZONE’
TIME_FORMAT = $FORMAT_CHOICE
UPDATE_FREQUENCY = $UPDATE_FREQ
CUSTOM_EMOJI = ‘$CUSTOM_EMOJI’

# 设置时区

try:
timezone = pytz.timezone(TIMEZONE_STR)
except:
timezone = pytz.timezone(‘Asia/Shanghai’)
logger.warning(f”时区设置失败，使用默认时区: Asia/Shanghai”)

SESSION_NAME = ‘$WORK_DIR/session’
weekday_cn = [‘一’, ‘二’, ‘三’, ‘四’, ‘五’, ‘六’, ‘日’]

def get_time_username():
“”“生成时间用户名”””
try:
now = datetime.now(timezone)

```
    if TIME_FORMAT == 1:  # 🍼 22:05
        return f"🍼 {now.strftime('%H:%M')}"
    elif TIME_FORMAT == 2:  # 🕙 22:05 PM
        return f"🕙 {now.strftime('%I:%M %p')}"
    elif TIME_FORMAT == 3:  # ⚡ 22:05:30
        return f"⚡ {now.strftime('%H:%M:%S')}"
    elif TIME_FORMAT == 4:  # 📅 12-06 22:05
        return f"📅 {now.strftime('%m-%d %H:%M')}"
    elif TIME_FORMAT == 5:  # 🔥 周五 22:05
        weekday = weekday_cn[now.weekday()]
        return f"🔥 周{weekday} {now.strftime('%H:%M')}"
    elif TIME_FORMAT == 6:  # 自定义
        return f"{CUSTOM_EMOJI} {now.strftime('%H:%M')}"
    else:
        return f"🕒 {now.strftime('%H:%M')}"
except Exception as e:
    logger.error(f"生成时间用户名错误: {e}")
    return f"🕒 {datetime.now().strftime('%H:%M')}"
```

async def update_username():
“”“更新用户名主函数”””
client = None
try:
# 连接Telegram
client = TelegramClient(SESSION_NAME, API_ID, API_HASH)
await client.start()

```
    logger.info("已连接到Telegram")
    
    # 获取当前用户信息
    me = await client.get_me()
    logger.info(f"当前账号: {me.first_name}")
    
    # 主循环
    while True:
        try:
            new_username = get_time_username()
            
            # 更新用户名
            await client(functions.account.UpdateProfileRequest(
                first_name=new_username
            ))
            logger.info(f"✅ 用户名已更新: {new_username}")
            
        except Exception as e:
            error_msg = str(e).lower()
            if 'flood' in error_msg or 'seconds' in error_msg:
                logger.warning(f"⚠️ 遇到速率限制: {e}")
                await asyncio.sleep(600)  # 等待10分钟
                continue
            else:
                logger.error(f"❌ 更新失败: {e}")
        
        # 等待下次更新
        logger.info(f"⏰ {UPDATE_FREQUENCY}秒后下次更新")
        await asyncio.sleep(UPDATE_FREQUENCY)
        
except KeyboardInterrupt:
    logger.info("👋 程序被用户停止")
except Exception as e:
    logger.error(f"💥 程序运行错误: {e}")
    # 等待后重试
    await asyncio.sleep(60)
    await update_username()
finally:
    if client and client.is_connected():
        await client.disconnect()
        logger.info("🔌 已断开Telegram连接")
```

if **name** == “**main**”:
try:
asyncio.run(update_username())
except KeyboardInterrupt:
print(”\n👋 程序已停止”)
except Exception as e:
print(f”💥 启动失败: {e}”)
sys.exit(1)
EOF

# 设置可执行权限

chmod +x “$WORK_DIR/time_username.py”

# 创建启动脚本

cat > “$WORK_DIR/start.sh” << EOF
#!/bin/bash
cd $WORK_DIR
python3 time_username.py
EOF

chmod +x “$WORK_DIR/start.sh”

# 创建systemd服务

cat > /etc/systemd/system/telegram-time.service << EOF
[Unit]
Description=Telegram Time Username Updater
After=network.target

[Service]
Type=simple
ExecStart=$WORK_DIR/start.sh
WorkingDirectory=$WORK_DIR
Restart=always
RestartSec=10
User=root

[Install]
WantedBy=multi-user.target
EOF

# 重新加载systemd

systemctl daemon-reload
systemctl enable telegram-time

echo “”
echo -e “${GREEN}🎉 安装完成！${NC}”
echo “”
echo -e “${YELLOW}📱 现在需要登录您的Telegram账号:${NC}”
echo -e “  ${BLUE}cd $WORK_DIR && python3 time_username.py${NC}”
echo “”
echo -e “${YELLOW}🔑 首次运行时会要求输入手机号和验证码${NC}”
echo -e “${YELLOW}✅ 登录成功后，按 Ctrl+C 停止程序${NC}”
echo “”
echo -e “${YELLOW}🚀 然后启动后台服务:${NC}”
echo -e “  ${BLUE}systemctl start telegram-time${NC}”
echo “”
echo -e “${YELLOW}📊 管理命令:${NC}”
echo -e “  查看状态: ${BLUE}systemctl status telegram-time${NC}”
echo -e “  停止服务: ${BLUE}systemctl stop telegram-time${NC}”
echo -e “  重启服务: ${BLUE}systemctl restart telegram-time${NC}”
echo -e “  查看日志: ${BLUE}tail -f $WORK_DIR/time_username.log${NC}”
echo “”
echo -e “${GREEN}配置摘要:${NC}”
echo -e “  时区: ${TIMEZONE}”
echo -e “  格式: 选项 ${FORMAT_CHOICE}”
echo -e “  频率: 每 ${UPDATE_FREQ} 秒”
echo -e “  表情: ${CUSTOM_EMOJI}”
echo “”
EOF
