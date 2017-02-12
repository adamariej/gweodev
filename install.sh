#!/bin/bash
BUILD_PREFIX=$PWD/build
INSTALL_PREFIX=$PWD/build/install
INSTALL_APP_PREFIX=
DEPLOY_APPS=no
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
	printf "# APP INSTALL INTO $INSTALL_APP_PREFIX\n"
	printf "\n"
}

help_menu()
{
	printf "#######################################\n"
	printf "# Usage: ./install.sh"
	printf "#######################################\n"
	printf "# --prefix=<path>\n"
	printf "# --temp-prefix=<path>\n"
	printf "# --with-apps=<path>\n"
	printf "# --app-prefix=<path>\n"
	printf "# --help|-h|-help\n"
	printf "#######################################\n"
	printf "\n"

}

deploy_apps()
{
	mkdir -p $BUILD_PREFIX
	cd $BUILD_PREFIX

	for app in `cat $SOURCE_PREFIX/url.txt`
	do
		app_name=`echo $app | cut -f1 -d';'`
		app_url=`echo $app | cut -f2 -d';'`

		if test -n "`echo $app_name | \egrep "^#.*$"`"; then
			continue;
		fi

		l="`cat $SOURCE_PREFIX/configure.txt | \egrep "^$app_name;.*$"`"
		app_before="`echo $l | cut -f2 -d";"`"
		app_cargs="`echo $l | cut -f3 -d";"`"
		app_margs="`echo $l | cut -f4 -d";"`"

		rm -rf $app_name
		echo git clone --depth 1 $app_url $app_name || error "Unable to clone $app_name"
		#cd $app_name && mkdir -p build && cd build

		if test -n "$app_before"; then
			echo $app_before
		fi
		echo ../configure $app_cargs --prefix=$INSTALL_APP_PREFIX || error "Unable to run \'$app_name\' configure !"
		echo make -j4 $app_margs || error "Unable to install \'$app_name\' software !"
		echo

	done
}

deploy_link()
{
	#deploy the env
	if test ! -a $1 ; then
		ln -sf $2 $1
	else
		error "Can't override $1: Is not our symlink !\n"
	fi
}

for arg in $@
do
	case $arg in
		--temp-prefix=*)
			BUILD_PREFIX=$(read_arg "$arg" "--tmp-prefix")
			;;
		--prefix=*)
			INSTALL_PREFIX=$(read_arg "$arg" "--prefix")
			;;
		--with-apps)
			DEPLOY_APPS=yes;
			;;
		--app-prefix=*)
			INSTALL_APP_PREFIX=$(read_arg "$arg" "--app-prefix")
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
test -z "$INSTALL_APP_PREFIX" && INSTALL_APP_PREFIX="$INSTALL_PREFIX/products"
print_config

##### CHECKS ######
# assert if trying to build or install in src tree
test "$BUILD_PREFIX"   = "$SOURCE_PREFIX" && error "Can't build our distrib directly in source tree !\n"
test "$INSTALL_PREFIX" = "$SOURCE_PREFIX" && error "Can't install directly in SRC tree !\n"
test "$DEPLOY_APPS" = "yes" -a "$INSTALL_APP_PREFIX" = "$SOURCE_PREFIX" && error "Can't install apps directly in SRC tree\n"

if test "$DEPLOY_APPS" = "yes"; then
	deploy_apps
fi
exit 0


deploy_link "$INSTALL_PREFIX/.superenv" "$SOURCE_PREFIX/env"
deploy_link "$INSTALL_PREFIX/.vimrc" "$SOURCE_PREFIX/vim/vimrc"
deploy_link "$INSTALL_PREFIX/.tmux.conf" "$SOURCE_PREFIX/tmux/tmux.conf"
deploy_link "$INSTALL_PREFIX/.gitconfig" "$SOURCE_PREFIX/git/gitconfig"
deploy_link "$INSTALL_PREFIX/.gitattributes_global" "$SOURCE_PREFIX/git/gitattributes_global"
deploy_link "$INSTALL_PREFIX/.gitignore_global" "$SOURCE_PREFIX/git/gititgnore_global"
deploy_link "$INSTALL_PREFIX/.gdbinit" "$SOURCE_PREFIX/gdb/gdbinit"

printf "Installation completed !\n"
if test -n "$INSTALL_APP_PREFIX"; then
	printf "To add products in your environment: please export\n"
	printf "SUPERBASH_INSTALL=$INSTALL_PREFIX\n"
	printf "PATH=\${SUPERBASH_INSTALL}/bin:\$PATH\n"
	printf "INCLUDE_PATH=\${SUPERBASH_INSTALL}/include:\$INCLUDE_PATH\n"
	printf "C_INCLUDE_PATH=\${SUPERBASH_INSTALL}/bin:\$C_INCLUDE_PATH\n"
	printf "LD_LIBRARY_PATH=\${SUPERBASH_INSTALL}/lib64:\${SUPERBASH_INSTALL}/lib:\$LD_LIBRARY_PATH\n"
	printf "MANPATH=\${SUPERBASH_INSTALL}/share/man:\$MANPATH\n"
	printf ". $INSTALL_PREFIX/.superenv/bash_global"
	printf "Think about deploying VIM plugins"
fi

