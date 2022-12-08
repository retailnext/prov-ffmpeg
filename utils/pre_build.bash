#!/bin/bash

###############################################################
# This must be executed from the directory with the resources #
###############################################################
set -e
set -o pipefail

# Default values
GS_BUCKET='aurora-dependencies'

function download_dep_artifacts {
    ARTIFACTS=`jq -r '.dependencies.artifact|to_entries|map(.value)|join(" ")' package.json 2>/dev/null`
    echo "[DEBUG] ARTIFACTS=${ARTIFACTS}"
    if [ "$ARTIFACTS" = "" ]
    then
        return
    fi
    for ARTIFACT in ${ARTIFACTS}
    do
        gsutil cp gs://${GS_BUCKET}/${RPM} .
    done
}

function download_sources {
    URLS=`jq -r '.dependencies.source|to_entries|map(.value)|join(" ")' package.json 2>/dev/null`
    if [ "$URLS" = "" ]
    then
        return
    fi
    for URL in ${URLS}
    do
        echo "Downloading $URL"
        curl -OJL "$URL"
    done
}

function main {
    parse_options "$@"
    download_dep_artifacts
    download_sources
}

function usage {
    echo "Usage: $0 [-s <gcp bucket name>]" 1>&2
}

function parse_options {
    while getopts ":s:" OPT; do
    case "${OPT}" in
        s)
            GS_BUCKET=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
    done
    shift $((OPTIND-1))
}

main "$@"