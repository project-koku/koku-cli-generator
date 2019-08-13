#!/usr/bin/env bash
# Requires the following environment variables to be set:
REQUIRED=(
    API_AUTH_USERNAME API_AUTH_PASSWORD API_JSON_URL
    COMMITTER_EMAIL COMMITTER_NAME REPO_BRANCH
    GITHUB_USERNAME GITHUB_PASSWORD
)
unset FAIL
for VAR_NAME in ${REQUIRED[@]}; do
    [ -z "${!VAR_NAME}" ] && echo "missing " ${!VAR_NAME} && FAIL=1
done
# If any of those were not set, exit early.
[ -z "${FAIL}" ] || exit 1

# Reasonable defaults of these environment variables are not set:
[ -z "${GITHUB_REPO_PATH}" ] && GITHUB_REPO_PATH="project-koku/koku-cli"
[ -z "${GENERATOR_TYPE}" ] && GENERATOR_TYPE="bash"

API_JSON="/tmp/openapi.json"
REPO_DIR="/tmp/koku-cli-git"
REPO_URL="https://${GITHUB_USERNAME}:${GITHUB_PASSWORD}@github.com/${GITHUB_REPO_PATH}.git"
GENERATE_DIR="${REPO_DIR}/client-${GENERATOR_TYPE}"

# If any command fails, exit early.
set -e

# Pull down the openapi.json specification.
curl -u "${API_AUTH_USERNAME}:${API_AUTH_PASSWORD}" "${API_JSON_URL}" -o "${API_JSON}"

# Prepare the repo clone.
git clone "${REPO_URL}" "${REPO_DIR}"
cd "${REPO_DIR}"
git config --local user.email "${COMMITTER_EMAIL}"
git config --local user.name "${COMMITTER_NAME}"

# Prepare the branch for this build.
git checkout "${REPO_BRANCH}" || git checkout --track -b "${REPO_BRANCH}"
git rm -r --force --ignore-unmatch "${GENERATE_DIR}"

# Hand control over to openapi-generator's entrypoint script.
/usr/local/bin/docker-entrypoint.sh generate -i "${API_JSON}" -g "${GENERATOR_TYPE}" -o "${GENERATE_DIR}"

# Commit and push any changes up to GitHub.
git add "${GENERATE_DIR}"
git commit -m "generate ${GENERATOR_TYPE} code based on latest ${API_JSON_URL}"
git push origin "${REPO_BRANCH}"
