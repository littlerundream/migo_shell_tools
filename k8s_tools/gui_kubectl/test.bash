#!/bin/bash

for item in `kubectl get pods -n yxt-app | sed 1d | sed "s/ .*//g"`; do
  podName=`echo $item | sed "s/-.*//g"`
  kubectl cp yxt-app/$item:$podName/$podName.jar -c $podName /tmp/$podName.jar
done