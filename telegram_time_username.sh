#!/bin/bash

# 简单版Telegram时间用户名更新器

echo “=======================================”
echo “  Telegram 时间用户名更新器”
echo “=======================================”

# 检查root权限

if [ “$EUID” -ne 0 ]; then
echo “错误: 请使用sudo运行此脚本”
exit 1
fi

# 安装依赖

echo “安装依赖…”
apt update > /dev/null 2>&1
apt install -y python3 python3-pip python3-venv python3-full > /dev/null 2>&1

# 创建目录

WORK_DIR=”/opt/telegram-time”
mkdir -p $WORK_DIR

# 创建虚拟环境

echo “创建虚拟环境…”
python3 -m venv $WORK_DIR/venv > /dev/null 2>&1

# 安装Python包

echo “安装Python包…”
$WORK_DIR/venv/bin/pip install telethon pytz > /dev/null 2>&1

# 获取API信息

echo “”
echo “请输入Telegram API信息:”
echo “获取地址: https://my.telegram.org/apps”
echo “”
read -p “API ID: “ API_ID
read -p “API Hash: “ API_HASH

# 选择时区

echo “”
echo “选择时区:”
echo “1) 中国时间”
echo “2) 香港时间”
echo “3) 新加坡时间”
read -p “选择 [1-3]: “ TZ_CHOICE

case $TZ_CHOICE in
2) TIMEZONE=“Asia/Hong_Kong” ;;
3) TIMEZONE=“Asia/Singapore” ;;
*) TIMEZONE=“Asia/Shanghai” ;;
esac

# 选择格式

echo “”
echo “选择显示格式:”
echo “1) 🍼 22:05”
echo “2) 🕙 22:05 PM”
echo “3) ⚡ 22:05:30”
echo “4) 📅 12-06 22:05”
echo “5) 🔥 周五 22:05”
echo “6) 自定义表情符号”
read -p “选择 [1-6]: “ FORMAT

# 自定义表情

CUSTOM_EMOJI=””
if [ “$FORMAT” = “6” ]; then
echo “”
read -p “请输入自定义表情符号 (例如: 💎): “ CUSTOM_EMOJI
if [ -z “$CUSTOM_EMOJI” ]; then
CUSTOM_EMOJI=“🕒”
fi
echo “自定义表情: $CUSTOM_EMOJI”
fi

# 选择频率

echo “”
echo “选择更新频率:”
echo “1) 每分钟”
echo “2) 每5分钟”
echo “3) 每30分钟”
read -p “选择 [1-3]: “ FREQ

case $FREQ in

1. UPDATE_FREQ=60 ;;
1. UPDATE_FREQ=1800 ;;
   *) UPDATE_FREQ=300 ;;
   esac

# 创建Python脚本

cat > $WORK_DIR/time_username.py << ‘PYEOF’
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
sys.exit(1)

logging.basicConfig(
level=logging.INFO,
format=’%(asctime)s - %(message)s’,
handlers=[
logging.FileHandler(’/opt/telegram-time/app.log’),
logging.StreamHandler()
]
)
logger = logging.getLogger(**name**)

API_ID = os.environ.get(‘API_ID’)
API_HASH = os.environ.get(‘API_HASH’)
TIMEZONE_STR = os.environ.get(‘TIMEZONE’, ‘Asia/Shanghai’)
TIME_FORMAT = int(os.environ.get(‘TIME_FORMAT’, ‘1’))
UPDATE_FREQUENCY = int(os.environ.get(‘UPDATE_FREQ’, ‘300’))
CUSTOM_EMOJI = os.environ.get(‘CUSTOM_EMOJI’, ‘🕒’)

if not API_ID or not API_HASH:
logger.error(“未设置API信息”)
sys.exit(1)

timezone = pytz.timezone(TIMEZONE_STR)
SESSION_NAME = ‘/opt/telegram-time/session’
weekday_cn = [‘一’, ‘二’, ‘三’, ‘四’, ‘五’, ‘六’, ‘日’]

def get_time_username():
now = datetime.now(timezone)

```
if TIME_FORMAT == 1:
    return f"🍼 {now.strftime('%H:%M')}"
elif TIME_FORMAT == 2:
    return f"🕙 {now.strftime('%I:%M %p')}"
elif TIME_FORMAT == 3:
    return f"⚡ {now.strftime('%H:%M:%S')}"
elif TIME_FORMAT == 4:
    return f"📅 {now.strftime('%m-%d %H:%M')}"
elif TIME_FORMAT == 5:
    weekday = weekday_cn[now.weekday()]
    return f"🔥 周{weekday} {now.strftime('%H:%M')}"
elif TIME_FORMAT == 6:
    return f"{CUSTOM_EMOJI} {now.strftime('%H:%M')}"
else:
    return f"🍼 {now.strftime('%H:%M')}"
```

async def update_username():
client = None
try:
client = TelegramClient(SESSION_NAME, API_ID, API_HASH)
await client.start()

```
    logger.info("已连接到Telegram")
    me = await client.get_me()
    logger.info(f"当前账号: {me.first_name}")
    
    while True:
        try:
            new_username = get_time_username()
            await client(functions.account.UpdateProfileRequest(
                first_name=new_username
            ))
            logger.info(f"用户名已更新: {new_username}")
            
        except Exception as e:
            if 'flood' in str(e).lower():
                logger.warning("遇到速率限制，等待10分钟")
                await asyncio.sleep(600)
                continue
            else:
                logger.error(f"更新失败: {e}")
        
        await asyncio.sleep(UPDATE_FREQUENCY)
        
except KeyboardInterrupt:
    logger.info("程序被停止")
except Exception as e:
    logger.error(f"运行错误: {e}")
finally:
    if client and client.is_connected():
        await client.disconnect()
```

if **name** == “**main**”:
try:
asyncio.run(update_username())
except KeyboardInterrupt:
print(“程序已停止”)
PYEOF

# 创建配置文件

cat > $WORK_DIR/config.env << CONFEOF
API_ID=$API_ID
API_HASH=$API_HASH
TIMEZONE=$TIMEZONE
TIME_FORMAT=$FORMAT
UPDATE_FREQ=$UPDATE_FREQ
CUSTOM_EMOJI=$CUSTOM_EMOJI
CONFEOF

# 创建启动脚本

cat > $WORK_DIR/start.sh << ‘STARTEOF’
#!/bin/bash
cd /opt/telegram-time
export $(cat config.env | xargs)
./venv/bin/python time_username.py
STARTEOF

chmod +x $WORK_DIR/start.sh
chmod +x $WORK_DIR/time_username.py

# 创建系统服务

cat > /etc/systemd/system/telegram-time.service << SERVICEEOF
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
SERVICEEOF

systemctl daemon-reload
systemctl enable telegram-time

echo “”
echo “安装完成！”
echo “”
echo “下一步：”
echo “1. 运行: cd $WORK_DIR && ./start.sh”
echo “2. 输入手机号和验证码登录”
echo “3. 登录成功后按Ctrl+C”
echo “4. 启动服务: systemctl start telegram-time”
echo “”
echo “管理命令：”
echo “  查看状态: systemctl status telegram-time”
echo “  查看日志: tail -f $WORK_DIR/app.log”
echo “”
