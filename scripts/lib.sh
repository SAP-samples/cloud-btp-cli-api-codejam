#!/usr/bin/env bash
# shellcheck disable=SC2034

# To be sourced within the generate-* scripts in this directory.

set -o errexit

declare uaa_url clientid clientsecret service_key_file

service_key_file="${1:?Specify name of file containing service key data}"
shift

uaa_url="$(jq -r .credentials.uaa.url "${service_key_file}")"
clientid="$(jq -r .credentials.uaa.clientid "${service_key_file}")"
clientsecret="$(jq -r .credentials.uaa.clientsecret "${service_key_file}")"

if [[ -z $uaa_url ]]; then
  echo "No service key data available"
  exit 1
fi
