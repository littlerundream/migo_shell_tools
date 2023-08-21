function quitScript()
{
  clear
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