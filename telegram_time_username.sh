#!/bin/bash

# Telegram时间用户名更新器 - 一键安装脚本

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# 工作目录
WORK_DIR="/opt/telegram-time"

# 检查root权限
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}请使用root权限运行此脚本${NC}"
    exit 1
fi

# 清屏
clear

# 标题
echo -e "${BLUE}====================================${NC}"
echo -e "${BLUE}  Telegram 时间用户名更新器  ${NC}"
echo -e "${BLUE}====================================${NC}"

# 创建工作目录
mkdir -p $WORK_DIR

# 安装依赖
echo -e "${YELLOW}正在安装必要依赖...${NC}"
apt update &>/dev/null
apt install -y python3 python3-pip &>/dev/null
pip3 install telethon pytz &>/dev/null

# 创建字体转换模块
cat > $WORK_DIR/font_converter.py << 'EOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

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
        'script': {
            'a':'𝒶', 'b':'𝒷', 'c':'𝒸', 'd':'𝒹', 'e':'ℯ', 
            'f':'𝒻', 'g':'ℊ', 'h':'𝒽', 'i':'𝒾', 'j':'𝒿', 
            'k':'𝓀', 'l':'𝓁', 'm':'𝓂', 'n':'𝓃', 'o':'ℴ', 
            'p':'𝓅', 'q':'𝓆', 'r':'𝓇', 's':'𝓈', 't':'𝓉', 
            'u':'𝓊', 'v':'𝓋', 'w':'𝓌', 'x':'𝓍', 'y':'𝓎', 'z':'𝓏',
            'A':'𝒜', 'B':'𝐵', 'C':'𝒞', 'D':'𝒟', 'E':'𝐸', 
            'F':'𝐹', 'G':'𝒢', 'H':'𝐻', 'I':'𝐼', 'J':'𝒥', 
            'K':'𝒦', 'L':'𝐿', 'M':'𝑀', 'N':'𝒩', 'O':'𝒪', 
            'P':'𝒫', 'Q':'𝒬', 'R':'𝑅', 'S':'𝒮', 'T':'𝒯', 
            'U':'𝒰', 'V':'𝒱', 'W':'𝒲', 'X':'𝒳', 'Y':'𝒴', 'Z':'𝒵'
        },
        'monospace': {
            'a':'𝚊', 'b':'𝚋', 'c':'𝚌', 'd':'𝚍', 'e':'𝚎', 
            'f':'𝚏', 'g':'𝚐', 'h':'𝚑', 'i':'𝚒', 'j':'𝚓', 
            'k':'𝚔', 'l':'𝚕', 'm':'𝚖', 'n':'𝚗', 'o':'𝚘', 
            'p':'𝚙', 'q':'𝚚', 'r':'𝚛', 's':'𝚜', 't':'𝚝', 
            'u':'𝚞', 'v':'𝚟', 'w':'𝚠', 'x':'𝚡', 'y':'𝚢', 'z':'𝚣',
            'A':'𝙰', 'B':'𝙱', 'C':'𝙲', 'D':'𝙳', 'E':'𝙴', 
            'F':'𝙵', 'G':'𝙶', 'H':'𝙷', 'I':'𝙸', 'J':'𝙹', 
            'K':'𝙺', 'L':'𝙻', 'M':'𝙼', 'N':'𝙽', 'O':'𝙾', 
            'P':'𝙿', 'Q':'𝚀', 'R':'𝚁', 'S':'𝚂', 'T':'𝚃', 
            'U':'𝚄', 'V':'𝚅', 'W':'𝚆', 'X':'𝚇', 'Y':'𝚈', 'Z':'𝚉'
        },
        'rounded': {
            'a':'ａ', 'b':'ｂ', 'c':'ｃ', 'd':'ｄ', 'e':'ｅ', 
            'f':'ｆ', 'g':'ｇ', 'h':'ｈ', 'i':'ｉ', 'j':'ｊ', 
            'k':'ｋ', 'l':'ｌ', 'm':'ｍ', 'n':'ｎ', 'o':'ｏ', 
            'p':'ｐ', 'q':'ｑ', 'r':'ｒ', 's':'ｓ', 't':'ｔ', 
            'u':'ｕ', 'v':'ｖ', 'w':'ｗ', 'x':'ｘ', 'y':'ｙ', 'z':'ｚ',
            'A':'Ａ', 'B':'Ｂ', 'C':'Ｃ', 'D':'Ｄ', 'E':'Ｅ', 
            'F':'Ｆ', 'G':'Ｇ', 'H':'Ｈ', 'I':'Ｉ', 'J':'Ｊ', 
            'K':'Ｋ', 'L':'Ｌ', 'M':'Ｍ', 'N':'Ｎ', 'O':'Ｏ', 
            'P':'Ｐ', 'Q':'Ｑ', 'R':'Ｒ', 'S':'Ｓ', 'T':'Ｔ', 
            'U':'Ｕ', 'V':'Ｖ', 'W':'Ｗ', 'X':'Ｘ', 'Y':'Ｙ', 'Z':'Ｚ'
        },
        'math': {
            'a':'𝕒', 'b':'𝕓', 'c':'𝕔', 'd':'𝕕', 'e':'𝕖', 
            'f':'𝕗', 'g':'𝕘', 'h':'𝕙', 'i':'𝕚', 'j':'𝕛', 
            'k':'𝕜', 'l':'𝕝', 'm':'𝕞', 'n':'𝕟', 'o':'𝕠', 
            'p':'𝕡', 'q':'𝕢', 'r':'𝕣', 's':'𝕤', 't':'𝕥', 
            'u':'𝕦', 'v':'𝕧', 'w':'𝕨', 'x':'𝕩', 'y':'𝕪', 'z':'𝕫',
            'A':'𝔸', 'B':'𝔹', 'C':'ℂ', 'D':'𝔻', 'E':'𝔼', 
            'F':'𝔽', 'G':'𝔾', 'H':'ℍ', 'I':'𝕀', 'J':'𝕁', 
            'K':'𝕂', 'L':'𝕃', 'M':'𝕄', 'N':'ℕ', 'O':'𝕆', 
            'P':'ℙ', 'Q':'ℚ', 'R':'ℝ', 'S':'𝕊', 'T':'𝕋', 
            'U':'𝕌', 'V':'𝕍', 'W':'𝕎', 'X':'𝕏', 'Y':'𝕐', 'Z':'ℤ'
        }
    }
    
    font_map = font_maps.get(style, font_maps['default'])
    converted_text = ''.join(font_map.get(char, char) for char in text)
    
    return converted_text
EOF

# 创建主脚本
cat > $WORK_DIR/time_username.py << 'EOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import pytz
from datetime import datetime
from telethon import TelegramClient, functions
import asyncio
import logging
import sys
import importlib.util

# 动态导入字体转换模块
spec = importlib.util.spec_from_file_location("font_converter", "/opt/telegram-time/font_converter.py")
font_converter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(font_converter)

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s: %(message)s',
    handlers=[
        logging.FileHandler("/opt/telegram-time/telegram_time.log"),
        logging.StreamHandler(sys.stdout)
    ]
)

# 配置参数（请在首次运行时手动修改）
API_ID = 'YOUR_API_ID'
API_HASH = 'YOUR_API_HASH'
TIMEZONE = pytz.timezone('Asia/Shanghai')
ICON = '⌚️'
TIME_FORMAT = '%H:%M'
FONT_STYLE = 'default'
UPDATE_FREQUENCY = 60

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

# 设置文件权限
chmod +x $WORK_DIR/time_username.py
chmod +x $WORK_DIR/font_converter.py

# 重新加载服务
systemctl daemon-reload

# 完成提示
echo -e "\n${GREEN}✅ 安装完成！${NC}"
echo -e "${YELLOW}使用说明:${NC}"
echo -e "1. 编辑 $WORK_DIR/time_username.py"
echo -e "   修改 API_ID 和 API_HASH 为您的 Telegram API 凭据"
echo -e "2. 首次运行请执行: ${BLUE}cd $WORK_DIR && python3 time_username.py${NC}"
echo -e "3. 登录成功后，按 Ctrl+C 停止"
echo -e "4. 启动服务: ${BLUE}systemctl start telegram-time${NC}"
echo -e "5. 查看服务状态: ${BLUE}systemctl status telegram-time${NC}"
echo -e "6. 查看日志: ${BLUE}tail -f $WORK_DIR/telegram_time.log${NC}"
