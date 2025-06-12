#!/bin/bash

# Telegram自动更新时间用户名安装脚本 - 高级定制版

# 设置颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 检查是否为root用户运行
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}请使用root权限运行此脚本 (sudo bash $0)${NC}"
    exit 1
fi

# 清屏
clear

# 显示标题
echo -e "${BLUE}====================================${NC}"
echo -e "${BLUE}  Telegram 时间用户名高级更新器  ${NC}"
echo -e "${BLUE}====================================${NC}"

# 创建工作目录
WORK_DIR="/opt/telegram-time"
mkdir -p $WORK_DIR

# API凭据输入
echo -e "${GREEN}请输入Telegram API凭据${NC}"
read -p "API ID: " API_ID
read -p "API Hash: " API_HASH

# 时区选择
echo -e "\n${GREEN}选择时区${NC}"
TIMEZONES=(
    "Asia/Shanghai:中国标准时间"
    "Asia/Hong_Kong:香港时间"
    "Asia/Singapore:新加坡时间"
    "Asia/Tokyo:日本时间"
    "America/New_York:纽约时间"
    "自定义时区"
)

for i in "${!TIMEZONES[@]}"; do
    IFS=':' read -r tz desc <<< "${TIMEZONES[i]}"
    echo "$((i+1)). $desc ($tz)"
done

read -p "选择时区 [1-$((${#TIMEZONES[@]}))] : " TIMEZONE_CHOICE

if [[ $TIMEZONE_CHOICE -ge 1 && $TIMEZONE_CHOICE -le $((${#TIMEZONES[@]}-1)) ]]; then
    IFS=':' read -r TIMEZONE _ <<< "${TIMEZONES[$((TIMEZONE_CHOICE-1))]}"
else
    read -p "输入自定义时区 (例如 Asia/Tokyo): " TIMEZONE
fi

# 图标选择
echo -e "\n${GREEN}选择时间图标${NC}"
ICONS=(
    "⌚️:经典时钟"
    "🕒:现代时钟"
    "📅:日历"
    "🤖:机器人"
    "⭐:星星"
    "🚀:火箭"
    "🌈:彩虹"
    "自定义图标"
)

for i in "${!ICONS[@]}"; do
    IFS=':' read -r icon desc <<< "${ICONS[i]}"
    echo "$((i+1)). $desc $icon"
done

read -p "选择图标 [1-$((${#ICONS[@]}))] : " ICON_CHOICE

if [[ $ICON_CHOICE -ge 1 && $ICON_CHOICE -le $((${#ICONS[@]}-1)) ]]; then
    IFS=':' read -r ICON _ <<< "${ICONS[$((ICON_CHOICE-1))]}"
else
    read -p "输入自定义图标 (例如 🌟): " ICON
fi

# 字体样式选择
echo -e "\n${GREEN}选择字体样式${NC}"
FONTS=(
    "default:默认字体"
    "bold:𝐁𝐨𝐥𝐝 𝐒𝐭𝐲𝐥𝐞"
    "script:𝒮𝒸𝓇𝒾𝓅𝓉 𝒮𝓉𝓎𝓁𝑒"
    "monospace:𝙼𝚘𝚗𝚘𝚜𝚙𝚊𝚌𝚎 𝚂𝚝𝚢𝚕𝚎"
    "rounded:Ｒｏｕｎｄｅｄ Ｓｔｙｌｅ"
    "math:𝕄𝕒𝕥𝕙 𝕊𝕥𝕪𝕝𝕖"
    "自定义字体"
)

for i in "${!FONTS[@]}"; do
    IFS=':' read -r font desc <<< "${FONTS[i]}"
    echo "$((i+1)). $desc: $font"
done

read -p "选择字体 [1-$((${#FONTS[@]}))] : " FONT_CHOICE

if [[ $FONT_CHOICE -ge 1 && $FONT_CHOICE -le $((${#FONTS[@]}-1)) ]]; then
    IFS=':' read -r FONT_STYLE _ <<< "${FONTS[$((FONT_CHOICE-1))]}"
else
    read -p "输入自定义字体转换 (例如输入一个转换函数): " FONT_STYLE
fi

# 时间格式选择
echo -e "\n${GREEN}选择时间显示格式${NC}"
TIME_FORMATS=(
    "HH:mm:24小时制"
    "hh:mm a:12小时制"
    "MM-dd HH:mm:带日期"
    "周X HH:mm:带星期"
)

for i in "${!TIME_FORMATS[@]}"; do
    IFS=':' read -r format desc <<< "${TIME_FORMATS[i]}"
    echo "$((i+1)). $desc ($format)"
done

read -p "选择格式 [1-${#TIME_FORMATS[@]}] : " FORMAT_CHOICE

case $FORMAT_CHOICE in
    1) TIME_FORMAT="%H:%M" ;;
    2) TIME_FORMAT="%I:%M %p" ;;
    3) TIME_FORMAT="%m-%d %H:%M" ;;
    4) TIME_FORMAT="周%w %H:%M" ;;
    *) TIME_FORMAT="%H:%M" ;;
esac

# 更新频率
echo -e "\n${GREEN}选择更新频率${NC}"
echo "1. 每分钟"
echo "2. 每5分钟"
echo "3. 每15分钟"
read -p "选择频率 [1-3]: " FREQ_CHOICE

case $FREQ_CHOICE in
    1) UPDATE_FREQ=60 ;;
    2) UPDATE_FREQ=300 ;;
    3) UPDATE_FREQ=900 ;;
    *) UPDATE_FREQ=60 ;;
esac

# 创建字体转换模块
cat > $WORK_DIR/font_converter.py << EOF
def convert_font(text, style='default'):
    font_maps = {
        'default': lambda x: x,
        'bold': {
            'a':'𝐚', 'b':'𝐛', 'c':'𝐜', 'd':'𝐝', 'e':'𝐞', 
            'f':'𝐟', 'g':'𝐠', 'h':'𝐡', 'i':'𝐢', 'j':'𝐣', 
            'k':'𝐤', 'l':'𝐥', 'm':'𝐦', 'n':'𝐧', 'o':'𝐨', 
            'p':'𝐩', 'q':'𝐪', 'r':'𝐫', 's':'𝐬', 't':'𝐭', 
            'u':'𝐮', 'v':'𝐯', 'w':'𝐰', 'x':'𝐱', 'y':'𝐲', 'z':'𝐳',
            'A':'𝐀', 'B':'𝐁', 'C':'𝐂', 'D':'𝐃', 'E':'𝐄', 
            'F':'𝐅', 'G':'𝐆', 'H':'𝐇', 'I':'𝐈', 'J':'𝐉', 
            'K':'𝐊', 'L':'𝐋', 'M':'𝐌', 'N':'𝐍', 'O':'𝐎', 
            'P':'𝐏', 'Q':'𝐐', 'R':'𝐑', 'S':'𝐒', 'T':'𝐓', 
            'U':'𝐔', 'V':'𝐕', 'W':'𝐖', 'X':'𝐗', 'Y':'𝐘', 'Z':'𝐙'
        },
        # 其他字体映射（之前的代码）
    }
    
    font_map = font_maps.get(style, font_maps['default'])
    converted_text = ''.join(font_map.get(char, char) for char in text)
    
    return converted_text
EOF

# 创建主Python脚本
cat > $WORK_DIR/time_username.py << EOF
#!/usr/bin/env python3
import pytz
from datetime import datetime
from telethon import TelegramClient, functions
import asyncio
import logging
import sys
import importlib.util

# 动态导入字体转换模块
spec = importlib.util.spec_from_file_location("font_converter", "$WORK_DIR/font_converter.py")
font_converter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(font_converter)

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s: %(message)s',
    handlers=[
        logging.FileHandler("$WORK_DIR/telegram_time.log"),
        logging.StreamHandler(sys.stdout)
    ]
)

# 配置参数
API_ID = '$API_ID'
API_HASH = '$API_HASH'
TIMEZONE = pytz.timezone('$TIMEZONE')
ICON = '$ICON'
TIME_FORMAT = '$TIME_FORMAT'
FONT_STYLE = '$FONT_STYLE'
UPDATE_FREQUENCY = $UPDATE_FREQ

async def update_username():
    async with TelegramClient('session', API_ID, API_HASH) as client:
        while True:
            try:
                current_time = datetime.now(TIMEZONE).strftime(TIME_FORMAT)
                formatted_time = font_converter.convert_font(current_time, FONT_STYLE)
                new_username = f"{ICON} {formatted_time}"
                
                await client(functions.account.UpdateProfileRequest(
                    first_name=new_username
                ))
                logging.info(f"用户名已更新: {new_username}")
                
                await asyncio.sleep(UPDATE_FREQUENCY)
            except Exception as e:
                logging.error(f"更新失败: {e}")
                await asyncio.sleep(60)

if __name__ == '__main__':
    asyncio.run(update_username())
EOF

# 设置脚本权限
chmod +x $WORK_DIR/time_username.py
chmod +x $WORK_DIR/font_converter.py

# 创建系统服务
cat > /etc/systemd/system/telegram-time.service << EOF
[Unit]
Description=Telegram Time Username Updater
After=network.target

[Service]
ExecStart=/usr/bin/python3 $WORK_DIR/time_username.py
WorkingDirectory=$WORK_DIR
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# 重新加载systemd
systemctl daemon-reload
systemctl enable telegram-time

# 完成提示
echo -e "\n${GREEN}✅ 安装完成！${NC}"
echo -e "${YELLOW}使用说明:${NC}"
echo -e "1. 首次运行请执行: ${BLUE}cd $WORK_DIR && python3 time_username.py${NC}"
echo -e "2. 登录成功后，按 Ctrl+C 停止"
echo -e "3. 启动服务: ${BLUE}systemctl start telegram-time${NC}"
echo -e "4. 查看服务状态: ${BLUE}systemctl status telegram-time${NC}"
echo -e "5. 查看日志: ${BLUE}tail -f $WORK_DIR/telegram_time.log${NC}"
