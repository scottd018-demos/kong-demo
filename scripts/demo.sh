#!/usr/bin/env sh

set -e

. ./env

KONG_PROXY_URL="http://127.0.0.1.nip.io:8000"
echo "using KONG_PROXY_URL: [${KONG_PROXY_URL}]..."
#echo "using OPENAI_API_KEY: [$OPENAI_API_KEY]..."

# run demo get models
echo "running get models..."
DEMO_GET_OUT=$(curl --http1.1 -s -X GET $KONG_PROXY_URL/openai/v1/models \
  --header "Accept: application/json" \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $OPENAI_API_KEY")
echo `echo $DEMO_GET_OUT | jq -r`

# run demo post chat
echo "running demo..."
DEMO_OUT=$(curl --http1.1 -s -X POST $KONG_PROXY_URL/openai/v1/chat/completions \
  --header "Accept: application/json" \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $OPENAI_API_KEY" \
  --data-raw '{ "model": "gpt-4o-mini", "messages": [ { "role": "system", "content": "You are a mathematician" }, { "role": "user", "content": "Say this is a test!"} ] }')

echo $(echo $DEMO_OUT | jq -r)
