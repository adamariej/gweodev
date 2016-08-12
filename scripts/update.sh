#!/bin/bash

test ! -d ./bash_env && printf "This script should be run from root directory !\n" && exit 1

test -d $HOME/.superbash && (
printf " * Bash-env updating\n"
cp -rvf ./bash_env/* $HOME/.superbash/
) || printf " * bash-env configuration not updated\n"

printf "\n"
test -d $HOME/.vim && (
printf " * VIM updating\n"
cp -vf ./vim/vimrc $HOME/.superbash/vimrc
vim +PluginUpdate +qall
) || printf " * VIM configuration not updated\n"

printf "\n"
test -d $HOME/.i3 && (
printf " * I3 udating (not replacing i3status)\n"
cp -vf ./i3/config $HOME/.i3/config
) || printf " * I3 configuration not updated\n"
