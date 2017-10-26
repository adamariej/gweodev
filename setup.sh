#!/bin/bash

banner()
{
	echo '#######################################################'
	echo '#    ________                        .___             #'
	echo '#   /  _____/_  _  __ ____  ____   __| _/_______  __  #'
	echo '#  /   \  __\ \/ \/ // __ \/  _ \ / __ |/ __ \  \/ /  #'
	echo '#  \    \_\  \     /\  ___(  <_> ) /_/ \  ___/\   /   #'
	echo '#   \______  /\/\_/  \___  >____/\____ |\___  >\_/    #'
	echo '#          \/            \/           \/    \/        #'
	echo '#                                                     #'
	echo '#######################################################'
}

help_menu()
{
	echo '#### MAIN OPTIONS:                                    #'
	echo '  -[-]i[nstall]=<path>    The installation path       #'
	echo '#######################################################'
}

show_config()
{
	echo "#### CONFIGURATION:                                    "
	echo "  - SRC     = $GD_SRC                                  "
	echo "  - INSTALL = $GD_INSTALL                              "
	echo "  - TMP     = $GD_TMP                                  "
	echo "#######################################################"

}

convert_absolute_path()
{
	test -z "`echo "$1" | grep -E "^/.*$"`" && printf "$2/"
	printf "$1"
}

error()
{
	printf "Error: $@\n" 1>&2
	exit 42
}

warn()
{
	printf "Warn: $@\n" 1>&2
}

read_arg()
{
	echo "$1" | sed -re "s@^$2@@"
}

line_to_add_bashrc()
{
	echo "#######################################################"
	echo "Now add the following to your ~/.bashrc or ~/.profile:"
	echo "  export GD_SRC=$GD_SRC"
	echo "  . \${GD_SRC}/gweodenv/bash_global"
}

create_symlinks()
{
	for link in `cat $GD_SRC/.links`
	do
		src=`echo $link    | cut -f1 -d":"`
		target=`echo $link | cut -f2 -d":"`

		test -f "$target.old" && warn "Don't want to erase a backup !" && continue
		test -e "$target"     && echo cp $target $target.old
		test -f "$src"        && echo ln -sf $GD_SRC/$src $target
	done

}

build_packages()
{
	if test -d $GD_SRC/spack/ -a ! -e $GD_SRC/spack/share/spack/setup-env.sh; then
		warn "Spack not present. Cloning it first"
		echo "git submodule init && git submodule update"
	fi
	. $GD_SRC/spack/share/spack/setup-env.sh
	grep -v '^ *#' < $GD_SRC/.defprogs |
	while read package
	do
		test -z "$package" && continue
		echo spack install $package
	done
}

deploy_vim()
{
	echo mkdir -p ~/.vim/bundle
	echo git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/vundle.vim
	echo vim +PluginInstall +qall
	echo vim +PluginUpdate +qall
}

GD_PWD="$PWD"
GD_SRC="`dirname $0`"
GD_INSTALL=$GD_SRC/spack/opt

banner

for arg in $@
do
	case $arg in
		--install=*|-i=*)
			warn "For now, we don't handle different INSTALL_DIR than in SOURCES, sorry !"
			#GD_INSTALL="`read_arg "$arg" "--*i(nstall)*="`"
			;;
		--help|-help|-h|-H)
			help_menu
			exit 0
			;;
		*)
			help_menu
			error "Unknown argument '$arg'"
			;;
	esac
done

GD_SRC="`convert_absolute_path "$GD_SRC" "$GD_PWD"`"
GD_INSTALL="`convert_absolute_path "$GD_INSTALL" "$GD_PWD"`"

show_config

build_packages

deploy_vim

create_symlinks


rm -rf $GD_TMP

echo "Installation complete !"
line_to_add_bashrc
exit 0
