#!/bin/sh

get_url()
{
	echo 'https://github.com/git/git.git'
}

get_linkpaths()
{
	prefix=$1
	echo ".gitconfig .gitattributes_global .gitignore_global"
}

#$1 = SRC
#$2 = DST
run_configure()
{
	SRC=$1
	DST=$2

	cd $SRC
	make configure
	./configure --prefix=$DST
}

run_install()
{
}
