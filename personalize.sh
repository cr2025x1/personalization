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

# Checking Linux Distribution
DISTRO=`awk -F= '/^NAME/{print $2}' /etc/os-release | sed "s/\"//g"`
DIST_UBUNTU=`echo $DISTRO | grep "^Ubuntu.*" | wc -l`
DIST_CENTOS=`echo $DISTRO | grep "^CentOS.*" | wc -l`
DIST_UNKNOWN="1"

if [ "$DIST_UBUNTU" == "1" ]
    then
        PKG_INSTALL_CMD="apt update && apt install -y zsh git"
        SUPERUSER_GROUP="sudo"
        DIST_UNKNOWN="0"
fi

if [ "$DIST_CENTOS" == "1" ]
    then
        PKG_INSTALL_CMD="yum -y install git zsh wget"
        SUPERUSER_GROUP="wheel"
        DIST_UNKNOWN="0"
fi

if [ "$DIST_UNKNOWN" == "1" ]
    then
        echo "Failed to identify Linux Distro"
	exit 1
fi

WHICH_BASH=`which bash`
$WHICH_BASH -c "$PKG_INSTALL_CMD"

echo "$ACCOUNT_NAME	ALL=(ALL:ALL)	NOPASSWD:ALL" >> /etc/sudoers
WHICH_ZSH=`which zsh`
useradd -d $ACCOUNT_HOME_DIR $ACCOUNT_NAME -m -s $WHICH_ZSH -U
usermod -a -G $SUPERUSER_GROUP $ACCOUNT_NAME

ACCOUNT_SSH_DIR="$ACCOUNT_HOME_DIR/.ssh"
mkdir -p $ACCOUNT_SSH_DIR
echo $ACCOUNT_AUTHORIZED_KEY > $ACCOUNT_SSH_DIR/authorized_keys
chmod 600 $ACCOUNT_SSH_DIR/authorized_keys
chmod 700 $ACCOUNT_SSH_DIR
chown -R $ACCOUNT_NAME:$ACCOUNT_NAME $ACCOUNT_SSH_DIR

echo -e "$ACCOUNT_PASSWORD\n$ACCOUNT_PASSWORD\n" | passwd $ACCOUNT_NAME

OH_MY_ZSH_INSTALL_SCRIPT="$ACCOUNT_HOME_DIR/install.sh"
$OH_MY_ZSH_INSTALL_COMMAND -O $OH_MY_ZSH_INSTALL_SCRIPT
chown $ACCOUNT_NAME:$ACCOUNT_NAME $OH_MY_ZSH_INSTALL_SCRIPT
chmod u+x $ACCOUNT_HOME_DIR/install.sh
cd $ACCOUNT_HOME_DIR
su $ACCOUNT_NAME -s $WHICH_BASH -c "echo -e \"$ACCOUNT_PASSWORD\\nexit\\n\" | $ACCOUNT_HOME_DIR/install.sh" $ACCOUNT_NAME
rm $OH_MY_ZSH_INSTALL_SCRIPT
su $ACCOUNT_NAME -s $WHICH_ZSH -c "$ZSH_SYNTAX_HIGHLIGHTING_INSTALL_COMMAND" $ACCOUNT_NAME
su $ACCOUNT_NAME -s $WHICH_ZSH -c "sed -i \"s/^ZSH_THEME.*$/ZSH_THEME=\\\"refined\\\"/g\" \"/home/$ACCOUNT_NAME/.zshrc\"" $ACCOUNT_NAME
su $ACCOUNT_NAME -s $WHICH_ZSH -c "sed -i \"s/^plugins=(/plugins=(\n  zsh-syntax-highlighting \n/g\" \"/home/$ACCOUNT_NAME/.zshrc\"" $ACCOUNT_NAME


