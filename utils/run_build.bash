#!/bin/bash
###############################################################
# This must be executed from the directory with the resources #
###############################################################
set -e
set -o pipefail

# Default values
GS_CONTAINER_REPO=''
BUILDER_IMG_PATH=''
DRIVER_SCRIPT='build.sh'

function docker_pull_builder {
    BUILDER_IMG=`jq -r '.dependencies.image | to_entries[0] | .key + ":" + .value' package.json 2>/dev/null`
    BUILDER_IMG_PATH="$GS_CONTAINER_REPO/$BUILDER_IMG"
    echo "[DEBUG] BUILDER_IMG=${BUILDER_IMG}"
    if [ "$BUILDER_IMG" = "" ]
    then
        echo "[ERROR] BUILDER_IMG is not found" 1>&2
        exit 1
    fi
    docker pull --platform linux/amd64 "$GS_CONTAINER_REPO/$BUILDER_IMG"
}

function docker_run {
    DOCKER_RUN_OPTIONS="-v $PWD:/shared -w /shared --rm --entrypoint=/bin/bash $BUILDER_IMG_PATH -l -c /shared/${DRIVER_SCRIPT}"
    echo "docker run --platform linux/amd64 $DOCKER_RUN_OPTIONS"
    docker run --platform linux/amd64 $DOCKER_RUN_OPTIONS 
}

function main {
    parse_options "$@"
    docker_pull_builder
    docker_run
}

function usage {
    echo "Usage: $0 [-s <driver script:-build.sh>][-d <gcp container repository>]" 1>&2
}

function parse_options {
    while getopts ":s:d:" OPT; do
    case "${OPT}" in
        s)
            DRIVER_SCRIPT=${OPTARG}
            ;;
        d)
            GS_CONTAINER_REPO=${OPTARG}
            ;;
        *)
            usage
            exit 1
            ;;
    esac
    done
    shift $((OPTIND-1))

    if [ "$GS_CONTAINER_REPO" == "" ]
    then
        echo "gcp container repo is not given" 1>&2
        usage
        exit 1
    fi
}

main "$@"