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

	for app in `cat $SOURCE_PREFIX/products.txt`
	do
		if test -n "`echo $app | \egrep "^#.*$"`"; then
			continue;
		fi

		if test ! -f $SOURCE_PREFIX/$app/setup.sh; then
			printf "No Setup for $app\n"
			continue;
		fi

		. $SOURCE_PREFIX/$app/setup.sh
		
		url="`get_url`"
		echo "Cloning $app from $url"
		git clone --depth 1 $url $BUILD_PREFIX/$app > /dev/null 2>&1 || error "Unable to clone $app"
		
		run_configure "$BUILD_PREFIX/$app" "$INSTALL_APP_PREFIX" || error "Unable to run \'$app_name\' configuration !"
		run_install || error "Unable to install \'$app_name\' software !"
		
		for link in `get_linkpaths`
		do
			if test ! -a $INSTALL_PREFIX/$link ; then
				ln -sf $SOURCE_PREFIX/$link $INSTALL_PREFIX/$link
			else
				error "Can't override $INSTALL_PREFIX/$link: Is not our symlink !\n"
			fi
		done

	done
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
test "$INSTALL_APP_PREFIX" = "$SOURCE_PREFIX" && error "Can't install apps directly in SRC tree\n"

deploy_apps

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

