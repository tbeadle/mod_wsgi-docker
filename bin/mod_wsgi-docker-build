#!/usr/bin/env bash

# The master for this script exists in the Python '2.7' directory. Do
# not edit the version of this script found in other directories. When
# the version of the script in the Python '2.7' directory is modified,
# it must then be be copied into other directories. This is necessary as
# Docker when building an image cannot copy in a file from outside of
# the directory where the Dockerfile resides.

# This is the script that prepares the Python application to be run. It
# would normally be triggered from a derived docker image explicitly, or
# as a deferred ONBUILD action.
#
# The main purpose of the script is to run 'pip install' on any user
# supplied 'requirements.txt' file. In addition to that though, it will
# also run any user provided scripts for performing actions before or
# after the installation of any application dependencies. These user
# scripts enable the ability to install additional system packages, or
# run any application specific startup commands for preparing an
# application, such as for running 'collectstatic' on a Django web
# application.

# Ensure that any failure within this script or a user provided script
# causes this script to fail immediately. This eliminates the need to
# check individual statuses for anything which is run and prematurely
# exit. Note that the feature of bash to exit in this way isn't
# foolproof. Ensure that you heed any advice in:
#
#   http://mywiki.wooledge.org/BashFAQ/105
#   http://fvue.nl/wiki/Bash:_Error_handling
#
# and use best practices to ensure that failures are always detected.
# Any user supplied scripts should also use this failure mode.

set -eo pipefail

. mod_wsgi-docker-vars

# Make sure we are in the correct working directory for the application.

cd $WHISKEY_HOMEDIR

# Copy the Apache executables into the Python directory so they can
# be found without working out how to override the PATH.

ln -s $WHISKEY_HOMEDIR/apache/bin/apxs $WHISKEY_BINDIR/apxs
ln -s $WHISKEY_HOMEDIR/apache/bin/httpd $WHISKEY_BINDIR/httpd
ln -s $WHISKEY_HOMEDIR/apache/bin/rotatelogs $WHISKEY_BINDIR/rotatelogs
ln -s $WHISKEY_HOMEDIR/apache/bin/ab $WHISKEY_BINDIR/ab

# Run any user supplied script to be run prior to installing application
# dependencies. This is to allow additional system packages to be
# installed that may be required by any Python modules which are being
# installed. The script must be executable in order to be run. It is not
# possible for this script to change the permissions so it is executable
# and then run it, due to some docker bug which results in the text file
# being busy. For more details see:
#
#   https://github.com/docker/docker/issues/9547
#
# Note that because path to the action_hooks directory was changed, we
# need to warn about old deprecated name. In case that the user is using
# old name, just symlink the new location to the old. If both exist, then
# this should fail.

PRE_BUILD_HOOK=${WHISKEY_HOMEDIR}/action_hooks/pre-build
if [ -x ${PRE_BUILD_HOOK} ]; then
	echo " -----> Running ${PRE_BUILD_HOOK}"
	${PRE_BUILD_HOOK}
fi

# Check whether there are any git repositories referenced from the
# 'requirements.txt file. If there are then we need to first explicitly
# install git and only then run 'pip'.

REQ_TXT=${WHISKEY_HOMEDIR}/requirements.txt
if [ -f ${REQ_TXT} ]; then
	if (grep -Fiq "git+" ${REQ_TXT}); then
		echo " -----> Installing git"
		apt-get update && \
			apt-get install -y git --no-install-recommends && \
			rm -r /var/lib/apt/lists/*
	fi

	# Check whether there are any Mercurial repositories referenced from the
	# 'requirements.txt file. If there are then we need to first explicitly
	# install Mercurial and only then run 'pip'.

	if (grep -Fiq "hg+" ${REQ_TXT}); then
		echo " -----> Installing mercurial"
		pip install -U mercurial
	fi

	# Now run 'pip' to install any required Python packages based on the
	# contents of the 'requirements.txt' file.

	echo " -----> Installing dependencies with pip"
	pip install -r ${REQ_TXT} -U --allow-all-external \
		--exists-action=w --src=${WHISKEY_HOMEDIR}/tmp
fi

# Build and install mod_wsgi.

${WHISKEY_BINDIR}/pip install -U mod_wsgi==4.4.3

# Run any user supplied script to run after installing any application
# dependencies. This is to allow any application specific setup scripts
# to be run, such as 'collectstatic' for a Django web application. It is
# not possible for this script to change the permissions so it is
# executable and then run it, due to some docker bug which results in
# the text file being busy. For more details see:
#
#   https://github.com/docker/docker/issues/9547

BUILD_HOOK=${WHISKEY_HOMEDIR}/action_hooks/build
if [ -x ${BUILD_HOOK} ]; then
	echo " -----> Running ${BUILD_HOOK}"
	${BUILD_HOOK}
fi

# Clean up any temporary files, including the results of checking out
# any source code repositories when doing a 'pip install' from a VCS.

rm -rf ${WHISKEY_HOMEDIR}/tmp
