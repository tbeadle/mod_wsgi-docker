#!/usr/bin/env bash

# This script will run 'mod_wsgi-express start-server', adding in some
# additional initial arguments to send logging to the terminal and to
# force the use of port 80. If necessary the port to use can be overridden
# using the PORT environment variable.

. mod_wsgi-docker-common

# Run any user supplied script to be run prior to starting the
# application in the actual container. The script must be executable in
# order to be run. It is not possible for this script to change the
# permissions so it is executable and then run it, due to some docker
# bug which results in the text file being busy. For more details see:
#
#   https://github.com/docker/docker/issues/9547

DEPLOY_HOOK=${WHISKEY_HOMEDIR}/action_hooks/deploy
if [ -x ${DEPLOY_HOOK} ]; then
    echo " -----> Running ${DEPLOY_HOOK}"
    ${DEPLOY_HOOK}
fi

# Now run the the actual application under Apache/mod_wsgi. This is run
# in the foreground, replacing this process and adopting process ID 1 so
# that signals are received properly and Apache will shutdown properly
# when the container is being stopped. It will log to stdout/stderr.

SERVER_ARGS="--log-to-terminal --startup-log --port 80"

exec mod_wsgi-express start-server ${SERVER_ARGS} "$@"
