#!/bin/sh

get_url()
{
	echo 'https://github.com/tmux/tmux.git'
}

get_linkpaths()
{
	echo ".tmux.conf"
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
	echo "Installing tmux"
}
