#!/bin/bash
set -e

if [ "$#" -eq 0 ]; then
    exec /docker/run.sh
else
    exec "$@"
fi
