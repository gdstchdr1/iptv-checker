#!/bin/bash

INPUT_M3U="tv_channels.m3u"  # 原始 IPTV 直播源列表
OUTPUT_M3U="tv_selected.m3u"  # 过滤后的 IPTV 列表

# 只提取 "翡翠台" 和 "凤凰资讯" 频道
grep -E "翡翠台|凤凰资讯" "$INPUT_M3U" -A1 > "$OUTPUT_M3U"

# 过滤掉无法播放的 IPTV 源
echo "正在检测无效播放源..."
while read -r line; do
  if [[ $line == http* ]]; then
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$line")
    if [[ "$STATUS" -ne 200 ]]; then
      echo "❌ 无效源: $line"
      sed -i "/$line/d" "$OUTPUT_M3U"
    fi
  fi
done < "$OUTPUT_M3U"

# 过滤低于 1280×720 分辨率的源
echo "正在检测分辨率..."
while read -r line; do
  if [[ $line == http* ]]; then
    RESOLUTION=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$line" | awk -F',' '{print $1 "x" $2}')
    if [[ "$RESOLUTION" < "1280x720" ]]; then
      echo "📉 低分辨率: $line ($RESOLUTION)"
      sed -i "/$line/d" "$OUTPUT_M3U"
    fi
  fi
done < "$OUTPUT_M3U"

echo "✅ 处理完成，生成新 M3U: $OUTPUT_M3U"
