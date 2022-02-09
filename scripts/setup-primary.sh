#!/bin/bash

SHARED_DIR=${1}

export VAULT_TOKEN=$(sudo cat ${SHARED_DIR}/root_token-vault)

# Enable performance primary cluster
vault write -f sys/replication/performance/primary/enable

# Enable dr primary cluster
vault write -f sys/replication/dr/primary/enable

# Setup performance activation token
vault write sys/replication/performance/primary/secondary-token id=$(uuidgen) -format=json | jq -r '.wrap_info.token' | sudo tee ${SHARED_DIR}/../pr-activation-token.txt >/dev/null

# Setup dr activation token
vault write sys/replication/dr/primary/secondary-token id=$(uuidgen) -format=json | jq -r '.wrap_info.token' | sudo tee ${SHARED_DIR}/../dr-activation-token.txt >/dev/null

