#!/bin/bash
#
# SCRIPT: rclone_data.bash
# AUTHOR: Luke Zhang
# DATE: 08/29/2023
# REV: 0.0.1
#
# PURPOSE: A script that synchronizes an S3 bucket
# synchronizing data from an S3 bucket to another S3 bucket.
#
# REV LIST:
#
#         08/29/2023 - Luke Zhang
#         Initial the script.
#
#######################################################################
#
# NOTE: To output the timing to a file use the following syntax:
#
#    rclone_data.sh > output_file_name 2>&1
#
#######################################################################
#
# set -n # Uncomment to check command syntax without any execution
# set -x # Uncomment to debug this script
#
#######################################################################

# 需要同步的源路径
# set -x # 注释掉此行，用于在运行中调试脚本
# set nu

pendingDir=/src-dir/
# 定义根源文件夹
src=s3:src-bucket
# 定义根目标文件夹
des=s3:dst-bucket
# 定义执行用户
user=user
# 定义上一个处理过的文件
identifierOfPrevProcessedFile=""

# 使用醒目的颜色输出
function highlight_message() {
  message=$1
  echo -e "\033[33m $(date "+%Y-%m-%d %H:%M:%S") $message\033[0m"

}
# 使用不醒目的颜色输出
function lowlight_message() {
  message=$1
  echo -e "\033[2m $(date "+%Y-%m-%d %H:%M:%S")  $message \033[0m"
}

# 当前正在处理的文件
function is_file_on_processing() {
    ps aux | grep "rclone" | grep "$1" | grep -v grep | wc -l
}
# 为当前日期进行一次初始化同步
function init_sync_for_today() {
    syncDirToday=$(date +%Y/%m/%d)
    highlight_message "正在执行初始化文件同步 $syncDirToday"
    rclone copy --metadata --update -P --bwlimit 85M $src/$syncDirToday $des/$syncDirToday
}
# 持续执行同步动作
function continuous_sync() {
    highlight_message "正在针对 $syncDirToday 当日目录，执行持续同步"
    while true; do
        rclone copy --metadata --update -P --bwlimit 85M $src/$syncDirToday $des/$syncDirToday
        sleep 5
    done
}
# 执行文件同步
function sync_file() {
    srcFile=$(echo $1 | sed 's/ //g')
    desDir=$(echo $2 | sed 's/ //g')
    processingCount=$(is_file_on_processing)
    identifierOfPendingProcessFile="$srcFile-`date +%m%d%H%M`"
    if [[ $processingCount -eq 0 && $identifierOfPendingProcessFile != $identifierOfPrevProcessedFile ]]; then
        highlight_message "正在执行文件同步，源 $srcFile  目标：$desDir"
        nohup rclone copy --metadata --update -P --bwlimit 85M $srcFile $desDir >> /tmp/rclone-$(date +%Y%m%d).log 2>&1 &
        identifierOfPrevProcessedFile="$srcFile-`date +%m%d%H%M`"
    fi
}
# 处理文件监听事件
function process_event() {
  # 把inotify输出切割 把事件类型部分赋值给 INO_EVENT
  INO_EVENT=$1
  # 把inotify输出切割 把文件路径部分赋值给 INO_FILE
  INO_FILE=$(echo $2 | sed 's/^\.\///g')
  INO_DIR=$(dirname $INO_FILE)
  #输出日志信息
  lowlight_message "监听到事件 $file"

  #增加、修改、写入完成、移动进事件
  #增、改放在同一个判断，因为他们都肯定是针对文件的操作，即使是新建目录，要同步的也只是一个空目录，不会影响速度。

  # 判断事件类型
  if [[ $INO_EVENT =~ 'CREATE' ]] || [[ $INO_EVENT =~ 'MODIFY' ]] || [[ $INO_EVENT =~ 'CLOSE_WRITE' ]] || [[ $INO_EVENT =~ 'MOVED_TO' ]]; then
    sync_file $src/${INO_FILE} $des/${INO_DIR}
    #仔细看 上面的rsync同步命令 源是用了$(dirname ${INO_FILE})变量，然后用 -R 参数把源的目录结构递归到目标后面 保证目录结构一致性
  fi

  #删除、移动出事件
  if [[ $INO_EVENT =~ 'DELETE' ]] || [[ $INO_EVENT =~ 'MOVED_FROM' ]]
    then
            highlight_message "正在删除文件 $des/${INO_FILE}"
            rclone deletefile $des/${INO_FILE}
  fi

  #修改属性事件 指 touch chgrp chmod chown等操作
  if [[ $INO_EVENT =~ 'ATTRIB' ]]; then
    # 如果修改属性的是目录 则不同步，因为同步目录会发生递归扫描，等此目录下的文件发生同步时，rsync会顺带更新此目录。
    if [ ! -d "$INO_FILE" ]; then
      sync_file $src/${INO_FILE} $des/${INO_DIR}
    fi
  fi
}

# 监听并根据事件执行对应的同步动作
function listen_and_process_sync_events() {
  echo "开始监听目录" ${pendingDir} "下的文件变更"
  cd ${pendingDir}
  # 把监控到有发生更改的"文件路径列表"循环
  # shellcheck disable=SC2162
  inotifywait -mrq --format '%Xe %w%f' --exclude '.*\.sw[px]*$|4913|~$' -e modify,create,delete,attrib,close_write,move ./ | while read file; do
      # 判断如果进程中存在  rclone copy 则跳过当前循环，否则执行 process_event $file
      process_event $file
  done
}

# 定义脚本使用方法
function useage() {
   echo "使用方法: "
   echo "  --sync-once: 同步当日的全部增量"
   echo "  --sync-always: 持续进行同步"
   echo "  --wait: 进行监听并同步"
}

###################
###   主程序    ###
##################


if [[ $# -eq 0 ]]; then
    echo "参数为空！"
    useage
    exit 1
fi


while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        --sync-once)
        init_sync_for_today
        shift
        ;;
        --sync-always)
        continuous_sync
        shift
        ;;        
        --wait)
        listen_and_process_sync_events
        shift
        ;;
        *)
        echo "无效的参数: $key"
        useage
        exit 1
        ;;
    esac
done