#!/bin/sh

to_print()
{
	thepath=`dirname $0`
	thepath=`readlink -e $thepath`/..
	echo "export GD_SRC=$thepath;"
	echo "\${GD_SRC}/gweodenv/bash_global"
}

to_print >> ~/.bashrc
