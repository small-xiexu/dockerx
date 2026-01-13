#!/bin/bash

# 日志清理脚本
# 用途：清理超过 30 天的日志文件

echo "开始清理日志文件..."

# 清理 logs 目录中超过 30 天的日志文件
find ./logs -name "*.log.*" -type f -mtime +30 -delete

# 清理 data/rocketmq/logs 目录中超过 30 天的日志文件
find ./data/rocketmq/logs -name "*.log.*" -type f -mtime +30 -delete 2>/dev/null

echo "日志清理完成！"

# 显示当前日志目录大小
echo ""
echo "当前日志目录大小："
du -sh ./logs 2>/dev/null || echo "logs 目录为空"
du -sh ./data/rocketmq/logs 2>/dev/null || echo "rocketmq logs 目录为空"
