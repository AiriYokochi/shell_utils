#!/bin/bash
function ask_yes_no {
  while true; do
    echo -n "$* [y/N]: "
    read ANS
    case $ANS in
      "")
        return 0
        ;;
      [Yy]*)
        return 0
        ;;  
      [Nn]*)
        return 1
        ;;
      *)
        echo "yまたはNを入力してください"
        ;;
    esac
  done
}

IP=`ifconfig |grep inet |grep 192 | awk '{print $2}'`
ROSMASTER=`cat ~/.bashrc  |grep ROS_MASTER_URI |grep -v \# |tail -n 1 | awk -F"//" '{print $2}' | awk -F":" '{print $1}'`
ROSIP=`cat ~/.bashrc  |grep ROS_IP |grep -v \# |tail -n 1 | awk -F"=" '{print $2}'`

### example of ROS_MASER_URI and ROS_IP
# export ROS_MASTER_URI=http://192.168.0.69:11311
# export ROS_IP=192.168.0.69

if [ "${IP}" == "${ROSMASTER}" -a  "${IP}" == "${ROSIP}" ]; then
  echo "ROS IP CHECK(${IP}): [OK]"
else
  echo "ROS IP CHECK(${IP}): [FAILED]"
  if ask_yes_no "bashrcに追加しますか"; then
    echo "" >> ~/.bashrc
    echo "" >> ~/.bashrc
    ADD_INFO_NAME=`uname -n`
    ADD_INFO_DATE=`date "+(%Y/%m/%d %H:%M:%S)"`
    echo "# ${ADD_INFO_NAME} ${ADD_INFO_DATE}" >> ~/.bashrc
    echo "export ROS_MASTER_URI=http://${IP}:11311" >> ~/.bashrc
    echo "export ROS_IP=${IP}" >> ~/.bashrc
    source ~/.bashrc
    echo "追加しました"
    tail -n 3 ~/.bashrc
  else
    echo "add to ~/.bashrc"
    echo "export ROS_MASTER_URI=http://${IP}:11311"
    echo "export ROS_IP=${IP}"
  fi
fi

