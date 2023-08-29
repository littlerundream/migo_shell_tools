#!/bin/bash
#
# SCRIPT: s3_mount.bash
# AUTHOR: Luke Zhang
# DATE: 08/01/2023
# REV: 0.0.1
#
# PURPOSE: This script help mount s3fs to local file system
#
# REV LIST:
#
#         08/25/2023 - Luke Zhang
#         Initial the script.
#
#######################################################################
#
# NOTE: To output the timing to a file use the following syntax:
#
#    batch_process_conflicts.sh [old|new] > output_file_name 2>&1
#
#######################################################################
#
# set -n # Uncomment to check command syntax without any execution
# set -x # Uncomment to debug this script
#
#######################################################################
source /etc/profile
 
export service_path="/usr/bin/s3fs"
export passwd_file="/home/s3/.password-s3fs"
export url="https://oss-host:443"
 
export download_bucket="bucket-name"
export download_mountpoint="/home/s3-user/s3"

# 限制 s3-user 用户
if [ "$(whoami)" != "s3-user" ]; then
    echo "must run as user: s3-user"
    exit
fi
 
# s3 服务挂载
function start() {
    status
    if [ "1" -eq "$?" ]; then
        ${service_path} ${download_bucket} ${download_mountpoint} -o passwd_file=${passwd_file} -o url=${url} -o use_path_request_style -o allow_other -o nonempty
        status
        if [ "0" -eq "$?" ]; then
            echo "started success"
        else
            echo "start failed"
        fi
    else
        echo "already started"
    fi
}
 
# s3 服务卸载
function stop() {
    status
    if [ "0" -eq "$?" ]; then
        fusermount -u ${download_mountpoint}
        echo "stopped"
    else
        echo "not started"
    fi
}
 
# s3 状态查询
function status() {
    export service_PID=$(/bin/ps -ef | grep -E "passwd_file=${passwd_file}" | grep -v "grep" | awk '{print $2}' | tr '\n' ',' | sed 's/,$//g')
    if [ -z ${service_PID} ]; then
        echo "Service has been stopped"
        return 1
    else
        echo "Service is running：${service_PID}"
        return 0
    fi
}
 
case $1 in
start)
    start
    ;;
stop)
    stop
    ;;
status)
    status
    ;;
*)
    echo "请输入运行命令：bash s3.sh [start|stop|status]"
    ;;
esac