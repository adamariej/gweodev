function mcd()
{
	mkdir $1 && cd $1
}

function projects_load()
{
	projpath=$HOME/Documents/projets/;
	for proj in `ls $projpath`; 
	do
		echo "alias $proj='cd $projpath/$proj'"
	done
}

function mpcload()
{
	mpcpath=/opt/modules/mpc/
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

function mpcbuild()
{
	mpcpath=/opt/modules/mpc/builds
	main=$1
	shift #for MPC reaseon
	if test -z "$main"; then
		printf "Available build/ directories:\n"
		\ls $mpcpath
		return;
	fi

	if test -d $mpcpath/$main; then
		cd $mpcpath/$main
	else
		printf "Unable to chdir to $mpcpath/$main: not a directory\n"
	fi
}

