function quitScript()
{
  clear
  echo "退出脚本"
  exit 0 
}

function runArthasLocal()
{
   java -jar ~/arthas-boot.jar `ps axu | grep jar | grep Bootstrap | awk '{print $2}'`
}

function checkTheProtectionLock()
{
  if [ -f ./.lock ]; then
    echo '配置处在锁定保护状态，无法切换'
    exit 1
  fi
}

function openMenu()
{
  clear
  title=$1
  func=$2
  shift 2
  local menu_items=("$@")
  while choice=$(dialog --title "$title" \
     --menu "请选择要执行的操作" 20 40 20 "${menu_items[@]}" \
     2>&1 > /dev/tty); do
       $func $choice
  done

  runActionByChoice "$GLOBAL_ACTION" "$GLOBAL_CHOICE"
}

function gotoSubItems()
{
  openMenu "子菜单 $choice"  "subFunc$choice" "${sub_items_${choice}[@]}"
}

function runActionByChoice()
{
  action=$1
  choice=$2

  if [ -z "$action" ]; then
    echo "未选择任何操作！"
    clear
  else
    case $action in
    arthas_local)
      runArthasLocal
      ;;
    quit_script)
      quitScript
      ;;
    go_to_sub_items)
      gotoSubItems $choice
      ;;
    *)
      clear
      bash ./${action}.bash
      ;;
    esac
  fi
}