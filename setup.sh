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
	echo "printf \"export GD_SRC=$GD_SRC;\n. \${GD_SRC}/gweodenv/bash_global\" >> ~/.bashrc"
}

create_symlinks()
{
	for link in `cat $GD_SRC/.links`
	do
		src=`echo $link    | cut -f1 -d":"`
		target=`echo $link | cut -f2 -d":" | sed -e "s,HOME,${HOME},g"`

		test -f "${target}.old" && warn "Don't want to erase a backup !" && continue
		test -e "$target"     && echo cp $target ${target}.old
		test -f "$src"        && ln -sf $GD_SRC/$src $target
	done

}

build_packages()
{
	if test -d $GD_SRC/spack/ -a ! -e $GD_SRC/spack/share/spack/setup-env.sh; then
		warn "Spack not present. Cloning it first"
		git submodule init && git submodule update
	fi
	. $GD_SRC/spack/share/spack/setup-env.sh
	grep -v '^ *#' < $GD_SRC/.defprogs |
	while read package
	do
		test -z "$package" && continue
		spack install $package
	done
}

deploy_vim()
{
	echo "Deploying VIM environment"
	mkdir -p ~/.vim/bundle
	if test -d ~/.vim/bundle/vundle.vim; then
		cd ~/.vim/bundle/vundle.vim && git pull
	else
		git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/vundle.vim
	fi
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

create_symlinks

deploy_vim

rm -rf $GD_TMP

echo "Installation complete !"
line_to_add_bashrc
echo "#######################################################"
echo "To install VIM plugins, run:"
echo "   vim +PluginInstall +qall"
exit 0
