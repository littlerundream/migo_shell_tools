#!/bin/bash
 
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