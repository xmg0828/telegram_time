#!/bin/bash
# Telegram自动更新时间用户名安装脚本 (改进版)
# 作者: Claude
# 版本: 2.0 - 支持多种字体和时间在前显示

# 设置颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # 恢复默认颜色

# 检查是否为root用户运行
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}请使用root权限运行此脚本${NC}"
    echo "例如: sudo bash $0"
    exit 1
fi

# 显示欢迎界面
clear
echo -e "${CYAN}┌─────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│                                                         │${NC}"
echo -e "${CYAN}│     🕐 Telegram 时间用户名更新器 v2.0 🕐               │${NC}"
echo -e "${CYAN}│                                                         │${NC}"
echo -e "${CYAN}│              ✨ 支持多种字体样式 ✨                    │${NC}"
echo -e "${CYAN}│                                                         │${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────────────┘${NC}"
echo ""

# 安装依赖项
echo -e "${YELLOW}📦 正在安装必要的依赖项...${NC}"
apt update > /dev/null 2>&1
apt install -y python3 python3-pip > /dev/null 2>&1

# 安装Python依赖
echo -e "${YELLOW}🐍 安装Python依赖...${NC}"
pip3 install --break-system-packages telethon pytz > /dev/null 2>&1

# 创建工作目录
WORK_DIR="/opt/telegram-time"
echo -e "${YELLOW}📁 创建工作目录: $WORK_DIR${NC}"
mkdir -p $WORK_DIR

# 交互式获取API凭据
echo ""
echo -e "${GREEN}🔑 请输入您的Telegram API凭据${NC}"
echo -e "${CYAN}您可以从 https://my.telegram.org/apps 获取${NC}"
read -p "API ID: " API_ID
read -p "API Hash: " API_HASH

# 选择字体样式
echo ""
echo -e "${GREEN}🎨 请选择字体样式${NC}"
echo -e "${PURPLE}1) 𝟐𝟐:𝟎𝟓 𝐁𝐫𝐲𝐚𝐧𝐧𝐚 💕 ${CYAN}(数学粗体)${NC}"
echo -e "${PURPLE}2) 𝟐𝟐:𝟎𝟓 𝘽𝙧𝙮𝙖𝙣𝙣𝙖 💕 ${CYAN}(数学无衬线粗体)${NC}"
echo -e "${PURPLE}3) 𝟐𝟐:𝟎𝟓 𝒷𝓇𝓎𝒶𝓃𝓃𝒶 💕 ${CYAN}(数学手写体)${NC}"
echo -e "${PURPLE}4) 𝟐𝟐:𝟎𝟓 𝐵𝓇𝓎𝒶𝓃𝓃𝒶 💕 ${CYAN}(数学粗手写体)${NC}"
echo -e "${PURPLE}5) 𝟐𝟐:𝟎𝟓 𝓑𝓻𝔂𝓪𝓷𝓷𝓪 💕 ${CYAN}(数学Fraktur)${NC}"
echo -e "${PURPLE}6) 𝟐𝟐:𝟎𝟓 𝖡𝗋𝗒𝖺𝗇𝗇𝖺 💕 ${CYAN}(数学无衬线)${NC}"
echo -e "${PURPLE}7) 𝟐𝟐:𝟎𝟓 𝘉𝘳𝘺𝘢𝘯𝘯𝘢 💕 ${CYAN}(数学斜体)${NC}"
echo -e "${PURPLE}8) 𝟐𝟐:𝟎𝟓 𝕭𝖗𝖞𝖆𝖓𝖓𝖆 💕 ${CYAN}(数学双线)${NC}"
echo -e "${PURPLE}9) 𝟐𝟐:𝟎𝟓 𝙱𝚛𝚢𝚊𝚗𝚗𝚊 💕 ${CYAN}(等宽字体)${NC}"
echo -e "${PURPLE}10) 22:05 Bryanna 💕 ${CYAN}(普通字体)${NC}"
read -p "选择字体 [1-10]: " FONT_CHOICE

# 设置字体变量
case $FONT_CHOICE in
    1) FONT_TYPE="math_bold" ;;
    2) FONT_TYPE="math_sans_bold" ;;
    3) FONT_TYPE="math_script" ;;
    4) FONT_TYPE="math_bold_script" ;;
    5) FONT_TYPE="math_fraktur" ;;
    6) FONT_TYPE="math_sans" ;;
    7) FONT_TYPE="math_italic" ;;
    8) FONT_TYPE="math_double" ;;
    9) FONT_TYPE="monospace" ;;
    10) FONT_TYPE="normal" ;;
    *)
        echo -e "${RED}无效的选择，使用默认字体 (数学粗体)${NC}"
        FONT_TYPE="math_bold"
        ;;
esac

# 选择时区
echo ""
echo -e "${GREEN}🌍 请选择时区${NC}"
echo "1) 亚洲/上海 (中国时间)"
echo "2) 亚洲/香港"
echo "3) 亚洲/新加坡"
echo "4) 美国/东部"
echo "5) 美国/西部"
echo "6) 欧洲/伦敦"
echo "7) 自定义"
read -p "选择 [1-7]: " TIMEZONE_CHOICE

case $TIMEZONE_CHOICE in
    1) TIMEZONE="Asia/Shanghai" ;;
    2) TIMEZONE="Asia/Hong_Kong" ;;
    3) TIMEZONE="Asia/Singapore" ;;
    4) TIMEZONE="America/New_York" ;;
    5) TIMEZONE="America/Los_Angeles" ;;
    6) TIMEZONE="Europe/London" ;;
    7) 
        echo "请输入有效的时区名称 (例如: Asia/Tokyo):"
        read -p "时区: " TIMEZONE
        ;;
    *)
        echo -e "${RED}无效的选择，使用默认时区 Asia/Shanghai${NC}"
        TIMEZONE="Asia/Shanghai"
        ;;
esac

# 选择时间格式
echo ""
echo -e "${GREEN}⏰ 请选择时间格式${NC}"
echo "1) 24小时制 (例如: 22:05)"
echo "2) 12小时制 (例如: 10:05 PM)"
echo "3) 带日期 (例如: 12-06 22:05)"
echo "4) 带星期 (例如: 周四 22:05)"
echo "5) 带秒显示 (例如: 22:05:30)"
read -p "选择 [1-5]: " FORMAT_CHOICE

case $FORMAT_CHOICE in
    1) TIME_FORMAT=1 ;;
    2) TIME_FORMAT=2 ;;
    3) TIME_FORMAT=3 ;;
    4) TIME_FORMAT=4 ;;
    5) TIME_FORMAT=5 ;;
    *)
        echo -e "${RED}无效的选择，使用默认格式 (24小时制)${NC}"
        TIME_FORMAT=1
        ;;
esac

# 输入用户名
echo ""
echo -e "${GREEN}👤 请输入您的用户名${NC}"
read -p "用户名 (例如: Bryanna): " USERNAME

# 选择emoji
echo ""
echo -e "${GREEN}😊 请选择emoji (可选)${NC}"
echo "1) 💕 (爱心)"
echo "2) 💖 (闪亮心)"
echo "3) 🌸 (樱花)"
echo "4) ✨ (星星)"
echo "5) 🎀 (蝴蝶结)"
echo "6) 💫 (彗星)"
echo "7) 🌟 (星星)"
echo "8) 不使用emoji"
read -p "选择 [1-8]: " EMOJI_CHOICE

case $EMOJI_CHOICE in
    1) EMOJI="💕" ;;
    2) EMOJI="💖" ;;
    3) EMOJI="🌸" ;;
    4) EMOJI="✨" ;;
    5) EMOJI="🎀" ;;
    6) EMOJI="💫" ;;
    7) EMOJI="🌟" ;;
    8) EMOJI="" ;;
    *)
        echo -e "${RED}无效的选择，使用默认emoji 💕${NC}"
        EMOJI="💕"
        ;;
esac

# 选择更新频率
echo ""
echo -e "${GREEN}⚡ 请选择更新频率${NC}"
echo -e "${YELLOW}警告: 频繁更新可能导致Telegram账号受限${NC}"
echo "1) 每分钟 (推荐)"
echo "2) 每5分钟"
echo "3) 每小时"
read -p "选择 [1-3]: " FREQ_CHOICE

case $FREQ_CHOICE in
    1) UPDATE_FREQ=60 ;;
    2) UPDATE_FREQ=300 ;;
    3) UPDATE_FREQ=3600 ;;
    *)
        echo -e "${RED}无效的选择，使用默认频率 (每分钟)${NC}"
        UPDATE_FREQ=60
        ;;
esac

# 创建Python脚本
echo -e "${YELLOW}📝 创建Python脚本...${NC}"
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
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler("$WORK_DIR/time_username.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# 设置时区
timezone = pytz.timezone("$TIMEZONE")

# Telegram API配置
API_ID = '$API_ID'
API_HASH = '$API_HASH'
SESSION_NAME = '$WORK_DIR/time_username_session'

# 配置参数
FONT_TYPE = '$FONT_TYPE'
TIME_FORMAT = $TIME_FORMAT
USERNAME = '$USERNAME'
EMOJI = '$EMOJI'
UPDATE_FREQUENCY = $UPDATE_FREQ  # 秒

# 星期几的中文表示
weekday_cn = ['一', '二', '三', '四', '五', '六', '日']

# 字体转换函数
def convert_to_font(text, font_type):
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

def get_time_username():
    """生成时间用户名"""
    now = datetime.now(timezone)
    
    # 获取时间部分
    if TIME_FORMAT == 1:  # 24小时制
        time_part = now.strftime('%H:%M')
    elif TIME_FORMAT == 2:  # 12小时制
        time_part = now.strftime('%I:%M %p')
    elif TIME_FORMAT == 3:  # 带日期
        time_part = f"{now.strftime('%m-%d')} {now.strftime('%H:%M')}"
    elif TIME_FORMAT == 4:  # 带星期
        weekday = weekday_cn[now.weekday()]
        time_part = f"周{weekday} {now.strftime('%H:%M')}"
    elif TIME_FORMAT == 5:  # 带秒显示
        time_part = now.strftime('%H:%M:%S')
    else:
        time_part = now.strftime('%H:%M')
    
    # 构建完整用户名：时间在前
    if EMOJI:
        full_name = f"{time_part} {USERNAME} {EMOJI}"
    else:
        full_name = f"{time_part} {USERNAME}"
    
    # 应用字体转换
    styled_name = convert_to_font(full_name, FONT_TYPE)
    
    return styled_name

async def update_username():
    """更新用户名主函数"""
    try:
        # 连接到Telegram
        client = TelegramClient(SESSION_NAME, API_ID, API_HASH)
        await client.start()
        logger.info("✅ 已连接到Telegram")
        
        me = await client.get_me()
        logger.info(f"👤 当前账号: {me.first_name} (@{me.username})")
        
        while True:
            new_username = get_time_username()
            try:
                # 更新用户名
                await client(functions.account.UpdateProfileRequest(
                    first_name=new_username
                ))
                logger.info(f"🔄 用户名已更新为: {new_username}")
            except Exception as e:
                logger.error(f"❌ 更新用户名失败: {e}")
            
            # 计算下次更新时间
            wait_time = UPDATE_FREQUENCY
            if UPDATE_FREQUENCY == 60:
                # 如果是每分钟更新，则对齐到整分钟
                now = datetime.now()
                wait_time = 60 - now.second
                
            logger.info(f"⏰ 等待 {wait_time} 秒后再次更新")
            await asyncio.sleep(wait_time)

    except Exception as e:
        logger.error(f"💥 运行出错: {e}")
        # 如果遇到错误，等待一段时间后重试
        await asyncio.sleep(60)
        await update_username()

if __name__ == "__main__":
    loop = asyncio.get_event_loop()
    try:
        loop.run_until_complete(update_username())
    except KeyboardInterrupt:
        logger.info("🛑 程序被用户中断")
    finally:
        loop.close()
EOF

# 设置可执行权限
chmod +x $WORK_DIR/time_username.py

# 创建systemd服务
echo -e "${YELLOW}⚙️ 创建系统服务...${NC}"
cat > /etc/systemd/system/telegram-time.service << EOF
[Unit]
Description=Telegram Time Username Updater
After=network.target

[Service]
ExecStart=/usr/bin/python3 $WORK_DIR/time_username.py
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

# 显示完成信息
echo ""
echo -e "${GREEN}🎉 安装完成！${NC}"
echo ""
echo -e "${CYAN}┌─────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│                     使用说明                           │${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────────────┘${NC}"
echo ""
echo -e "${YELLOW}1. 首次登录您的Telegram账号:${NC}"
echo -e "   ${BLUE}cd $WORK_DIR && python3 time_username.py${NC}"
echo ""
echo -e "${YELLOW}2. 登录成功后，按 ${RED}Ctrl+C${NC} ${YELLOW}停止程序，然后启动服务:${NC}"
echo -e "   ${BLUE}systemctl start telegram-time${NC}"
echo ""
echo -e "${YELLOW}3. 查看服务状态:${NC}"
echo -e "   ${BLUE}systemctl status telegram-time${NC}"
echo ""
echo -e "${YELLOW}4. 查看实时日志:${NC}"
echo -e "   ${BLUE}tail -f $WORK_DIR/time_username.log${NC}"
echo ""
echo -e "${YELLOW}5. 停止服务:${NC}"
echo -e "   ${BLUE}systemctl stop telegram-time${NC}"
echo ""
echo -e "${YELLOW}6. 重启服务:${NC}"
echo -e "   ${BLUE}systemctl restart telegram-time${NC}"
echo ""
echo -e "${GREEN}✨ 您的用户名格式预览: ${NC}"
if [ "$EMOJI" != "" ]; then
    echo -e "${PURPLE}   22:05 $USERNAME $EMOJI${NC}"
else
    echo -e "${PURPLE}   22:05 $USERNAME${NC}"
fi
echo ""
echo -e "${CYAN}💡 提示: 时间会根据您选择的时区和格式自动更新！${NC}"
