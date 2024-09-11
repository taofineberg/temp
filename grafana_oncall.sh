#!/bin/bash
# This is the modification of original ericos's shell script.

# Get the url ($1), subject ($2), and message ($3)
url="$1"
subject="${2//$'\r\n'/'\n'}"
message="${3//$'\r\n'/'\n'}"

# Alert state depending on the subject indicating whether it is a trigger going in to problem state or recovering
recoversub='^RECOVER(Y|ED)?$|^OK$|^Resolved.*'

if [[ "$subject" =~ $recoversub ]]; then
    state='ok'
else
    state='alerting'
fi

payload='{
    "title": "'${subject}'",
    "state": "'${state}'",
    "message": "'${message}'"
}'

# Alert group identifier from the subject of action. Grouping will not work without ONCALL_GROUP in the action subject
regex='ONCALL_GROUP: ([a-zA-Z0-9_\"]*)'
if [[ "$subject" =~ $regex ]]; then
    alert_uid=${BASH_REMATCH[1]}
    payload='{
        "alert_uid": "'${alert_uid}'",
        "title": "'${subject}'",
        "state": "'${state}'",
        "message": "'${message}'"
    }'
fi

return=$(curl $url -d "${payload}" -H "Content-Type: application/json" -X POST)
