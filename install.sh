#!/bin/bash
BUILD_PREFIX=
INSTALL_PREFIX="$PWD"
APP_INSTALL_PREFIX=
SOURCE_PREFIX=$(readlink -f `dirname $0`)
error()
{
	printf "ERROR: $@"
	exit 1
}

read_arg()
{
	echo "x$1" | sed -e "s/^x$2=//g"
}

print_config()
{
	printf "# PROJECT SRC INTO $SOURCE_PREFIX\n"
	printf "# BUILDING    INTO $BUILD_PREFIX\n"
	printf "# INSTALLING  INTO $INSTALL_PREFIX\n"
	printf "# APP INSTALL INTO $APP_INSTALL_PREFIX\n"
	printf "\n"
}

help_menu()
{
	printf "#######################################\n"
	printf "# Usage: ./install.sh"
	printf "#######################################\n"
	printf "# --prefix=<path>"
	printf "# --bprefix=<path>"
	printf "# --help"
	printf "#######################################\n"
	printf "\n"

}

for arg in $@
do
	case $arg in
		--bprefix=*)
			BUILD_PREFIX=$(read_arg "$arg" "--bprefix")
			;;
		--prefix=*)
			INSTALL_PREFIX=$(read_arg "$arg" "--prefix")
			;;
		--help|-h|-help)
			help_menu
			exit 0
			;;
		*)
			error "Unknown Argument --> \"$arg\""
			;;
	esac
done


test -z "$BUILD_PREFIX" && BUILD_PREFIX=`mktemp -d`
APP_INSTALL_PREFIX="$INSTALL_PREFIX/.usr"

print_config

##### CHECKS ######

# assert if trying to build or install in src tree
test "$BUILD_PREFIX" = "$SOURCE_PREFIX" -o "$INSTALL_PREFIX" = "$SOURCE_PREFIX" && error "Can't build or install in SRC tree !\n"

# Check if we can deploy env/ solution
test -e $INSTALL_PREFIX/.superbash -a ! -L $INSTALL_PREFIX/.superbash && error "Can't override \$HOME/.superbash: Is not our symlink !\n"

# Check if we can deploy vim/ solution
test -e $INSTALL_PREFIX/.vimrc -a ! -L $INSTALL_PREFIX/.vimrc && error "Can't override \$HOME/.vimrc: Is not our symlink !\n"

# Check if we can deploy GDB solution
test -e $INSTALL_PREFIX/.gdbinit -a ! -L $INSTALL_PREFIX/.gdbinit && error "Can't override \$HOME/.gdbinit: Is not our symlink !\n"

exit 0






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

printf "Installation completed !\n"

