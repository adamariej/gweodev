#!/bin/sh

get_url()
{
	echo ''
}

get_linkpaths()
{
	echo ""
}

#$1 = SRC
#$2 = DST
run_configure()
{
	SRC=$SOURCE_PREFIX/superenv
	DST=$2

	echo "Configuring Superenv"
	if test -d $DST -a ! -e $DST/.superenv ; then
		ln -s $SRC $DST/.superenv || return 1
	fi
}

run_install()
{
	echo "Nothing to do for installing superenv"
}
