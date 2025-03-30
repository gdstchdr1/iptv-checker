#!/bin/sh

# IPTV 播放列表的下载地址
M3U_URL="https://ehe.serv00.net/tv3.m3u"
M3U_FILE="tv.m3u"
VALID_M3U_FILE="tv_valid.m3u"

# 下载 IPTV 播放列表
curl -sL "$M3U_URL" -o "$M3U_FILE"

# 检测直播源是否可用
check_stream() {
    url="$1"
    if curl --head --silent --fail "$url" >/dev/null 2>&1; then
        return 0  # 可用
    else
        return 1  # 无效
    fi
}

# 获取直播源分辨率
get_resolution() {
    url="$1"
    resolution=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$url" 2>/dev/null)
    
    if [ -z "$resolution" ]; then
        return 1  # 获取失败
    fi
    
    width=$(echo "$resolution" | cut -d',' -f1)
    height=$(echo "$resolution" | cut -d',' -f2)

    if [ "$width" -ge 1280 ] && [ "$height" -ge 720 ]; then
        return 0  # 分辨率合格
    else
        return 1  # 分辨率低
    fi
}

# 解析 M3U 文件并筛选可用的高清直播源
echo "#EXTM3U" > "$VALID_M3U_FILE"

while read -r line; do
    if echo "$line" | grep -q "^#EXTINF"; then
        title="$line"
        read -r url  # 读取下一行（即 URL）

        if check_stream "$url" && get_resolution "$url"; then
            echo "$title" >> "$VALID_M3U_FILE"
            echo "$url" >> "$VALID_M3U_FILE"
            echo "✔ 保留高清: $url"
        else
            echo "❌ 丢弃低清: $url"
        fi
    fi
done < "$M3U_FILE"

echo "高清 IPTV 列表已生成: $VALID_M3U_FILE"
