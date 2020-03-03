function mcd()
{
	mkdir -p $1 && cd $1
}

function mpcload()
{
	test -z "$GWEODEV_MPC_INSTALL" && return
	mpcpath=$GWEODEV_MPC_INSTALL;
	main=$1
	if test $# -eq 0; then
		printf "Currently installed:\n"
		\ls $mpcpath
		return;
	fi
	shift # for MPC reasons

	if test -f $mpcpath/$main/mpcvars.sh; then
		source $mpcpath/$main/mpcvars.sh
	else
		printf "Unable to source $main version: $mpcpath/$main/mpcvars.sh not found !\n"
	fi
}

function spackload()
{
	test -z "$GWEODEV_SPACK_PATH" && GWEODEV_SPACK_PATH=$HOME/.gweodev/spack
	spackpath=$GWEODEV_SPACK_PATH
	. $spackpath/share/spack/setup-env.sh
	>&2 echo "Spack successfully loaded !"
}

function mpcbuild()
{
	test -z "$GWEODEV_MPC_BUILD" && return
	mpcpath=$GWEODEV_MPC_BUILD;
	if test $# = "0"; then
		printf "Available build/ directories:\n"
		\ls $mpcpath
		return;
	fi
	main=$1
	shift #for MPC reaseon

	if test -d $mpcpath/$main; then
		cd $mpcpath/$main
	else
		printf "Unable to chdir to $mpcpath/$main: not a directory\n"
	fi
}

