#!/bin/bash
error()
{
	printf "$@"
	exit 1
}

test ! -d $HOME/.superbash ||  error "SuperBash already deployed in your environment. Please use update.sh instead \n"
test -d ./bash_env || error "This script should be run in root directory ! Abort !\n"

#deploy the env
cp -rv bash_env/ $HOME/.superbash
echo ". \$HOME/.superbash/bash_global" >> $HOME/.bashrc

which vim > /dev/null 2>&1
if test $? -eq 0
then
printf " * VIM deployment\n"
mkdir -p $HOME/.vim/bundle
cp ./vim/vimrc $HOME/.superbash/vimrc
tar xf ./vim/vundle.tar.gz -C $HOME/.vim/bundle
ln -sf $HOME/.superbash/vimrc $HOME/.vimrc
vim -e +PluginInstall +qall 2>/dev/null
else
printf " * Skipping VIM deployment: vim not found\n"
fi
#deploy vim

#which i3 > /dev/null 2>&1
#if test $? -eq 0
#then
#printf " * I3 configuration deployment\n"
#mkdir -p $HOME/.i3
#cp -rv ./i3/* $HOME/.i3/
#else
#printf " * Skipping i3 deployment: i3 not found\n"
#fi 

printf "Installation completed !\n"

