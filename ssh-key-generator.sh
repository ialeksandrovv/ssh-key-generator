#!/bin/bash

# SSH Key Generator for Web-based Repositories

updateConfig() {
  [ ! -f ~/.ssh/config ] && touch config && chmod 600 config && echo -e "\e[38;5;12mFile \"~/.ssh/config\" created.\033[0m"

  [ -n "$2" ] && echo -e "#$1 account \nHost ${1}-${2}\n\tHostName ${1}\n\tIdentitiesOnly yes\n\tIdentityFile ~/.ssh/$3\n\tPreferredAuthentications publickey" >> ~/.ssh/config || echo -e "#$1 account \nHost ${1}\n\tHostName ${1}\n\tIdentitiesOnly yes\n\tIdentityFile ~/.ssh/$3\n\tPreferredAuthentications publickey" >> ~/.ssh/config

  echo -e "\e[38;5;12mConfig successfully updated.\033[0m"
}

generateSSHKey() {
  [ ! -d ~/.ssh ] && mkdir ~/.ssh && echo -e "\e[38;5;12mFolder \"~/.ssh\" created.\033[0m"

  cd ~/.ssh

  while [ -z "${KEY_FILE_NAME}" -o -f ~/.ssh/id_${2}_$KEY_FILE_NAME -o -f ~/.ssh/id_${2}_${KEY_FILE_NAME}.pub ]
  do
    echo -n -e "\e[38;5;9m[REQUIRED]\033[0m Specify the key file name: "
    read KEY_FILE_NAME

    [ -z "${KEY_FILE_NAME}" ] && echo "The specified key file name is invalid."
    [ -f ~/.ssh/id_${2}_$KEY_FILE_NAME -o -f ~/.ssh/id_${2}_${KEY_FILE_NAME}.pub ] && echo "The specified key file name already exists."
  done

  echo -n -e "\e[38;5;11m[OPTIONAL]\033[0m Specify host alias name (only necessary if You own more than one account in the same web-based git repository): "
  read HOST_ALIAS_NAME

  ssh-keygen -t $2 -f "id_${2}_$KEY_FILE_NAME"

  echo -e "\e[38;5;13mYour public key is: \033[0m"

  cat "id_${2}_$KEY_FILE_NAME.pub"

  updateConfig $1 "$HOST_ALIAS_NAME" "id_${2}_$KEY_FILE_NAME.pub"
}

chooseEncryption() {
  echo "Which encryption do You prefer?"

  readonly ENCRYPTION_OPTIONS=("ED25519" "RSA" "Exit")

  select ENCRYPTION_OPTION in "${ENCRYPTION_OPTIONS[@]}"
  do
    case $ENCRYPTION_OPTION in
      "${ENCRYPTION_OPTIONS[0]}")
        generateSSHKey $1 "ed25519"
        break
      ;;
      "${ENCRYPTION_OPTIONS[1]}")
        generateSSHKey $1 "rsa"
        break
      ;;
      "${ENCRYPTION_OPTIONS[2]}")
        break
      ;;
      *) echo "\"$REPLY\" is an invalid option."
      ;;
    esac
  done
}

echo "Which web-based repository are You using?"

readonly OPTIONS=("GitHub" "GitLab" "Exit")

select OPTION in "${OPTIONS[@]}"
do
  case $OPTION in
    "${OPTIONS[0]}")
      chooseEncryption "github.com"
      break
    ;;
    "${OPTIONS[1]}")
      chooseEncryption "gitlab.com"
      break
    ;;
    "${OPTIONS[2]}")
      break
    ;;
    *) echo "\"$REPLY\" is an invalid option."
    ;;
  esac
done

echo -e "\e[38;5;10mScript execution done.\033[0m"
