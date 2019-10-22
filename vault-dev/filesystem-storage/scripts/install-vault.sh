#!/bin/bash

# based on: https://raw.githubusercontent.com/hashicorp/guides-configuration/master/vault/scripts/install-vault.sh

set -x

echo "Running scripts/install-vault.sh"

VAULT_VERSION=${VERSION}
VAULT_ZIP=vault_${VAULT_VERSION}_linux_amd64.zip
VAULT_URL=${URL:-https://releases.hashicorp.com/vault/${VAULT_VERSION}/${VAULT_ZIP}}
VAULT_DIR=/usr/local/bin
VAULT_PATH=${VAULT_DIR}/vault
VAULT_CONFIG_DIR=/etc/vault.d
VAULT_CONFIG_FILE=${VAULT_CONFIG_DIR}/vault.hcl
VAULT_DATA_DIR=/opt/vault/data
VAULT_TLS_DIR=/opt/vault/tls
VAULT_ENV_VARS=${VAULT_CONFIG_DIR}/vault.conf
VAULT_PROFILE_SCRIPT=/etc/profile.d/vault.sh

echo "Downloading Vault ${VAULT_VERSION}"
[ 200 -ne $(curl --write-out %{http_code} --silent --output /tmp/${VAULT_ZIP} ${VAULT_URL}) ] && exit 1

echo "Installing Vault"
sudo unzip -o /tmp/${VAULT_ZIP} -d ${VAULT_DIR}
sudo chmod 0755 ${VAULT_PATH}
sudo chown ${USER}:${GROUP} ${VAULT_PATH}
echo "$(${VAULT_PATH} --version)"

echo "Configuring Vault ${VAULT_VERSION}"
sudo mkdir -pm 0755 ${VAULT_CONFIG_DIR} ${VAULT_DATA_DIR} ${VAULT_TLS_DIR}
sudo touch ${VAULT_ENV_VARS}

echo "Set filesystem storage backend"
sudo tee ${VAULT_CONFIG_FILE} > /dev/null <<CONFIGFILE
listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_disable   = 1
}

storage "file" {
  path = "${VAULT_DATA_DIR}"
}
CONFIGFILE

echo "Update directory permissions"
sudo chown -R ${USER}:${GROUP} ${VAULT_CONFIG_DIR} ${VAULT_DATA_DIR} ${VAULT_TLS_DIR}
sudo chmod -R 0644 ${VAULT_CONFIG_DIR}/*

echo "Set Vault profile script"
sudo tee ${VAULT_PROFILE_SCRIPT} > /dev/null <<PROFILE
export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=root
PROFILE

echo "Granting mlock syscall to vault binary"
sudo setcap cap_ipc_lock=+ep ${VAULT_PATH}

echo "Complete"
