#!/bin/sh
set -e

APP_HOME=/opt/my-app

# Update the config files
[[ -n ${EXAMPLE_VAR} ]]                && sed -i "/zoekterm/c\zoekterm = ${EXAMPLE_VAR}"                                                        $APP_HOME/etc/org.ops4j.example.cfg


if [ "$1" = 'my-app' ]; then
  exec dumb-init -- sh ./my-app
fi

exec "$@"
