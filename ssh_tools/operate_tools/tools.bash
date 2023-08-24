#!/bin/bash
 
# 引入需要的工具脚本
source ./util.bash
# 引入需要的动作脚本
source ./actions.bash

# 定义菜单显示文字
items=(
  1 "修改远程服务器上的 host"
  2 "退出程序"
)
 
# 定义菜单执行动作
function mainMenu() {
  GLOBAL_CHOICE=$1
  case $GLOBAL_CHOICE in
  1) GLOBAL_ACTION="change_hosts" && break ;; # 执行某个脚本
  2) GLOBAL_ACTION="quit_script" && break ;; # 系统中已经存在的动作
  esac
}
 
openMenu "The operate tool box" "mainMenu" "${items[@]}"