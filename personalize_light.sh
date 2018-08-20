#!/usr/bin/zsh

OH_MY_ZSH_INSTALL_COMMAND='wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh'
ZSH_SYNTAX_HIGHLIGHTING_INSTALL_COMMAND="git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
WHICH_ZSH=`which zsh`

git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
$WHICH_ZSH -c "$ZSH_SYNTAX_HIGHLIGHTING_INSTALL_COMMAND"
sed -i "s/^ZSH_THEME.*$/ZSH_THEME=\"refined\"/g" "$HOME/.zshrc"
sed -i "s/^plugins=(/plugins=(\n  zsh-syntax-highlighting \n/g" "$HOME/.zshrc"
