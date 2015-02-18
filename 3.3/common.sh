#!/usr/bin/env bash

set -eo pipefail

. mod_wsgi-docker-vars

# Note that every instance of a container will have their own copy of
# the filesystem so we do not have to worry about them interfering with
# each other. We can therefore use the user_vars directory as the
# environment directory.

# Make sure we are in the correct working directory for the application.

cd ${APP_HOMEDIR}

# Docker will have set any environment variables defined in the image or
# on the command line when the container has been run. Here we are going
# to look for any statically defined environment variables provided by
# the user as part of the actual application. These will have been
# placed in the '/whiskey/user_vars' directory. The name of the file
# corresponds to the name of the environment variable and the contents
# of the file the value to set the environment variable to. Each of the
# environment variables is set and exported.

envvars=

for name in `ls ${USER_VARS_DIR} 2>/dev/null`; do
    export $name=`cat ${USER_VARS_DIR}/$name`
    envvars="$envvars $name"
done

# Run any user supplied script to be run to set, modify or delete the
# environment variables.

DEPLOY_ENV_HOOK=${WHISKEY_HOMEDIR}/action_hooks/deploy-env
if [ -x ${DEPLOY_ENV_HOOK} ]; then
    echo " -----> Running ${DEPLOY_ENV_HOOK}"
    ${DEPLOY_ENV_HOOK}
fi

# Go back and reset all the environment variables based on additions or
# changes. Unset any for which the environment variable file no longer
# exists, albeit in practice that is probably unlikely.

for name in `ls ${USER_VARS_DIR} 2>/dev/null`; do
    export $name=`cat ${USER_VARS_DIR}/$name`
done

for name in $envvars; do
    if test ! -f ${USER_VARS_DIR}/$name; then
        unset $name
    fi
done
