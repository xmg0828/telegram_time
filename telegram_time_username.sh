#!/bin/bash

# Telegram自动更新时间用户名安装脚本

# 作者: Claude

# 设置颜色

GREEN=’\033[0;32m’
YELLOW=’\033[1;33m’
RED=’\033[0;31m’
BLUE=’\033[0;34m’
NC=’\033[0m’ # 恢复默认颜色

# 检查是否为root用户运行

if [ “$EUID” -ne 0 ]; then
echo -e “${RED}请使用root权限运行此脚本${NC}”
echo “例如: sudo bash $0”
exit 1
fi

echo -e “${BLUE}====================================${NC}”
echo -e “${BLUE}  Telegram 时间用户名更新器安装脚本  ${NC}”
echo -e “${BLUE}====================================${NC}”
echo “”

# 安装依赖项

echo -e “${YELLOW}正在安装必要的依赖项…${NC}”
apt update
apt install -y python3 python3-pip

# 安装Python依赖

echo -e “${YELLOW}安装Python依赖…${NC}”
pip3 install –break-system-packages telethon pytz

# 创建工作目录

WORK_DIR=”/opt/telegram-time”
echo -e “${YELLOW}创建工作目录: $WORK_DIR${NC}”
mkdir -p $WORK_DIR

# 交互式获取API凭据和时区

echo “”
echo -e “${GREEN}请输入您的Telegram API凭据${NC}”
echo “您可以从 https://my.telegram.org/apps 获取”
read -p “API ID: “ API_ID
read -p “API Hash: “ API_HASH

# 选择时区

echo “”
echo -e “${GREEN}请选择时区${NC}”
echo “1) 亚洲/上海 (中国时间)”
echo “2) 亚洲/香港”
echo “3) 亚洲/新加坡”
echo “4) 美国/东部”
echo “5) 美国/西部”
echo “6) 欧洲/伦敦”
echo “7) 自定义”
read -p “选择 [1-7]: “ TIMEZONE_CHOICE

case $TIMEZONE_CHOICE in

1. TIMEZONE=“Asia/Shanghai” ;;
1. TIMEZONE=“Asia/Hong_Kong” ;;
1. TIMEZONE=“Asia/Singapore” ;;
1. TIMEZONE=“America/New_York” ;;
1. TIMEZONE=“America/Los_Angeles” ;;
1. TIMEZONE=“Europe/London” ;;
1. 

```
echo "请输入有效的时区名称 (例如: Asia/Tokyo):"
read -p "时区: " TIMEZONE
;;
```

*)
echo -e “${RED}无效的选择，使用默认时区 Asia/Shanghai${NC}”
TIMEZONE=“Asia/Shanghai”
;;
esac

# 选择时间格式

echo “”
echo -e “${GREEN}请选择时间格式和字体样式${NC}”
echo “1) 🍼 𝟐𝟐:𝟎𝟓 𝐏𝐌 (数学字体 - 粗体)”
echo “2) 🍼 𝟤𝟤:𝟢𝟧 𝒫𝑀 (数学字体 - 双线体)”
echo “3) 🍼 ２２：０５ ＰＭ (全角字符)”
echo “4) 🍼 𝚤𝚤:𝟶𝟻 𝙿𝙼 (等宽字体)”
echo “5) 🍼 ₂₂:₀₅ ₚₘ (下标数字)”
echo “6) 🍼 ²²:⁰⁵ ᴾᴹ (上标数字)”
echo “7) 🍼 𝓭𝓭:𝓸𝓯 𝓟𝓜 (花体)”
echo “8) 🅃🄸🄼🄴 22:05 PM (圆圈字母)”
echo “9) 🕙 22:05 PM (简单样式)”
echo “10) ⚡ 22:05:30 (带秒数)”
echo “11) 📍 2024-12-06 22:05 (带日期)”
echo “12) 🔥 周五 22:05 (带星期)”
echo “13) 自定义表情和文字”
read -p “选择 [1-13]: “ FORMAT_CHOICE

# 如果选择自定义

if [ “$FORMAT_CHOICE” -eq 13 ]; then
echo “”
echo -e “${GREEN}自定义设置${NC}”
read -p “请输入表情符号 (例如: 🍼): “ CUSTOM_EMOJI
echo “请选择数字字体样式:”
echo “1) 普通数字 (12:34)”
echo “2) 粗体数字 (𝟏𝟐:𝟑𝟒)”
echo “3) 双线体数字 (𝟣𝟤:𝟥𝟦)”
echo “4) 全角数字 (１２：３４)”
echo “5) 等宽数字 (𝟷𝟸:𝟹𝟺)”
read -p “选择数字样式 [1-5]: “ NUM_STYLE

```
echo "请选择时间格式:"
echo "1) 24小时制 (22:05)"
echo "2) 12小时制 (10:05 PM)"
echo "3) 带日期 (12-06 22:05)"
echo "4) 带星期 (周五 22:05)"
read -p "选择时间格式 [1-4]: " TIME_STYLE
```

fi

# 选择更新频率

echo “”
echo -e “${GREEN}请选择更新频率${NC}”
echo “警告: 频繁更新可能导致Telegram账号受限”
echo “1) 每分钟 (推荐)”
echo “2) 每5分钟”
echo “3) 每30分钟”
echo “4) 每小时”
read -p “选择 [1-4]: “ FREQ_CHOICE

case $FREQ_CHOICE in

1. UPDATE_FREQ=60 ;;
1. UPDATE_FREQ=300 ;;
1. UPDATE_FREQ=1800 ;;
1. UPDATE_FREQ=3600 ;;
   *)
   echo -e “${RED}无效的选择，使用默认频率 (每分钟)${NC}”
   UPDATE_FREQ=60
   ;;
   esac

# 创建Python脚本

echo -e “${YELLOW}创建Python脚本…${NC}”
cat > $WORK_DIR/time_username.py << EOF
#!/usr/bin/env python3
from telethon import TelegramClient, functions, types
import asyncio
import time
import logging
import os
import locale
from datetime import datetime
import pytz

# 配置日志

logging.basicConfig(
level=logging.INFO,
format=’%(asctime)s - %(name)s - %(levelname)s - %(message)s’,
handlers=[
logging.FileHandler(”$WORK_DIR/time_username.log”),
logging.StreamHandler()
]
)
logger = logging.getLogger(**name**)

# 设置时区

timezone = pytz.timezone(”$TIMEZONE”)

# Telegram API配置

API_ID = ‘$API_ID’
API_HASH = ‘$API_HASH’
SESSION_NAME = ‘$WORK_DIR/time_username_session’

# 时间格式设置

TIME_FORMAT = $FORMAT_CHOICE
UPDATE_FREQUENCY = $UPDATE_FREQ  # 秒
CUSTOM_EMOJI = “${CUSTOM_EMOJI:-🍼}”
NUM_STYLE = ${NUM_STYLE:-1}
TIME_STYLE = ${TIME_STYLE:-1}

# 星期几的中文表示

weekday_cn = [‘一’, ‘二’, ‘三’, ‘四’, ‘五’, ‘六’, ‘日’]

# 数字字体转换字典

def convert_numbers(text, style):
“”“转换数字字体样式”””
normal = “0123456789”

```
if style == 2:  # 粗体
    bold = "𝟎𝟏𝟐𝟑𝟒𝟓𝟔𝟕𝟖𝟗"
    trans = str.maketrans(normal, bold)
elif style == 3:  # 双线体
    double = "𝟘𝟙𝟚𝟛𝟜𝟝𝟞𝟟𝟠𝟡"
    trans = str.maketrans(normal, double)
elif style == 4:  # 全角
    fullwidth = "０１２３４５６７８９"
    trans = str.maketrans(normal, fullwidth)
    text = text.replace(":", "：")
elif style == 5:  # 等宽
    mono = "𝟶𝟷𝟸𝟹𝟺𝟻𝟼𝟽𝟾𝟿"
    trans = str.maketrans(normal, mono)
else:  # 普通
    return text

return text.translate(trans)
```

def convert_letters(text, style):
“”“转换字母字体样式”””
if style == 2:  # 粗体
text = text.replace(“AM”, “𝐀𝐌”).replace(“PM”, “𝐏𝐌”)
text = text.replace(“am”, “𝐚𝐦”).replace(“pm”, “𝐩𝐦”)
elif style == 3:  # 双线体
text = text.replace(“AM”, “𝔸𝕄”).replace(“PM”, “ℙ𝕄”)
text = text.replace(“am”, “𝕒𝕞”).replace(“pm”, “𝕡𝕞”)
elif style == 4:  # 全角
text = text.replace(“AM”, “ＡＭ”).replace(“PM”, “ＰＭ”)
text = text.replace(“am”, “ａｍ”).replace(“pm”, “ｐｍ”)
elif style == 5:  # 等宽
text = text.replace(“AM”, “𝙰𝙼”).replace(“PM”, “𝙿𝙼”)
text = text.replace(“am”, “𝚊𝚖”).replace(“pm”, “𝚙𝚖”)

```
return text
```

def get_time_username():
now = datetime.now(timezone)

```
if TIME_FORMAT == 1:  # 🍼 𝟐𝟐:𝟎𝟓 𝐏𝐌 (数学字体 - 粗体)
    time_str = now.strftime('%I:%M %p')
    time_str = convert_numbers(time_str, 2)
    time_str = convert_letters(time_str, 2)
    return f"🍼 {time_str}"

elif TIME_FORMAT == 2:  # 🍼 𝟤𝟤:𝟢𝟧 𝒫𝑀 (数学字体 - 双线体)
    time_str = now.strftime('%I:%M %p')
    time_str = convert_numbers(time_str, 3)
    time_str = convert_letters(time_str, 3)
    return f"🍼 {time_str}"

elif TIME_FORMAT == 3:  # 🍼 ２２：０５ ＰＭ (全角字符)
    time_str = now.strftime('%I:%M %p')
    time_str = convert_numbers(time_str, 4)
    time_str = convert_letters(time_str, 4)
    return f"🍼 {time_str}"

elif TIME_FORMAT == 4:  # 🍼 𝚤𝚤:𝟶𝟻 𝙿𝙼 (等宽字体)
    time_str = now.strftime('%I:%M %p')
    time_str = convert_numbers(time_str, 5)
    time_str = convert_letters(time_str, 5)
    return f"🍼 {time_str}"

elif TIME_FORMAT == 5:  # 🍼 ₂₂:₀₅ ₚₘ (下标数字)
    time_str = now.strftime('%I:%M %p').lower()
    subscript_nums = "₀₁₂₃₄₅₆₇₈₉"
    normal_nums = "0123456789"
    trans = str.maketrans(normal_nums, subscript_nums)
    time_str = time_str.translate(trans)
    time_str = time_str.replace("am", "ₐₘ").replace("pm", "ₚₘ")
    return f"🍼 {time_str}"

elif TIME_FORMAT == 6:  # 🍼 ²²:⁰⁵ ᴾᴹ (上标数字)
    time_str = now.strftime('%I:%M %p')
    superscript_nums = "⁰¹²³⁴⁵⁶⁷⁸⁹"
    normal_nums = "0123456789"
    trans = str.maketrans(normal_nums, superscript_nums)
    time_str = time_str.translate(trans)
    time_str = time_str.replace("AM", "ᴬᴹ").replace("PM", "ᴾᴹ")
    return f"🍼 {time_str}"

elif TIME_FORMAT == 7:  # 🍼 𝓭𝓭:𝓸𝓯 𝓟𝓜 (花体)
    time_str = now.strftime('%I:%M %p')
    # 花体转换 (简化版)
    script_map = {
        '0': '𝓸', '1': '𝟭', '2': '𝟮', '3': '𝟯', '4': '𝟰', 
        '5': '𝟱', '6': '𝟲', '7': '𝟳', '8': '𝟴', '9': '𝟵',
        'A': '𝓐', 'M': '𝓜', 'P': '𝓟'
    }
    for old, new in script_map.items():
        time_str = time_str.replace(old, new)
    return f"🍼 {time_str}"

elif TIME_FORMAT == 8:  # 🅃🄸🄼🄴 22:05 PM (圆圈字母)
    time_str = now.strftime('%I:%M %p')
    return f"🅃🄸🄼🄴 {time_str}"

elif TIME_FORMAT == 9:  # 🕙 22:05 PM (简单样式)
    time_str = now.strftime('%I:%M %p')
    return f"🕙 {time_str}"

elif TIME_FORMAT == 10:  # ⚡ 22:05:30 (带秒数)
    time_str = now.strftime('%H:%M:%S')
    return f"⚡ {time_str}"

elif TIME_FORMAT == 11:  # 📍 2024-12-06 22:05 (带日期)
    time_str = now.strftime('%Y-%m-%d %H:%M')
    return f"📍 {time_str}"

elif TIME_FORMAT == 12:  # 🔥 周五 22:05 (带星期)
    weekday = weekday_cn[now.weekday()]
    time_str = now.strftime('%H:%M')
    return f"🔥 周{weekday} {time_str}"

elif TIME_FORMAT == 13:  # 自定义
    if TIME_STYLE == 1:  # 24小时制
        time_str = now.strftime('%H:%M')
    elif TIME_STYLE == 2:  # 12小时制
        time_str = now.strftime('%I:%M %p')
    elif TIME_STYLE == 3:  # 带日期
        time_str = now.strftime('%m-%d %H:%M')
    elif TIME_STYLE == 4:  # 带星期
        weekday = weekday_cn[now.weekday()]
        time_str = f"周{weekday} {now.strftime('%H:%M')}"
    else:
        time_str = now.strftime('%H:%M')
    
    time_str = convert_numbers(time_str, NUM_STYLE)
    time_str = convert_letters(time_str, NUM_STYLE)
    return f"{CUSTOM_EMOJI} {time_str}"

else:
    return f"🕒 {now.strftime('%H:%M')}"
```

async def update_username():
try:
# 连接到Telegram
client = TelegramClient(SESSION_NAME, API_ID, API_HASH)
await client.start()

```
    logger.info("已连接到Telegram")
    
    me = await client.get_me()
    logger.info(f"当前账号: {me.first_name} (@{me.username})")
    
    while True:
        new_username = get_time_username()
        try:
            # 更新用户名
            await client(functions.account.UpdateProfileRequest(
                first_name=new_username
            ))
            logger.info(f"用户名已更新为: {new_username}")
        except Exception as e:
            logger.error(f"更新用户名失败: {e}")
            # 如果遇到速率限制，等待更长时间
            if "flood" in str(e).lower() or "rate" in str(e).lower():
                logger.warning("遇到速率限制，等待10分钟后重试")
                await asyncio.sleep(600)
                continue
        
        # 计算下次更新时间
        wait_time = UPDATE_FREQUENCY
        if UPDATE_FREQUENCY == 60:
            # 如果是每分钟更新，则对齐到整分钟
            now = datetime.now()
            wait_time = 60 - now.second
            
        logger.info(f"等待 {wait_time} 秒后再次更新")
        await asyncio.sleep(wait_time)

except Exception as e:
    logger.error(f"运行出错: {e}")
    # 如果遇到错误，等待一段时间后重试
    await asyncio.sleep(60)
    await update_username()
```

if **name** == “**main**”:
loop = asyncio.get_event_loop()
try:
loop.run_until_complete(update_username())
except KeyboardInterrupt:
logger.info(“程序被用户中断”)
finally:
loop.close()
EOF

# 设置可执行权限

chmod +x $WORK_DIR/time_username.py

# 创建systemd服务

echo -e “${YELLOW}创建系统服务…${NC}”
cat > /etc/systemd/system/telegram-time.service << EOF
[Unit]
Description=Telegram Time Username Updater
After=network.target

[Service]
ExecStart=/usr/bin/python3 $WORK_DIR/time_username.py
WorkingDirectory=$WORK_DIR
Restart=always
RestartSec=30
User=root
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
EOF

# 重新加载systemd

systemctl daemon-reload
systemctl enable telegram-time

echo “”
echo -e “${GREEN}✅ 安装完成！${NC}”
echo “”
echo -e “${YELLOW}现在运行以下命令登录您的Telegram账号:${NC}”
echo -e “  ${BLUE}cd $WORK_DIR && python3 time_username.py${NC}”
echo “”
echo -e “${YELLOW}登录成功后，按Ctrl+C停止程序，然后启动服务:${NC}”
echo -e “  ${BLUE}systemctl start telegram-time${NC}”
echo “”
echo -e “${YELLOW}管理命令:${NC}”
echo -e “  查看状态: ${BLUE}systemctl status telegram-time${NC}”
echo -e “  停止服务: ${BLUE}systemctl stop telegram-time${NC}”
echo -e “  重启服务: ${BLUE}systemctl restart telegram-time${NC}”
echo -e “  查看日志: ${BLUE}tail -f $WORK_DIR/time_username.log${NC}”
echo -e “  实时日志: ${BLUE}journalctl -f -u telegram-time${NC}”
echo “”
echo -e “${YELLOW}注意事项:${NC}”
echo -e “• 请勿过于频繁更新，避免账号受限”
echo -e “• 如遇到问题，查看日志文件排查”
echo -e “• 服务会在系统重启后自动启动”
echo “”
