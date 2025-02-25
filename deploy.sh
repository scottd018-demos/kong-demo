#!/usr/bin/env sh

set -e

. ./env

KONG_URL="https://us.api.konghq.com/v2/control-planes/$KONG_GW_ID"
echo "using KONG_URL: [${KONG_URL}]..."

# create gateway service
if [[ "${KONG_SERVICE_ID}" == "" ]]; then
  echo "creating service..."
  KONG_SERVICE_ID_OUT=$(curl -s -X POST $KONG_URL/core-entities/services/ \
    --header "accept: application/json" \
    --header "Content-Type: application/json" \
    --header "Authorization: Bearer $KONG_TOKEN" \
    --data '
      {
        "name": "backend-chat",
        "url": "http://localhost:8000"
      }')

  echo $KONG_SERVICE_ID_OUT
  KONG_SERVICE_ID=$(echo $KONG_SERVICE_ID_OUT | jq -r '.id')
else
  echo "skipping 'svc' action..."
fi
echo "using KONG_SERVICE_ID: [${KONG_SERVICE_ID}]..."

# create route
if [[ "${KONG_ROUTE_ID}" == "" ]]; then
  echo "creating route..."
  KONG_ROUTE_ID_OUT=$(curl -s -X POST $KONG_URL/core-entities/services/$KONG_SERVICE_ID/routes \
    --header "accept: application/json" \
    --header "Content-Type: application/json" \
    --header "Authorization: Bearer $KONG_TOKEN" \
    --data '
      {
        "name": "chat",
        "paths": [
          "/openai"
        ]
      }')

  echo $KONG_ROUTE_ID_OUT
  KONG_ROUTE_ID=$(echo $KONG_ROUTE_ID_OUT | jq -r '.id')
else
  echo "skipping 'route' action..."
fi
echo "using KONG_ROUTE_ID: [${KONG_ROUTE_ID}]..."

# create ai proxy plugin
if [[ "${KONG_AI_PLUGIN_ID}" == "" ]]; then
  echo "creating ai plugin..."
  KONG_AI_PLUGIN_ID_OUT=$(curl -s -X POST $KONG_URL/core-entities/routes/$KONG_ROUTE_ID/plugins \
    --header "accept: application/json" \
    --header "Content-Type: application/json" \
    --header "Authorization: Bearer $KONG_TOKEN" \
    --data '
      {
        "name": "ai-proxy",
        "config": {
          "route_type": "llm/v1/chat",
          "model": {
            "provider": "openai"
          }
        }
      }')

  echo $KONG_AI_PLUGIN_ID_OUT
  KONG_AI_PLUGIN_ID=$(echo $KONG_AI_PLUGIN_ID_OUT | jq -r '.id')
else
  echo "skipping ai proxy plugin action..."
fi
echo "using KONG_AI_PLUGIN_ID: [${KONG_AI_PLUGIN_ID}]..."
