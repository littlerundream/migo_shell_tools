#!/bin/bash
#
# SCRIPT: ssh_log_helper.bash
# AUTHOR: Luke Zhang
# DATE: 08/01/2023
# REV: 0.0.1
#
# PURPOSE: This script help assisted SSH login to other servers
#
# REV LIST:
#
#         08/01/2023 - Luke Zhang
#         Initial the script.
#
#######################################################################
#
# NOTE: To output the timing to a file use the following syntax:
#
#    ssh_log_helper.sh > output_file_name 2>&1
#
#######################################################################
#
# set -n # Uncomment to check command syntax without any execution
# set -x # Uncomment to debug this script
#
#######################################################################
#
# Usage Examples
#
# Test environment Ansible Server to other test servers 
# for password-free login method
# 1. Enable port 2222
#
# Edit sshd configuration:
# ```bash
# sudo vim /etc/ssh/sshd_config
# ```
#
# Add ports:
# ```bash
# Port 22
# Port 2222
# ```
#
# Restart sshd: sudo systemctl reload sshd
# test and verify `telnet target_ip 2222`
#
# 2. Account Configuration
#
# Configuring Secure Access from Source IP → Destination IP
#
# cat > /home/migo/.ssh/authorized_keys <<eof
# [To configure the source server ssh public key for secure logins]
# eof
#
# ```
# chmod 600 /home/migo/.ssh/authorized_keys
# ```
#
# 3. Use the login script
#
# ```bash
# bash ssh_login_helper.bash
# ```


items=(01 "server01v-MyWebServer01-192.168.0.1"
       02 "server02v-MyWebServer01-192.168.0.2-port-2200"
       03 "server03v-MyWebServer03-192.168.0.3-port-2222")
 
SSH_TO_PORT="22"
while choice=$(dialog --title "$TITLE" \
                 --menu "Please select the server you want to log in to" 80 80 45 "${items[@]}" \
                 2>&1 >/dev/tty)
    do
    case $choice in
       01) SSH_TO_SERVER="192.168.0.1" && break ;;
       02) SSH_TO_SERVER="192.168.0.2" && SSH_TO_PORT="2200" && break ;;
       03) SSH_TO_SERVER="192.168.0.3" && SSH_TO_PORT="2222" && break ;;
    esac
done
clear
 
if [ -z "$SSH_TO_SERVER" ];then
  echo "No host is selected!"
else
  ssh migo@$SSH_TO_SERVER -p $SSH_TO_PORT
fi