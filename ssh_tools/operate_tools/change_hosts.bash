#!/bin/bash

# 引入服务器脚本
source ./servers.bash
# 引入远程服务器执行工具
source remote_run_script.bash

START_MSG="开始在远程服务器执行"
SUCCESS_MSG="替换完成"
FAILED_MSG="替换失败"

function _changeHost() {
  echo "正在切换远程服务的上的 hosts：127.0.0.1 → migo.top"
  _runOnRemoteServers "echo '127.0.0.1 migo.top' >> /etc/hosts"
}

_changeHost
