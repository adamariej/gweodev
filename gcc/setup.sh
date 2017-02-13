#!/bin/sh

get_url()
{
	echo 'https://github.com/...'
}

get_linkpaths()
{
	echo ".gitconfig .gitattributes_global .gitignore_global"
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
}
