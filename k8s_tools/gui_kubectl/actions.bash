APP_NAMESPACE=yxt-app

function listAllPod()
{
  clear
  #kubectl get pods -o wide -n $APP_NAMESPACE | less
  kubectl get pods -n $APP_NAMESPACE | awk '{print NR " " $1"\t"$2"\t "$3}' | less
}

function showPodDetail()
{
  clear
  while selectPod=$(dialog --title "$TITLE" \
   --menu "请选择容器" 80 80 45 "${pods[@]}" 2>&1 >/dev/tty); do
    echo "您选择了 echo ${pods[$selectPod*2-1]}!" && selectPod=${pods[$selectPod*2-1]} && break;
  done
  
  #pendingPods=(`kubectl get pods -n $APP_NAMESPACE | grep $selectPod | awk '{print NR" "$1"("$2","$3")"}'  | tr '\n' ' '`)
  pendingPods=(`kubectl get pods -n $APP_NAMESPACE | grep $selectPod | awk '{print NR" "$1}'  | tr '\n' ' '`)
  clear
  while pod=$(dialog --title "$TITLE" \
   --menu "请选择实际的 pod" 80 80 45 "${pendingPods[@]}" 2>&1 >/dev/tty); do
    clear && (kubectl get pods -n $APP_NAMESPACE -o wide | grep ${pendingPods[$pod*2-1]}) && break;
  done
}

function accessToRunningPod()
{
  clear
  while selectPod=$(dialog --title "$TITLE" \
   --menu "请选择容器" 80 80 45 "${pods[@]}" 2>&1 >/dev/tty); do
    echo "您选择了 echo ${pods[$selectPod*2-1]}!" && selectPod=${pods[$selectPod*2-1]} && break;
  done

  #pendingPods=(`kubectl get pods -n $APP_NAMESPACE | grep $selectPod | awk '{print NR" "$1"("$2","$3")"}'  | tr '\n' ' '`)
  pendingPods=(`kubectl get pods -n $APP_NAMESPACE | grep $selectPod | awk '{print NR" "$1}'  | tr '\n' ' '`)
  clear
  while pod=$(dialog --title "$TITLE" \
   --menu "请选择实际的 pod" 80 80 45 "${pendingPods[@]}" 2>&1 >/dev/tty); do
    accessPod=${pendingPods[($pod*2-1)]} && break;
  done 
  
  echo "kubectl exec -it $accessPod -n $APP_NAMESPACE -c $selectPod -- bash"
  kubectl exec -it $accessPod -n $APP_NAMESPACE -c $selectPod -- bash
  kubectl exec -it $accessPod -n $APP_NAMESPACE -- bash
}

function showCpuMemoryUseageOfPod()
{
  while selectPod=$(dialog --title "$TITLE" \
   --menu "请选择容器" 80 80 45 "${pods[@]}" 2>&1 >/dev/tty); do
    echo "您选择了 echo ${pods[$selectPod*2-1]}!" && selectPod=${pods[$selectPod*2-1]} && break;
  done
  clear
  kubectl top pod -n $APP_NAMESPACE | grep $selectPod
}


function editDeployment()
{
  clear
  while selectDeployment=$(dialog --title "$TITLE" \
   --menu "请选择 Deployment" 80 80 45 "${pods[@]}" 2>&1 >/dev/tty); do
   deployment=${pods[$selectDeployment*2-1]} && break;
  done
  clear
  kubectl edit deploy $deployment -n $APP_NAMESPACE
}
