#!/usr/bin/env bash

set -euo pipefail

SERVICE_ACCOUNT="$1"
NAMESPACE="$2"

TOKEN=$(kubectl create token \
  "$SERVICE_ACCOUNT" \
  -n "$NAMESPACE")

jq -n \
  --arg token "$TOKEN" \
  '{token_reviewer_jwt:$token}'
