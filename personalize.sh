#!/bin/bash

# Removed contents to prevent exposure to public
ACCOUNT_NAME=""
ACCOUNT_PASSWORD=""
ACCOUNT_AUTHORIZED_KEY=""

# Make sure this script is run by root user.
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Getting ID and its password to create
read -p "ID: " ACCOUNT_NAME
read -s -p "Enter Password: " ACCOUNT_PASSWORD
echo
read -p "Enter SSH public key: " ACCOUNT_AUTHORIZED_KEY

ACCOUNT_HOME_DIR="/home/$ACCOUNT_NAME"
OH_MY_ZSH_INSTALL_COMMAND='wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh'
ZSH_SYNTAX_HIGHLIGHTING_INSTALL_COMMAND='git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-/home/'"$ACCOUNT_NAME"'/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting'

apt update && apt install -y zsh git

echo "$ACCOUNT_NAME	ALL=(ALL:ALL)	NOPASSWD:ALL" >> /etc/sudoers
useradd -d $ACCOUNT_HOME_DIR $ACCOUNT_NAME -m -s `which zsh` -U
usermod -a -G sudo $ACCOUNT_NAME

ACCOUNT_SSH_DIR="$ACCOUNT_HOME_DIR/.ssh"
mkdir -p $ACCOUNT_SSH_DIR
echo $ACCOUNT_AUTHORIZED_KEY > $ACCOUNT_SSH_DIR/authorized_keys
chmod 600 $ACCOUNT_SSH_DIR/authorized_keys
chmod 700 $ACCOUNT_SSH_DIR
chown -R $ACCOUNT_NAME:$ACCOUNT_NAME $ACCOUNT_SSH_DIR

echo -e "$ACCOUNT_PASSWORD\n$ACCOUNT_PASSWORD\n" | passwd $ACCOUNT_NAME

ZSH_PATH=`which zsh`
OH_MY_ZSH_INSTALL_SCRIPT="$ACCOUNT_HOME_DIR/install.sh"
$OH_MY_ZSH_INSTALL_COMMAND -O $OH_MY_ZSH_INSTALL_SCRIPT
chown $ACCOUNT_NAME:$ACCOUNT_NAME $OH_MY_ZSH_INSTALL_SCRIPT
chmod u+x $ACCOUNT_HOME_DIR/install.sh
su -s `which bash` -c "echo -e \"$ACCOUNT_PASSWORD\\nexit\\n\" | $ACCOUNT_HOME_DIR/install.sh" $ACCOUNT_NAME
rm $OH_MY_ZSH_INSTALL_SCRIPT
su -s $ZSH_PATH -c "$ZSH_SYNTAX_HIGHLIGHTING_INSTALL_COMMAND" $ACCOUNT_NAME
su -s $ZSH_PATH -c "sed -i \"s/^ZSH_THEME.*$/ZSH_THEME=\\\"refined\\\"/g\" \"/home/$ACCOUNT_NAME/.zshrc\"" $ACCOUNT_NAME
su -s $ZSH_PATH -c "sed -i \"s/^plugins=(/plugins=(\n  zsh-syntax-highlighting \n/g\" \"/home/$ACCOUNT_NAME/.zshrc\"" $ACCOUNT_NAME


