#!/usr/bin/env bash

TOKEN=$(kubectl create token openbao-reviewer -n default)

jq -n \
  --arg token "$TOKEN" \
  '{token_reviewer_jwt:$token}'
