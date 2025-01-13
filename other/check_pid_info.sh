#!/bin/bash
####################################################

read -p "请输入要查询的进程名或PID: " NAME_PID

# 判断是否有输入值
if [ -z "${NAME_PID}" ]; then
    echo "请输入一个有效的进程名或PID！！"
    exit 1
fi

# 检查输入是否为数字，如果不是则认为是进程名
if [[ "${NAME_PID}" =~ ^[0-9]+$ ]]; then
    PIDS=(${NAME_PID})
else
    PIDS=($(pgrep -x "${NAME_PID}"))
    if [ -z "$PIDS" ]; then
        echo "该进程名不存在！！"
        exit 1
    fi
fi

for PID in "${PIDS[@]}"; do
    # 检查进程是否存在
    if ! ps -p $PID &> /dev/null ; then
        echo "该PID不存在！！"
        continue
    fi

    # 获取并显示进程的基本信息
    echo "------------------------------------------------"
    printf "%-20s %s\n" "进程PID:" "$PID"
    printf "%-20s %s\n" "进程命令:" "$(ps -p $PID -o cmd=)"
    printf "%-20s %s%%\n" "CPU占用率:" "$(ps -p $PID -o %cpu=)"
    printf "%-20s %s%%\n" "内存占用率:" "$(ps -p $PID -o %mem=)"
    printf "%-20s %s\n" "进程所属用户:" "$(ps -p $PID -o user=)"
    printf "%-20s %s\n" "进程当前状态:" "$(ps -p $PID -o stat=)"
    printf "%-20s %.2f MB\n" "进程虚拟内存:" "$(echo "$(ps -p $PID -o vsz=) / 1024" | bc -l)"
    printf "%-20s %.2f MB\n" "进程共享内存:" "$(echo "$(ps -p $PID -o rss=) / 1024" | bc -l)"
    printf "%-20s %s\n" "进程运行持续时间:" "$(ps -p $PID -o etime=)"
    printf "%-20s %s\n" "进程开始运行时间:" "$(ps -p $PID -o lstart=)"
    echo "------------------------------------------------"
done
