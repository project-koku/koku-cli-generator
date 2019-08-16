#!/usr/bin/env bash
# Requires the following environment variables to be set:
REQUIRED=(
    API_AUTH_USERNAME API_AUTH_PASSWORD API_JSON_URL
    GITHUB_USERNAME GITHUB_PASSWORD
)
unset FAIL
for VAR_NAME in ${REQUIRED[@]}; do
    [ -z "${!VAR_NAME}" ] && echo "missing " ${!VAR_NAME} && FAIL=1
done
# If any of those were not set, exit early.
[ -z "${FAIL}" ] || exit 1

# Reasonable defaults of these environment variables are not set:
[ -z "${VERSION}" ] && VERSION=`date +%s`

API_JSON="/tmp/openapi.json"
REPO_DIR="/tmp/koku-cli-git"
REPO_URL="https://${GITHUB_USERNAME}:${GITHUB_PASSWORD}@github.com/${GITHUB_REPO_PATH}.git"

# If any command fails, exit early.
set -e

# Pull down the openapi.json specification.
curl -u "${API_AUTH_USERNAME}:${API_AUTH_PASSWORD}" "${API_JSON_URL}" -o "${API_JSON}"

# Create a new release in Github.
RELEASE_RESPONSE=`curl -u "${GITHUB_USERNAME}:${GITHUB_PASSWORD}" -X POST https://api.github.com/repos/project-koku/koku-cli/releases -d '{"tag_name":"'"${VERSION}"'", "name":"CLI Release '"${VERSION}"'"}'`
RELEASE_ID=`echo $RELEASE_RESPONSE | jq .id`
RELEASE_UPLOAD_URL=`echo $RELEASE_RESPONSE | jq .upload_url | sed 's/{?name,label}//' | sed -r 's/"//gI'`

# Generate our clients, and upload to the github release.
for GENERATOR_TYPE in bash python ruby java go
do
    GENERATE_DIR="${REPO_DIR}/client-${GENERATOR_TYPE}"
    CLIENT_ARCHIVE_NAME=${GENERATOR_TYPE}-client.tar.gz
    /usr/local/bin/docker-entrypoint.sh generate -i "${API_JSON}" -g "${GENERATOR_TYPE}" -o "${GENERATE_DIR}"
    tar -czvf ${CLIENT_ARCHIVE_NAME} ${GENERATE_DIR}
    curl -u "${GITHUB_USERNAME}:${GITHUB_PASSWORD}" -X POST "${RELEASE_UPLOAD_URL}?name=${CLIENT_ARCHIVE_NAME}" -H Content-Type:application/tar+gzip --data-binary "@${CLIENT_ARCHIVE_NAME}"
done
