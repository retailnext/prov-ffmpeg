#!/bin/bash -e

###############################################################
# This must be executed from the directory with the resources #
###############################################################
set -e
set -o pipefail

# Default values
GCP_YUM_REPO=''

function post_rpms {
    PREFIX=`jq -r .package package.json`
    for RPM in ${PREFIX}*.rpm; do
    echo "Uploading $RPM"
    gcloud artifacts yum upload ${GCP_YUM_REPO} --location=us --source=$RPM
done
}


function main {
    parse_options "$@"
    post_rpms
}

function usage {
    echo "Usage: $0 [-y <gcp yum repository>]" 1>&2
}

function parse_options {
    while getopts ":y:" OPT; do
    case "${OPT}" in
        y)
            GCP_YUM_REPO=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
    done
    shift $((OPTIND-1))

    if [ "$GCP_YUM_REPO" = "" ]
    then
        echo "[ERROR] GCP yum repository name is not found" 1>&2
        exit 1
    fi
}

main "$@"