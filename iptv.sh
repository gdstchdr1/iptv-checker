#!/bin/bash

# IPTV 播放列表的下载地址
M3U_URL="http://205.185.123.236:50089/?type=m3u"
M3U_FILE="tv.m3u"
SELECTED_M3U_FILE="tv_selected.m3u"

# 删除旧的 M3U 文件，防止 GitHub Actions 复制相同的文件
rm -f "$SELECTED_M3U_FILE"

# 下载 IPTV 播放列表
curl -sL "$M3U_URL" -o "$M3U_FILE"

# 解析 M3U 文件，仅提取“翡翠台”和“凤凰资讯”
echo "#EXTM3U" > "$SELECTED_M3U_FILE"

while read -r line; do
    if echo "$line" | grep -q "^#EXTINF"; then
        if echo "$line" | grep -E "翡翠台|凤凰资讯|J2"; then
            title="$line"
            read -r url  # 读取下一行（即 URL）
            echo "$title" >> "$SELECTED_M3U_FILE"
            echo "$url" >> "$SELECTED_M3U_FILE"
            echo "✔ 提取频道: $title"
        else
            read -r url  # 跳过该频道 URL
        fi
    fi
done < "$M3U_FILE"

echo "✅ 翡翠台 & 凤凰资讯 IPTV 播放列表已生成: $SELECTED_M3U_FILE"
