#!/usr/bin/env bash

db_name () {
  ROLE_NAME=$1
  DB_NAME="${ROLE_NAME%-read-only}"
  echo "${DB_NAME%-read-write}"
}

target_id () {
  ROLE_NAME=$1
  TARGETS=$(boundary targets list -format json -recursive)
  TARGET_ID=$(echo "$TARGETS" | jq ".items[] | select(.name == \"$ROLE_NAME\").id" | tr -d '"')

  echo "$TARGET_ID"
}

copy_credentials_to_clipboard () {
  line=$1
  USERNAME=$(echo "$line" | jq -r '.credentials[0].credential.username')
  PASSWORD=$(echo "$line" | jq -r '.credentials[0].credential.password')
  CREDENTIALS="$USERNAME#PASS:$PASSWORD"

  echo "##### Connection established with '$ROLE_NAME' in '$ENVIRONMENT' on port '$PORT'"
  echo "##### You will find the credentials in the clipboard as: USERNAME#PASS:PASSWORD"
  echo -n "$CREDENTIALS" | pbcopy
}

job_number () {
  jobs -l | grep "$1" | awk '{print $1}' | sed 's/[][()+]//g'
}

case "$2" in
  "testing" | "staging")
    ;;
  *)
    echo "Error: 2nd argument must be a valid environment. received '$2'"
    exit 1
    ;;
esac

source boundary-config.sh
ROLE_NAME=$1
ENVIRONMENT=$2
DB_NAME=$(db_name "$ROLE_NAME")
PORT="${PORT_MAPPING[$DB_NAME]}"

export BOUNDARY_ADDR="${URL_MAPPING[$ENVIRONMENT]}"
export BOUNDARY_AUTH_METHOD_ID="${METHOD_ID_MAPPING[$ENVIRONMENT]}"

boundary authenticate oidc -auth-method-id "$BOUNDARY_AUTH_METHOD_ID"
echo "##### authenticated successfully in $ENVIRONMENT"

TARGET_ID=$(target_id "$ROLE_NAME")
echo "##### connecting to role '$ROLE_NAME' with target-id '$TARGET_ID'"

# the command 'boundary connect' needs to block the process to keep the tunnel open
# and we need its output to get the credentials and copy them to the clipboard
# so it has to be
# - run in the background
# - its output piped to credentials_pipe
# - read the credentials from the pipe and set to the clipboard
# - bring the process in foreground so that the tunnel stays open

set -m
rm credentials_pipe > /dev/null 2>&1 || true
mkfifo credentials_pipe

boundary connect --target-id "$TARGET_ID" -listen-port="$PORT" -format=json > credentials_pipe &

job_num=$(job_number "${!}")

while read line; do
    if [[ "${line}" == *"username"* ]]; then
        copy_credentials_to_clipboard "$line"
        break
    fi
done < credentials_pipe

fg %${job_num}

rm credentials_pipe



