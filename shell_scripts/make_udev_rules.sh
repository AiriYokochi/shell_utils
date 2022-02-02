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

function ask_yes_no_must {
  while true; do
    # echo -n "$* [Y/N]: "
    printf $*'\033[33m%s\033[m' ' [Y/N]:'
    read ANS
    case $ANS in
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


if [ $# -ne 1 ]; then
  echo "指定された引数は$#個です。" 1>&2
  echo "実行するには1個の引数が必要です。rulesを作成したいデバイスの/dev/以下のパスを入力してください" 1>&2
  echo "example: ttyUSB0"
  # exit 1
else
  #[TODO] 引数の入力チェック
  cmd=`ls /dev/$1`
  if [ -n "${cmd}" ]; then
    if ask_yes_no $1"のrulesを作成します"; then
      SUBSYSTEM=`udevadm info -a /dev/$1 | grep SUBSYSTEM | head -n 1`
      RULES_STR=${SUBSYSTEM}
      VENDOR_ID=`udevadm info -a /dev/$1 | grep idVendor | head -n 1`
      PRODUCT_ID=`udevadm info -a /dev/$1 | grep idProduct | head -n 1`
      DEVPATH=`udevadm info -a /dev/$1 | grep ATTRS{devpath} | head -n 1`
      if ask_yes_no_must "デバイスの位置を固定しますか？(複数同時デバイス接続時に推奨)"; then
        RULES_STR=${RULES_STR}", "${VENDOR_ID}", "${PRODUCT_ID}", "${DEVPATH}
      else
        RULES_STR=${RULES_STR}", "${VENDOR_ID}", "${PRODUCT_ID}
      fi

      read -p "/dev/XXXXX に表示したい名前を入力してください(デフォルトはTEST):" SIMLINK
      #[TODO] 入力チェック
      if [ "${SIMLINK}" == "" ]; then
        SIMLINK="TEST"
      fi
      if ask_yes_no_must "/dev/"${SIMLINK}"でよろしいですか"; then
        RULES_STR=${RULES_STR}", SYMLINK+="\"${SIMLINK}"\""
        echo -n "作成されたrules:"
        printf '\033[36m%s\033[m\n' '/dev/'${SIMLINK}        
        printf '\033[32m%s\033[m' ${RULES_STR}
        echo ""
        if ask_yes_no "新しくファイルを作成しますか(警告:すでに存在する場合は上書きします)"; then
          echo ${RULES_STR} > "99-"${SIMLINK}".rules"
          echo "作成しました > 99-${SIMLINK}.rules"
          echo ""
          echo "1. 以下のコマンドを実行してください"
          echo "---------------------------------"
          echo "sudo cp 99-${SIMLINK}.rules /etc/udev/rules.d/"
          echo "sudo service udev reload"
          echo "---------------------------------"
          echo "2. デバイスを指し直して設定が反映されているか確認してください"
          echo ""
          echo "終了します"
        else
          echo ""
          echo "1. 以下の文字列を/dev/udev/rules.d配下のファイルに書き加えてください"
          echo "---------------------------------"
          printf '\033[32m%s\033[m' ${RULES_STR}
          echo ""
          echo "---------------------------------"
          echo ""
          echo "終了します"
        fi
      else
        echo "終了します"
      fi 
    else
      echo "終了します"
    fi
  else
    echo "そのようなデバイスは見つかりませんでした。もう一度実行してください"
  fi
fi
