#!/bin/bash
error()
{
	printf "$@"
	exit 1
}

test ! -d $HOME/.superbash ||  error "SuperBash already deployed in your environment. Please use update.sh instead \n"
test -d ./bash_env || error "This script should be run in root directory ! Abort !\n"

#deploy the env
ln -sf $PWD/bash_env $HOME/.superbash
echo ". \$HOME/.superbash/bash_global" >> $HOME/.bashrc

which vim > /dev/null 2>&1
if test $? -eq 0
then
printf " * VIM deployment\n"
mkdir -p $HOME/.vim/bundle
ln -sf $PWD/vim/vimrc $HOME/.vimrc
tar xf $PWD/vim/vundle.tar.gz -C $HOME/.vim/bundle
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
#ln -sf $PWD/i3/* $HOME/.i3/
#else
#printf " * Skipping i3 deployment: i3 not found\n"
#fi 

printf "Installation completed !\n"

