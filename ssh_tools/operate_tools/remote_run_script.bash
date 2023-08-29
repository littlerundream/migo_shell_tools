#!/bin/bash
#
# SCRIPT: remote_run_script.bash
# AUTHOR: Luke Zhang
# DATE: 08/07/2023
# REV: 0.0.1
#
# PURPOSE: This is a simple remote command execution script 
#          that loops through each remote host and executes.
#
# REV LIST:
#
#         08/07/2023 - Luke Zhang
#         Initial the script.
#
#######################################################################
#
# NOTE: To output the timing to a file use the following syntax:
#
#    remote_run_script.sh > output_file_name 2>&1
#
#######################################################################
#
# set -n # Uncomment to check command syntax without any execution
# set -x # Uncomment to debug this script
#
#######################################################################

START_MSG="run on remote server"
SUCCESS_MSG="run successfully"
FAILED_MSG="run faild"

function _runOnRemoteServers() {
  runCommand=$1
  # 查询日志
  for ip_port in ${servers[@]}
  do
    server="${ip_port%%:*}"
    port="${ip_port##*:}"
    echo "${START_MSG}: ${server}"
    if ssh -p ${port} user@${server} "${runCommand}"; then
      _runSuccess ${server}
    else
      _runFail ${server}
    fi
  done
}

function _runSuccess() {
  local current=$1
  echo -e "\e[1;32m【√】${SUCCESS_MSG}\e[0m"
}

function _runFail() {
  local current=$1
  echo -e "\e[1;31m【×】${FAILED_MSG}\e[0m"
}