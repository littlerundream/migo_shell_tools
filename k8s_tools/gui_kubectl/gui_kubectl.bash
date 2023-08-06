#!/bin/bash
#
# SCRIPT: gui_kubectl.bash
# AUTHOR: Luke Zhang
# DATE: 08/06/2023
# REV: 0.0.1
#
# PURPOSE: this is a GUI helper for kubectl by dialog command.
#
# REV LIST:
#
#         08/06/2023 - Luke Zhang
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

# 引入需要的 pods
source ./pods.bash
# 引入需要的工具脚本
source ./util.bash
# 引入需要的动作脚本
source ./actions.bash

items=(
  1 "列出运行中的全部 Pod"
  2 "列出运行中某个 Pod 的副本"
  3 "登录一个运行中的 Pod"
  4 "列出某个运行中 Pod 的资源占用"
  5 "编辑一个 Deployment"
)

while choice=$(dialog --title "$TITLE" \
  --menu "请选择要执行的操作" 80 80 45 "${items[@]}" \
  2>&1 >/dev/tty); do
  case $choice in
  1) ACTION="list_all_pod" && break ;;
  2) ACTION="show_pod_detail" && break ;;
  3) ACTION="access_to_running_pod" && break ;;
  4) ACTION="show_cpu_memory_useage_of_pod" && break ;;
  5) ACTION="edit_deployment" && break ;;
  esac
done

if [ -z "$ACTION" ]; then
  echo "未选择任何操作！"
  clear
else
  case $ACTION in
  list_all_pod)
    listAllPod
    ;;
  show_pod_detail)
    showPodDetail
    ;;
  access_to_running_pod)
    accessToRunningPod
    ;;
  show_cpu_memory_useage_of_pod)
    showCpuMemoryUseageOfPod
    ;;
  edit_deployment)
    editDeployment
    ;;
  *)
    dialog --msgbox "取消" 10 40
    ;;
  esac
fi
