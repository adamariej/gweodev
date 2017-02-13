#!/bin/sh

get_url()
{
	echo 'git://sourceware.org/git/binutils-gdb.git'
}

get_linkpaths()
{
	echo ".gdbinit"
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
	echo "Installing GDB"
}
