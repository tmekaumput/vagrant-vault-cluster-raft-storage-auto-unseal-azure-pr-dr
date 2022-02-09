#!/bin/bash

SHARED_DIR=${1}

export VAULT_TOKEN=$(sudo cat ${SHARED_DIR}/root_token-vault)

vault write sys/replication/dr/secondary/enable token=$(sudo cat ${SHARED_DIR}/../dr-activation-token.txt)
