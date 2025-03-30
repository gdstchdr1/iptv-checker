#!/bin/bash

# IPTV 播放列表的下载地址
M3U_URL="https://ehe.serv00.net/tv3.m3u"
M3U_FILE="tv.m3u"
HK_M3U_FILE="tv_hongkong.m3u"

# 下载 IPTV 播放列表
curl -sL "$M3U_URL" -o "$M3U_FILE"

# 解析 M3U 文件，仅提取包含 "香港" 的频道
echo "#EXTM3U" > "$HK_M3U_FILE"

while read -r line; do
    if echo "$line" | grep -q "^#EXTINF"; then
        if echo "$line" | grep -q "香港"; then
            title="$line"
            read -r url  # 读取下一行（即 URL）
            echo "$title" >> "$HK_M3U_FILE"
            echo "$url" >> "$HK_M3U_FILE"
            echo "✔ 提取香港频道: $title"
        else
            read -r url  # 跳过该频道 URL
        fi
    fi
done < "$M3U_FILE"

echo "✅ 香港 IPTV 播放列表已生成: $HK_M3U_FILE"
