#!/bin/bash
trap exit INT 

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

create_symlinks()
{
	for link in `cat $GD_SRC/.links`
	do
		src=`echo $link    | cut -f1 -d":"`
		target=`echo $link | cut -f2 -d":" | sed -e "s,HOME,${HOME},g"`

		test -f "${target}.old" && warn "Don't want to erase a backup !" && continue
		test -e "$target"     && warn "old $target saved" && cp $target ${target}.old
		test -f "$src"        && ln -sf $GD_SRC/$src $target || warn "Trouble to create $target link !"
	done

}

build_packages()
{
	if test -d $GD_SRC/spack/ -a ! -e $GD_SRC/spack/share/spack/setup-env.sh; then
		warn "Spack not present. Cloning it first"
		(git submodule init && git submodule update) || error "Can't download Spack !"
	fi
	. $GD_SRC/spack/share/spack/setup-env.sh || error "Can't source Spack environment !"
	if test ! `type module`; then
		warn "Environment-modules not present. Installing first"
		spack install environment-modules || error "Unable to deploy environment-module"
	fi
 
	grep -v '^ *#' < $GD_SRC/.defprogs |
	while read package
	do
		test -z "$package" && continue
		spack install $package || error "Unable to install $package"
	done
}

deploy_vim()
{
	echo "Deploying VIM environment"
	mkdir -p ~/.vim/bundle
	if test -d ~/.vim/bundle/vundle.vim; then
		cd ~/.vim/bundle/vundle.vim && git pull
	else
		git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/vundle.vim || error "Can't clone vundle.vim from Github !"
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

echo "#######################################################"
echo "# Installation complete ! Just few more steps:"
echo "# 1. $GD_SRC/resources/update_bashrc.sh"
echo "  2. . ~/.bashrc"
echo "  3. spack load vim"
echo "# 4. $GD_SRC/resources/install_vimplugins.sh"
echo "###### THANKS FOR USING IT ! ##########################"
exit 0
