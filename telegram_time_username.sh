#!/bin/bash
# 修复Telegram时间更新错误脚本

# 设置颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

WORK_DIR="/opt/telegram-time"

echo -e "${BLUE}🔧 正在修复Telegram时间更新错误...${NC}"

# 停止服务
echo -e "${YELLOW}1. 停止服务...${NC}"
systemctl stop telegram-time

# 备份当前脚本
echo -e "${YELLOW}2. 备份当前脚本...${NC}"
cp $WORK_DIR/time_username.py $WORK_DIR/time_username.py.backup

# 创建修复后的Python脚本
echo -e "${YELLOW}3. 创建修复后的脚本...${NC}"

# 读取现有配置
API_ID=$(grep "API_ID = " $WORK_DIR/time_username.py | cut -d"'" -f2)
API_HASH=$(grep "API_HASH = " $WORK_DIR/time_username.py | cut -d"'" -f2)
TIMEZONE=$(grep "timezone = pytz.timezone" $WORK_DIR/time_username.py | cut -d'"' -f2)
FONT_TYPE=$(grep "FONT_TYPE = " $WORK_DIR/time_username.py | cut -d"'" -f2)
TIME_FORMAT=$(grep "TIME_FORMAT = " $WORK_DIR/time_username.py | grep -o '[0-9]')
USERNAME=$(grep "USERNAME = " $WORK_DIR/time_username.py | cut -d"'" -f2)
EMOJI=$(grep "EMOJI = " $WORK_DIR/time_username.py | cut -d"'" -f2)
UPDATE_FREQ=$(grep "UPDATE_FREQUENCY = " $WORK_DIR/time_username.py | grep -o '[0-9]*')

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
    client = None
    try:
        # 连接到Telegram
        client = TelegramClient(SESSION_NAME, API_ID, API_HASH)
        await client.start()
        logger.info("✅ 已连接到Telegram")
        
        me = await client.get_me()
        logger.info(f"👤 当前账号: {me.first_name}")
        
        while True:
            try:
                new_username = get_time_username()
                logger.info(f"🔄 准备更新用户名为: {new_username}")
                
                # 更新用户名 - 修复的关键部分
                await client(functions.account.UpdateProfileRequest(
                    first_name=new_username
                ))
                logger.info(f"✅ 用户名已成功更新为: {new_username}")
                
            except Exception as e:
                error_msg = str(e)
                logger.error(f"❌ 更新失败: {error_msg}")
                
                # 处理不同类型的错误
                if "flood" in error_msg.lower() or "too many" in error_msg.lower():
                    logger.warning("⚠️ 触发频率限制，等待5分钟...")
                    await asyncio.sleep(300)
                    continue
                elif "session" in error_msg.lower():
                    logger.error("🔐 Session问题，需要重新登录")
                    break
            
            # 计算下次更新时间
            wait_time = UPDATE_FREQUENCY
            if UPDATE_FREQUENCY == 60:
                # 如果是每分钟更新，则对齐到整分钟
                now = datetime.now()
                wait_time = 60 - now.second
                
            logger.info(f"⏰ 等待 {wait_time} 秒后再次更新")
            await asyncio.sleep(wait_time)

    except Exception as e:
        logger.error(f"💥 连接或运行出错: {str(e)}")
    finally:
        if client:
            await client.disconnect()
        # 如果遇到错误，等待一段时间后重试
        await asyncio.sleep(60)
        await update_username()

if __name__ == "__main__":
    try:
        asyncio.run(update_username())
    except KeyboardInterrupt:
        logger.info("🛑 程序被用户中断")
    except Exception as e:
        logger.error(f"💥 程序异常退出: {str(e)}")
EOF

# 设置可执行权限
chmod +x $WORK_DIR/time_username.py

echo -e "${GREEN}4. 修复完成！${NC}"

# 重启服务
echo -e "${YELLOW}5. 重启服务...${NC}"
systemctl start telegram-time

# 检查状态
echo -e "${YELLOW}6. 检查服务状态...${NC}"
sleep 3
systemctl status telegram-time --no-pager -l

echo ""
echo -e "${GREEN}🎉 修复完成！请查看上面的服务状态。${NC}"
echo -e "${BLUE}💡 提示：可以运行以下命令查看实时日志：${NC}"
echo -e "${BLUE}   tail -f $WORK_DIR/time_username.log${NC}"
