#!/bin/bash

# 设置GPIO权限（如果设备存在）
GPIO_PATH="/sys/class/tz_gpio/mcu_reset/value"
if [ -e "$GPIO_PATH" ]; then
    chmod 777 "$GPIO_PATH"
else
    echo "GPIO device not found: $GPIO_PATH" >&2
fi

# 启动MicroXRCEAgent（后台运行）
MicroXRCEAgent "$@" &
AGENT_PID=$!

# 等待Agent初始化（根据实际情况调整）
sleep 1

# 执行GPIO复位操作
if [ -e "$GPIO_PATH" ]; then
    echo 0 > "$GPIO_PATH"  # 触发复位
    sleep 0.5              # 保持复位状态
    echo 1 > "$GPIO_PATH"  # 释放复位
    echo "MCU reset triggered"
else
    echo "Skipping GPIO reset: device not available"
fi

# 等待Agent进程结束（保持容器运行）
wait $AGENT_PID