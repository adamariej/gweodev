#!/bin/bash

test -d ./bash_env || ( printf "Should be run in root Git directory !\n" && exit 1 )

git archive --format=tar --prefix=superbash/ HEAD | gzip > superbash.tar.gz
