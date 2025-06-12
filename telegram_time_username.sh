#!/bin/bash
# Telegram自动更新时间用户名安装脚本 - 完整版
# 作者: Claude
# 版本: 3.0 - 完整功能版本

# 设置颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # 恢复默认颜色

# 检查是否为root用户运行
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ 请使用root权限运行此脚本${NC}"
    echo "例如: sudo bash $0"
    exit 1
fi

# 显示欢迎界面
clear
echo -e "${CYAN}┌─────────────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│                                                                                 │${NC}"
echo -e "${CYAN}│     🕐 Telegram 时间用户名更新器 v3.0 - 完整版 🕐                            │${NC}"
echo -e "${CYAN}│                                                                                 │${NC}"
echo -e "${CYAN}│              ✨ 支持多种字体样式 + 完善错误处理 ✨                          │${NC}"
echo -e "${CYAN}│                                                                                 │${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────────────────────────────────────┘${NC}"
echo ""
echo -e "${WHITE}功能特色:${NC}"
echo -e "${GREEN}• 🎨 10种精美字体样式${NC}"
echo -e "${GREEN}• ⏰ 5种时间显示格式${NC}"
echo -e "${GREEN}• 😊 8种可爱emoji选择${NC}"
echo -e "${GREEN}• 🔧 完善的错误处理和日志${NC}"
echo -e "${GREEN}• 🚀 自动重连和故障恢复${NC}"
echo -e "${GREEN}• 📊 实时状态监控${NC}"
echo ""

# 安装依赖项
echo -e "${YELLOW}📦 正在安装必要的依赖项...${NC}"
apt update > /dev/null 2>&1
if apt install -y python3 python3-pip curl wget > /dev/null 2>&1; then
    echo -e "${GREEN}✅ 系统依赖安装成功${NC}"
else
    echo -e "${RED}❌ 系统依赖安装失败${NC}"
    exit 1
fi

# 安装Python依赖
echo -e "${YELLOW}🐍 安装Python依赖...${NC}"
if pip3 install --break-system-packages telethon pytz colorama > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Python依赖安装成功${NC}"
else
    echo -e "${RED}❌ Python依赖安装失败${NC}"
    exit 1
fi

# 创建工作目录
WORK_DIR="/opt/telegram-time"
echo -e "${YELLOW}📁 创建工作目录: $WORK_DIR${NC}"
mkdir -p $WORK_DIR

# 交互式获取API凭据
echo ""
echo -e "${GREEN}🔑 请输入您的Telegram API凭据${NC}"
echo -e "${CYAN}您可以从 https://my.telegram.org/apps 获取${NC}"
echo -e "${YELLOW}💡 提示: API ID是纯数字，API Hash是32位字符串${NC}"
echo ""
while true; do
    read -p "API ID: " API_ID
    if [[ "$API_ID" =~ ^[0-9]+$ ]]; then
        break
    else
        echo -e "${RED}❌ API ID应该是纯数字，请重新输入${NC}"
    fi
done

while true; do
    read -p "API Hash: " API_HASH
    if [[ ${#API_HASH} -eq 32 ]]; then
        break
    else
        echo -e "${RED}❌ API Hash应该是32位字符串，请重新输入${NC}"
    fi
done

# 选择字体样式
echo ""
echo -e "${GREEN}🎨 请选择字体样式${NC}"
echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${PURPLE}1)  𝟐𝟐:𝟎𝟓 𝐁𝐫𝐲𝐚𝐧𝐧𝐚 💕 ${CYAN}(数学粗体 - 推荐)${NC}"
echo -e "${PURPLE}2)  𝟐𝟐:𝟎𝟓 𝘽𝙧𝙮𝙖𝙣𝙣𝙖 💕 ${CYAN}(数学无衬线粗体)${NC}"
echo -e "${PURPLE}3)  𝟐𝟐:𝟎𝟓 𝒷𝓇𝓎𝒶𝓃𝓃𝒶 💕 ${CYAN}(数学手写体)${NC}"
echo -e "${PURPLE}4)  𝟐𝟐:𝟎𝟓 𝐵𝓇𝓎𝒶𝓃𝓃𝒶 💕 ${CYAN}(数学粗手写体)${NC}"
echo -e "${PURPLE}5)  𝟐𝟐:𝟎𝟓 𝓑𝓻𝔂𝓪𝓷𝓷𝓪 💕 ${CYAN}(数学Fraktur)${NC}"
echo -e "${PURPLE}6)  𝟐𝟐:𝟎𝟓 𝖡𝗋𝗒𝖺𝗇𝗇𝖺 💕 ${CYAN}(数学无衬线)${NC}"
echo -e "${PURPLE}7)  𝟐𝟐:𝟎𝟓 𝘉𝘳𝘺𝘢𝘯𝘯𝘢 💕 ${CYAN}(数学斜体)${NC}"
echo -e "${PURPLE}8)  𝟐𝟐:𝟎𝟓 𝕭𝖗𝖞𝖆𝖓𝖓𝖆 💕 ${CYAN}(数学双线)${NC}"
echo -e "${PURPLE}9)  𝟐𝟐:𝟎𝟓 𝙱𝚛𝚢𝚊𝚗𝚗𝚊 💕 ${CYAN}(等宽字体)${NC}"
echo -e "${PURPLE}10) 22:05 Bryanna 💕 ${CYAN}(普通字体)${NC}"
echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

while true; do
    read -p "选择字体 [1-10]: " FONT_CHOICE
    case $FONT_CHOICE in
        1) FONT_TYPE="math_bold"; break ;;
        2) FONT_TYPE="math_sans_bold"; break ;;
        3) FONT_TYPE="math_script"; break ;;
        4) FONT_TYPE="math_bold_script"; break ;;
        5) FONT_TYPE="math_fraktur"; break ;;
        6) FONT_TYPE="math_sans"; break ;;
        7) FONT_TYPE="math_italic"; break ;;
        8) FONT_TYPE="math_double"; break ;;
        9) FONT_TYPE="monospace"; break ;;
        10) FONT_TYPE="normal"; break ;;
        *)
            echo -e "${RED}❌ 请输入1-10之间的数字${NC}"
            continue
            ;;
    esac
done

echo -e "${GREEN}✅ 已选择字体样式${NC}"

# 选择时区
echo ""
echo -e "${GREEN}🌍 请选择时区${NC}"
echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "1) 🇨🇳 亚洲/上海 (中国时间 GMT+8)"
echo "2) 🇭🇰 亚洲/香港 (香港时间 GMT+8)"
echo "3) 🇸🇬 亚洲/新加坡 (新加坡时间 GMT+8)"
echo "4) 🇺🇸 美国/东部 (EST GMT-5)"
echo "5) 🇺🇸 美国/西部 (PST GMT-8)"
echo "6) 🇬🇧 欧洲/伦敦 (GMT+0)"
echo "7) 🇯🇵 亚洲/东京 (JST GMT+9)"
echo "8) 自定义时区"
echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

while true; do
    read -p "选择时区 [1-8]: " TIMEZONE_CHOICE
    case $TIMEZONE_CHOICE in
        1) TIMEZONE="Asia/Shanghai"; break ;;
        2) TIMEZONE="Asia/Hong_Kong"; break ;;
        3) TIMEZONE="Asia/Singapore"; break ;;
        4) TIMEZONE="America/New_York"; break ;;
        5) TIMEZONE="America/Los_Angeles"; break ;;
        6) TIMEZONE="Europe/London"; break ;;
        7) TIMEZONE="Asia/Tokyo"; break ;;
        8) 
            echo "请输入有效的时区名称 (例如: Asia/Seoul, Europe/Paris):"
            read -p "时区: " TIMEZONE
            break
            ;;
        *)
            echo -e "${RED}❌ 请输入1-8之间的数字${NC}"
            continue
            ;;
    esac
done

echo -e "${GREEN}✅ 已选择时区: $TIMEZONE${NC}"

# 选择时间格式
echo ""
echo -e "${GREEN}⏰ 请选择时间格式${NC}"
echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "1) 24小时制 (例如: 22:05)"
echo "2) 12小时制 (例如: 10:05 PM)"
echo "3) 带日期 (例如: 12-06 22:05)"
echo "4) 带星期 (例如: 周四 22:05)"
echo "5) 带秒显示 (例如: 22:05:30)"
echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

while true; do
    read -p "选择时间格式 [1-5]: " FORMAT_CHOICE
    case $FORMAT_CHOICE in
        1|2|3|4|5) TIME_FORMAT=$FORMAT_CHOICE; break ;;
        *)
            echo -e "${RED}❌ 请输入1-5之间的数字${NC}"
            continue
            ;;
    esac
done

echo -e "${GREEN}✅ 已选择时间格式${NC}"

# 输入用户名
echo ""
echo -e "${GREEN}👤 请输入您的用户名${NC}"
echo -e "${YELLOW}💡 提示: 用户名将显示在时间后面，建议使用英文或特殊字符${NC}"
while true; do
    read -p "用户名: " USERNAME
    if [[ -n "$USERNAME" ]]; then
        break
    else
        echo -e "${RED}❌ 用户名不能为空，请重新输入${NC}"
    fi
done

echo -e "${GREEN}✅ 用户名: $USERNAME${NC}"

# 选择emoji
echo ""
echo -e "${GREEN}😊 请选择emoji装饰${NC}"
echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "1) 💕 爱心"
echo "2) 💖 闪亮心"
echo "3) 🌸 樱花"
echo "4) ✨ 星星"
echo "5) 🎀 蝴蝶结"
echo "6) 💫 彗星"
echo "7) 🌟 亮星"
echo "8) 🦄 独角兽"
echo "9) 🌙 月亮"
echo "10) 不使用emoji"
echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

while true; do
    read -p "选择emoji [1-10]: " EMOJI_CHOICE
    case $EMOJI_CHOICE in
        1) EMOJI="💕"; break ;;
        2) EMOJI="💖"; break ;;
        3) EMOJI="🌸"; break ;;
        4) EMOJI="✨"; break ;;
        5) EMOJI="🎀"; break ;;
        6) EMOJI="💫"; break ;;
        7) EMOJI="🌟"; break ;;
        8) EMOJI="🦄"; break ;;
        9) EMOJI="🌙"; break ;;
        10) EMOJI=""; break ;;
        *)
            echo -e "${RED}❌ 请输入1-10之间的数字${NC}"
            continue
            ;;
    esac
done

if [[ -n "$EMOJI" ]]; then
    echo -e "${GREEN}✅ 已选择emoji: $EMOJI${NC}"
else
    echo -e "${GREEN}✅ 不使用emoji${NC}"
fi

# 选择更新频率
echo ""
echo -e "${GREEN}⚡ 请选择更新频率${NC}"
echo -e "${YELLOW}⚠️  警告: 频繁更新可能导致Telegram账号受限${NC}"
echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "1) 每分钟 (推荐，安全)"
echo "2) 每5分钟 (安全)"
echo "3) 每小时 (最安全)"
echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

while true; do
    read -p "选择更新频率 [1-3]: " FREQ_CHOICE
    case $FREQ_CHOICE in
        1) UPDATE_FREQ=60; break ;;
        2) UPDATE_FREQ=300; break ;;
        3) UPDATE_FREQ=3600; break ;;
        *)
            echo -e "${RED}❌ 请输入1-3之间的数字${NC}"
            continue
            ;;
    esac
done

echo -e "${GREEN}✅ 更新频率设置完成${NC}"

# 显示配置摘要
echo ""
echo -e "${CYAN}📋 配置摘要${NC}"
echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}API ID:${NC} $API_ID"
echo -e "${BLUE}API Hash:${NC} ${API_HASH:0:8}****"
echo -e "${BLUE}时区:${NC} $TIMEZONE"
echo -e "${BLUE}字体:${NC} $FONT_TYPE"
echo -e "${BLUE}时间格式:${NC} $TIME_FORMAT"
echo -e "${BLUE}用户名:${NC} $USERNAME"
echo -e "${BLUE}Emoji:${NC} $EMOJI"
echo -e "${BLUE}更新频率:${NC} $UPDATE_FREQ 秒"
echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo ""
read -p "确认配置是否正确？(y/n): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo -e "${YELLOW}🔄 重新运行脚本进行配置${NC}"
    exit 0
fi

# 创建完整的Python脚本
echo -e "${YELLOW}📝 创建Python脚本...${NC}"
cat > $WORK_DIR/time_username.py << 'EOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Telegram时间用户名自动更新器 - 完整版
作者: Claude
版本: 3.0
"""

from telethon import TelegramClient, functions, types
from telethon.errors import FloodWaitError, SessionPasswordNeededError, PhoneCodeInvalidError
import asyncio
import time
import logging
import os
import sys
import signal
from datetime import datetime, timedelta
import pytz
import json
import traceback
from pathlib import Path

# 配置文件路径
CONFIG_FILE = os.path.join(os.path.dirname(__file__), 'config.json')
LOG_FILE = os.path.join(os.path.dirname(__file__), 'time_username.log')
SESSION_FILE = os.path.join(os.path.dirname(__file__), 'time_username_session')

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(LOG_FILE, encoding='utf-8'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

# 全局变量
client = None
running = True
last_update_time = None
update_count = 0
error_count = 0

# 星期几的中文表示
weekday_cn = ['一', '二', '三', '四', '五', '六', '日']

class TelegramTimeUpdater:
    def __init__(self, config):
        self.config = config
        self.timezone = pytz.timezone(config['timezone'])
        self.client = None
        self.running = True
        self.stats = {
            'start_time': datetime.now(),
            'total_updates': 0,
            'successful_updates': 0,
            'failed_updates': 0,
            'last_update': None,
            'last_error': None
        }
    
    def convert_to_font(self, text, font_type):
        """将文本转换为指定字体"""
        if font_type == "normal":
            return text
        
        # 数字映射
        normal_digits = "0123456789"
        math_bold_digits = "𝟎𝟏𝟐𝟑𝟒𝟓𝟔𝟕𝟖𝟗"
        
        # 字母映射
        normal_letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        
        font_maps = {
            "math_bold": "𝐀𝐁𝐂𝐃𝐄𝐅𝐆𝐇𝐈𝐉𝐊𝐋𝐌𝐍𝐎𝐏𝐐𝐑𝐒𝐓𝐔𝐕𝐖𝐗𝐘𝐙𝐚𝐛𝐜𝐝𝐞𝐟𝐠𝐡𝐢𝐣𝐤𝐥𝐦𝐧𝐨𝐩𝐪𝐫𝐬𝐭𝐮𝐯𝐰𝐱𝐲𝐳",
            "math_sans_bold": "𝗔𝗕𝗖𝗗𝗘𝗙𝗚𝗛𝗜𝗝𝗞𝗟𝗠𝗡𝗢𝗣𝗤𝗥𝗦𝗧𝗨𝗩𝗪𝗫𝗬𝗭𝗮𝗯𝗰𝗱𝗲𝗳𝗴𝗵𝗶𝗷𝗸𝗹𝗺𝗻𝗼𝗽𝗾𝗿𝘀𝘁𝘂𝘃𝘄𝘅𝘆𝘇",
            "math_script": "𝒜𝐵𝒞𝒟𝐸𝐹𝒢𝐻𝐼𝒥𝒦𝐿𝑀𝒩𝒪𝒫𝒬𝑅𝒮𝒯𝒰𝒱𝒲𝒳𝒴𝒵𝒶𝒷𝒸𝒹𝑒𝒻𝑔𝒽𝒾𝒿𝓀𝓁𝓂𝓃𝑜𝓅𝓆𝓇𝓈𝓉𝓊𝓋𝓌𝓍𝓎𝓏",
            "math_bold_script": "𝓐𝓑𝓒𝓓𝓔𝓕𝓖𝓗𝓘𝓙𝓚𝓛𝓜𝓝𝓞𝓟𝓠𝓡𝓢𝓣𝓤𝓥𝓦𝓧𝓨𝓩𝓪𝓫𝓬𝓭𝓮𝓯𝓰𝓱𝓲𝓳𝓴𝓵𝓶𝓷𝓸𝓹𝓺𝓻𝓼𝓽𝓾𝓿𝔀𝔁𝔂𝔃",
            "math_fraktur": "𝔄𝔅ℭ𝔇𝔈𝔉𝔊ℌℑ𝔍𝔎𝔏𝔐𝔑𝔒𝔓𝔔ℜ𝔖𝔗𝔘𝔙𝔚𝔛𝔜ℨ𝔞𝔟𝔠𝔡𝔢𝔣𝔤𝔥𝔦𝔧𝔨𝔩𝔪𝔫𝔬𝔭𝔮𝔯𝔰𝔱𝔲𝔳𝔴𝔵𝔶𝔷",
            "math_sans": "𝖠𝖡𝖢𝖣𝖤𝖥𝖦𝖧𝖨𝖩𝖪𝖫𝖬𝖭𝖮𝖯𝖰𝖱𝖲𝖳𝖴𝖵𝖶𝖷𝖸𝖹𝖺𝖻𝖼𝖽𝖾𝖿𝗀𝗁𝗂𝗃𝗄𝗅𝗆𝗇𝗈𝗉𝗊𝗋𝗌𝗍𝗎𝗏𝗐𝗑𝗒𝗓",
            "math_italic": "𝘈𝘉𝘊𝘋𝘌𝘍𝘎𝘏𝘐𝘑𝘒𝘓𝘔𝘕𝘖𝘗𝘘𝘙𝘚𝘛𝘜𝘝𝘞𝘟𝘠𝘡𝘢𝘣𝘤𝘥𝘦𝘧𝘨𝘩𝘪𝘫𝘬𝘭𝘮𝘯𝘰𝘱𝘲𝘳𝘴𝘵𝘶𝘷𝘸𝘹𝘺𝘻",
            "math_double": "𝔸𝔹ℂ𝔻𝔼𝔽𝔾ℍ𝕀𝕁𝕂𝕃𝕄ℕ𝕆ℙℚℝ𝕊𝕋𝕌𝕍𝕎𝕏𝕐ℤ𝕒𝕓𝕔𝕕𝕖𝕗𝕘𝕙𝕚𝕛𝕜𝕝𝕞𝕠𝕡𝕢𝕣𝕤𝕥𝕦𝕧𝕨𝕩𝕪𝕫",
            "monospace": "𝙰𝙱𝙲𝙳𝙴𝙵𝙶𝙷𝙸𝙹𝙺𝙻𝙼𝙽𝙾𝙿𝚀𝚁𝚂𝚃𝚄𝚅𝚆𝚇𝚈𝚉𝚊𝚋𝚌𝚍𝚎𝚏𝚐𝚑𝚒𝚓𝚔𝚕𝚖𝚗𝚘𝚙𝚚𝚛𝚜𝚝𝚞𝚟𝚠𝚡𝚢𝚣"
        }
        
        result = text
        
        # 转换数字
        for i, digit in enumerate(normal_digits):
            result = result.replace(digit, math_bold_digits[i])
        
        # 转换字母
        if font_type in font_maps:
            font_letters = font_maps[font_type]
            for i, letter in enumerate(normal_letters):
                result = result.replace(letter, font_letters[i])
        
        return result

    def get_time_username(self):
        """生成时间用户名"""
        now = datetime.now(self.timezone)
        
        # 获取时间部分
        time_format = self.config['time_format']
        if time_format == 1:  # 24小时制
            time_part = now.strftime('%H:%M')
        elif time_format == 2:  # 12小时制
            time_part = now.strftime('%I:%M %p')
        elif time_format == 3:  # 带日期
            time_part = f"{now.strftime('%m-%d')} {now.strftime('%H:%M')}"
        elif time_format == 4:  # 带星期
            weekday = weekday_cn[now.weekday()]
            time_part = f"周{weekday} {now.strftime('%H:%M')}"
        elif time_format == 5:  # 带秒显示
            time_part = now.strftime('%H:%M:%S')
        else:
            time_part = now.strftime('%H:%M')
        
        # 构建完整用户名：时间在前
        username = self.config['username']
        emoji = self.config.get('emoji', '')
        
        if emoji:
            full_name = f"{time_part} {username} {emoji}"
        else:
            full_name = f"{time_part} {username}"
        
        # 应用字体转换
        styled_name = self.convert_to_font(full_name, self.config['font_type'])
        
        return styled_name

    async def connect(self):
        """连接到Telegram"""
        try:
            self.client = TelegramClient(
                SESSION_FILE, 
                self.config['api_id'], 
                self.config['api_hash']
            )
            
            await self.client.start()
            logger.info("✅ 已连接到Telegram")
            
            me = await self.client.get_me()
            logger.info(f"👤 当前账号: {me.first_name} (@{me.username or 'N/A'})")
            logger.info(f"📱 手机号: +{me.phone}")
            
            return True
            
        except SessionPasswordNeededError:
            logger.error("🔐 账号设置了两步验证，需要输入密码")
            return False
        except Exception as e:
            logger.error(f"💥 连接失败: {str(e)}")
            return False

    async def update_username_once(self):
        """执行一次用户名更新"""
        try:
            new_username = self.get_time_username()
            
            # 记录更新前状态
            me = await self.client.get_me()
            old_name = me.first_name
            
            if old_name == new_username:
                logger.info(f"🔄 用户名无需更新: {new_username}")
                return True
            
            logger.info(f"🔄 准备更新用户名: {old_name} → {new_username}")
            
            # 更新用户名
            await self.client(functions.account.UpdateProfileRequest(
                first_name=new_username
            ))
            
            # 验证更新是否成功
            me_updated = await self.client.get_me()
            if me_updated.first_name == new_username:
                logger.info(f"✅ 用户名更新成功: {new_username}")
                self.stats['successful_updates'] += 1
                self.stats['last_update'] = datetime.now()
                return True
            else:
                logger.warning(f"⚠️ 用户名更新可能失败，当前名称: {me_updated.first_name}")
                return False
                
        except FloodWaitError as e:
            wait_time = e.seconds
            logger.warning(f"⚠️ 触发频率限制，需要等待 {wait_time} 秒")
            self.stats['last_error'] = f"FloodWait: {wait_time}s"
            await asyncio.sleep(wait_time)
            return False
            
        except Exception as e:
            error_msg = str(e)
            logger.error(f"❌ 更新失败: {error_msg}")
            self.stats['failed_updates'] += 1
            self.stats['last_error'] = error_msg
            
            # 处理常见错误
            if "FIRSTNAME_INVALID" in error_msg:
                logger.error("🚫 用户名格式无效，可能包含不支持的字符")
            elif "flood" in error_msg.lower():
                logger.warning("⚠️ 触发API频率限制")
            elif "session" in error_msg.lower():
                logger.error("🔐 Session失效，需要重新登录")
                return None  # 需要重新连接
            
            return False

    async def run_update_loop(self):
        """运行更新循环"""
        logger.info("🚀 开始时间更新循环")
        consecutive_errors = 0
        max_consecutive_errors = 5
        
        while self.running:
            try:
                self.stats['total_updates'] += 1
                
                # 执行更新
                result = await self.update_username_once()
                
                if result is None:  # 需要重新连接
                    logger.warning("🔄 尝试重新连接...")
                    if await self.connect():
                        continue
                    else:
                        logger.error("💥 重新连接失败，程序退出")
                        break
                
                if result:
                    consecutive_errors = 0
                else:
                    consecutive_errors += 1
                    
                # 如果连续错误太多，增加等待时间
                if consecutive_errors >= max_consecutive_errors:
                    wait_time = min(300, consecutive_errors * 60)  # 最多等待5分钟
                    logger.warning(f"⚠️ 连续错误 {consecutive_errors} 次，等待 {wait_time} 秒")
                    await asyncio.sleep(wait_time)
                    consecutive_errors = 0
                    continue
                
                # 计算下次更新时间
                wait_time = self.config['update_frequency']
                if wait_time == 60:
                    # 如果是每分钟更新，对齐到整分钟
                    now = datetime.now()
                    wait_time = 60 - now.second
                
                # 显示统计信息
                if self.stats['total_updates'] % 10 == 0:
                    self.log_statistics()
                
                logger.info(f"⏰ 等待 {wait_time} 秒后再次更新")
                await asyncio.sleep(wait_time)
                
            except KeyboardInterrupt:
                logger.info("🛑 收到停止信号")
                break
            except Exception as e:
                logger.error(f"💥 更新循环出错: {str(e)}")
                logger.error(f"🔍 错误详情: {traceback.format_exc()}")
                await asyncio.sleep(60)

    def log_statistics(self):
        """记录统计信息"""
        uptime = datetime.now() - self.stats['start_time']
        success_rate = 0
        if self.stats['total_updates'] > 0:
            success_rate = (self.stats['successful_updates'] / self.stats['total_updates']) * 100
        
        logger.info(f"📊 统计信息 - 运行时间: {uptime}, 总更新: {self.stats['total_updates']}, "
                   f"成功: {self.stats['successful_updates']}, 失败: {self.stats['failed_updates']}, "
                   f"成功率: {success_rate:.1f}%")

    async def disconnect(self):
        """断开连接"""
        if self.client:
            await self.client.disconnect()
            logger.info("👋 已断开Telegram连接")

    def stop(self):
        """停止运行"""
        self.running = False
        logger.info("🛑 收到停止信号")


def load_config():
    """加载配置文件"""
    try:
        with open(CONFIG_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    except FileNotFoundError:
        logger.error(f"❌ 配置文件不存在: {CONFIG_FILE}")
        return None
    except json.JSONDecodeError as e:
        logger.error(f"❌ 配置文件格式错误: {e}")
        return None


def save_config(config):
    """保存配置文件"""
    try:
        with open(CONFIG_FILE, 'w', encoding='utf-8') as f:
            json.dump(config, f, ensure_ascii=False, indent=2)
        return True
    except Exception as e:
        logger.error(f"❌ 保存配置文件失败: {e}")
        return False


def signal_handler(signum, frame):
    """信号处理器"""
    global updater
    logger.info(f"🔔 收到信号 {signum}")
    if updater:
        updater.stop()


async def main():
    """主函数"""
    global updater
    
    # 设置信号处理器
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    logger.info("🎯 Telegram时间用户名更新器启动")
    
    # 加载配置
    config = load_config()
    if not config:
        logger.error("💥 无法加载配置，程序退出")
        return
    
    # 创建更新器
    updater = TelegramTimeUpdater(config)
    
    try:
        # 连接到Telegram
        if not await updater.connect():
            logger.error("💥 无法连接到Telegram，程序退出")
            return
        
        # 运行更新循环
        await updater.run_update_loop()
        
    except Exception as e:
        logger.error(f"💥 程序异常: {str(e)}")
        logger.error(f"🔍 错误详情: {traceback.format_exc()}")
    finally:
        # 清理资源
        await updater.disconnect()
        updater.log_statistics()
        logger.info("👋 程序结束")


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        logger.info("🛑 程序被用户中断")
    except Exception as e:
        logger.error(f"💥 程序启动失败: {str(e)}")
EOF

# 将配置写入配置文件
echo -e "${YELLOW}💾 保存配置文件...${NC}"
cat > $WORK_DIR/config.json << EOF
{
  "api_id": "$API_ID",
  "api_hash": "$API_HASH",
  "timezone": "$TIMEZONE",
  "font_type": "$FONT_TYPE",
  "time_format": $TIME_FORMAT,
  "username": "$USERNAME",
  "emoji": "$EMOJI",
  "update_frequency": $UPDATE_FREQ
}
EOF

# 设置权限
chmod +x $WORK_DIR/time_username.py
chmod 600 $WORK_DIR/config.json

# 创建管理脚本
echo -e "${YELLOW}🛠️ 创建管理脚本...${NC}"
cat > $WORK_DIR/manage.sh << 'EOF'
#!/bin/bash
# Telegram时间更新器管理脚本

WORK_DIR="/opt/telegram-time"
SERVICE_NAME="telegram-time"

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

show_status() {
    echo -e "${BLUE}📊 服务状态${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    systemctl status $SERVICE_NAME --no-pager -l
    echo ""
    
    echo -e "${BLUE}📋 最近日志${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    tail -n 10 $WORK_DIR/time_username.log
}

show_logs() {
    echo -e "${BLUE}📜 实时日志 (按 Ctrl+C 退出)${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    tail -f $WORK_DIR/time_username.log
}

start_service() {
    echo -e "${YELLOW}🚀 启动服务...${NC}"
    systemctl start $SERVICE_NAME
    sleep 2
    if systemctl is-active --quiet $SERVICE_NAME; then
        echo -e "${GREEN}✅ 服务启动成功${NC}"
    else
        echo -e "${RED}❌ 服务启动失败${NC}"
    fi
}

stop_service() {
    echo -e "${YELLOW}🛑 停止服务...${NC}"
    systemctl stop $SERVICE_NAME
    sleep 2
    if ! systemctl is-active --quiet $SERVICE_NAME; then
        echo -e "${GREEN}✅ 服务已停止${NC}"
    else
        echo -e "${RED}❌ 服务停止失败${NC}"
    fi
}

restart_service() {
    echo -e "${YELLOW}🔄 重启服务...${NC}"
    systemctl restart $SERVICE_NAME
    sleep 2
    if systemctl is-active --quiet $SERVICE_NAME; then
        echo -e "${GREEN}✅ 服务重启成功${NC}"
    else
        echo -e "${RED}❌ 服务重启失败${NC}"
    fi
}

test_script() {
    echo -e "${YELLOW}🧪 测试脚本...${NC}"
    cd $WORK_DIR
    python3 time_username.py
}

show_config() {
    echo -e "${BLUE}⚙️ 当前配置${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat $WORK_DIR/config.json | python3 -m json.tool
}

show_menu() {
    clear
    echo -e "${BLUE}┌─────────────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│                     🕐 Telegram时间更新器管理工具 🕐                          │${NC}"
    echo -e "${BLUE}└─────────────────────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo "1) 📊 查看状态"
    echo "2) 📜 查看实时日志"
    echo "3) 🚀 启动服务"
    echo "4) 🛑 停止服务"
    echo "5) 🔄 重启服务"
    echo "6) 🧪 测试脚本"
    echo "7) ⚙️ 查看配置"
    echo "8) 🚪 退出"
    echo ""
}

case "$1" in
    status) show_status ;;
    logs) show_logs ;;
    start) start_service ;;
    stop) stop_service ;;
    restart) restart_service ;;
    test) test_script ;;
    config) show_config ;;
    *)
        while true; do
            show_menu
            read -p "请选择操作 [1-8]: " choice
            case $choice in
                1) show_status; read -p "按回车继续..." ;;
                2) show_logs ;;
                3) start_service; read -p "按回车继续..." ;;
                4) stop_service; read -p "按回车继续..." ;;
                5) restart_service; read -p "按回车继续..." ;;
                6) test_script; read -p "按回车继续..." ;;
                7) show_config; read -p "按回车继续..." ;;
                8) echo "👋 再见！"; exit 0 ;;
                *) echo -e "${RED}❌ 无效选择${NC}"; sleep 1 ;;
            esac
        done
        ;;
esac
EOF

chmod +x $WORK_DIR/manage.sh

# 创建系统服务
echo -e "${YELLOW}⚙️ 创建系统服务...${NC}"
cat > /etc/systemd/system/telegram-time.service << EOF
[Unit]
Description=Telegram Time Username Updater v3.0
Documentation=https://github.com/telegram-time-updater
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 $WORK_DIR/time_username.py
WorkingDirectory=$WORK_DIR
Restart=always
RestartSec=30
User=root
Environment=PYTHONUNBUFFERED=1
StandardOutput=journal
StandardError=journal
KillMode=mixed
KillSignal=SIGTERM
TimeoutStopSec=30

# 安全设置
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ReadWritePaths=$WORK_DIR

[Install]
WantedBy=multi-user.target
EOF

# 创建日志轮转配置
echo -e "${YELLOW}📋 配置日志轮转...${NC}"
cat > /etc/logrotate.d/telegram-time << EOF
$WORK_DIR/time_username.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 root root
    postrotate
        systemctl reload telegram-time 2>/dev/null || true
    endscript
}
EOF

# 重新加载systemd并启用服务
systemctl daemon-reload
systemctl enable telegram-time

# 创建快捷命令
echo 'alias tg-time="/opt/telegram-time/manage.sh"' >> /root/.bashrc

# 显示完成信息
echo ""
echo -e "${GREEN}🎉🎉🎉 安装完成！🎉🎉🎉${NC}"
echo ""
echo -e "${CYAN}┌─────────────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│                              📋 使用指南 📋                                    │${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────────────────────────────────────┘${NC}"
echo ""
echo -e "${WHITE}🚀 快速开始:${NC}"
echo -e "${BLUE}   1. 首次登录: ${GREEN}cd $WORK_DIR && python3 time_username.py${NC}"
echo -e "${BLUE}   2. 登录成功后按 ${RED}Ctrl+C${NC} ${BLUE}停止${NC}"
echo -e "${BLUE}   3. 启动服务: ${GREEN}systemctl start telegram-time${NC}"
echo ""
echo -e "${WHITE}📊 管理工具:${NC}"
echo -e "${BLUE}   • 管理界面: ${GREEN}tg-time${NC} ${YELLOW}或${NC} ${GREEN}$WORK_DIR/manage.sh${NC}"
echo -e "${BLUE}   • 查看状态: ${GREEN}tg-time status${NC}"
echo -e "${BLUE}   • 实时日志: ${GREEN}tg-time logs${NC}"
echo -e "${BLUE}   • 重启服务: ${GREEN}tg-time restart${NC}"
echo ""
echo -e "${WHITE}🔧 系统命令:${NC}"
echo -e "${BLUE}   • 启动服务: ${GREEN}systemctl start telegram-time${NC}"
echo -e "${BLUE}   • 停止服务: ${GREEN}systemctl stop telegram-time${NC}"
echo -e "${BLUE}   • 查看状态: ${GREEN}systemctl status telegram-time${NC}"
echo -e "${BLUE}   • 查看日志: ${GREEN}journalctl -u telegram-time -f${NC}"
echo ""
echo -e "${WHITE}📁 重要文件:${NC}"
echo -e "${BLUE}   • 配置文件: ${GREEN}$WORK_DIR/config.json${NC}"
echo -e "${BLUE}   • 日志文件: ${GREEN}$WORK_DIR/time_username.log${NC}"
echo -e "${BLUE}   • Python脚本: ${GREEN}$WORK_DIR/time_username.py${NC}"
echo ""
echo -e "${GREEN}✨ 您的用户名格式预览:${NC}"
current_time=$(date "+%H:%M")
if [[ -n "$EMOJI" ]]; then
    echo -e "${PURPLE}   $current_time $USERNAME $EMOJI${NC}"
else
    echo -e "${PURPLE}   $current_time $USERNAME${NC}"
fi
echo ""
echo -e "${YELLOW}💡 提示: 重新加载终端或执行 ${GREEN}source /root/.bashrc${NC} ${YELLOW}来使用 ${GREEN}tg-time${NC} ${YELLOW}命令${NC}"
echo ""
echo -e "${CYAN}🔔 现在请运行首次登录命令开始使用！${NC}"
