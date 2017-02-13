#!/bin/sh

get_url()
{
	echo 'https://github.com/vim/vim.git'
}

get_linkpaths()
{
	echo ".vimrc"
}

#$1 = SRC
#$2 = DST
run_configure()
{
	SRC=$1
	DST=$2

	cd $SRC
}

run_install()
{
	echo "Installing vim"
}
