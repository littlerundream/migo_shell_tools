#!/bin/bash
 
# 引入需要的工具脚本
source ./util.bash
# 引入需要的动作脚本
source ./actions.bash
 
items=(
  1 "修改远程服务器上的 host"
  2 "退出程序"
)
 
while choice=$(dialog --title "$TITLE" \
  --menu "请选择要执行的操作" 20 40 20 "${items[@]}" \
  2>&1 >/dev/tty); do
  case $choice in
  1) ACTION="change_hosts" && break ;;
  2) ACTION="quit_script" && break ;;
  esac
done
 
if [ -z "$ACTION" ]; then
  echo "未选择任何操作！"
  clear
else
  case $ACTION in
  quit_script)
    quitScript
    ;;
  *)
    clear
    bash ./${ACTION}.bash
    ;;
  esac
fi
