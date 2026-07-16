#!/bin/bash

if [ ! -f "/usr/share/koha/bin/koha-functions.sh" ]; then
    logerr "koha-functions should be present"
    exit 1
fi

source /usr/share/koha/bin/koha-functions.sh

export QUEUE=${QUEUE:-default}
export KOHA_INSTANCE=${KOHA_INSTANCE:-koha}

while ! is_instance ${KOHA_INSTANCE}; do
    echo "% * ERROR: Instance ${KOHA_INSTANCE} not initialized. Waiting and retrying"
    sleep 5
done

export QUEUE=${QUEUE:-default}
export KOHA_INSTANCE=${KOHA_INSTANCE:-koha}

echo "$ * Startup (queue = ${QUEUE})"
# Create new user and group.
username="${KOHA_INSTANCE}-koha"
if getent passwd "${KOHA_INSTANCE}" > /dev/null; then
    echo "% * User ${username} already exists."
else
    adduser --no-create-home --disabled-password \
        --gecos "Koha instance $username" \
        --home "/var/lib/koha/${KOHA_INSTANCE}" \
        --quiet "$username"
    echo "% User ${username} created"
fi

echo "% Starting worker"
koha-shell ${KOHA_INSTANCE} -c \
        "/usr/share/koha/bin/workers/background_jobs_worker.pl \
            --queue ${QUEUE}"
