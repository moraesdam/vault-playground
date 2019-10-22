#!/bin/bash

# based on: https://raw.githubusercontent.com/hashicorp/guides-configuration/master/vault/scripts/install-vault-systemd.sh

set -x

echo "Running scripts/install-vault-systemd.sh"

# Detect package management system.
YUM=$(which yum 2>/dev/null)
APT_GET=$(which apt-get 2>/dev/null)

if [[ ! -z ${YUM} ]]; then
  SYSTEMD_DIR="/etc/systemd/system"
  echo "Installing systemd services for RHEL/CentOS"
elif [[ ! -z ${APT_GET} ]]; then
  SYSTEMD_DIR="/lib/systemd/system"
  echo "Installing systemd services for Debian/Ubuntu"
else
  echo "Service not installed due to OS detection failure"
  exit 1;
fi

sudo curl --silent -Lo ${SYSTEMD_DIR}/vault.service https://raw.githubusercontent.com/dmoraes/vault-playground/master/vault-dev/filesystem-storage/init/systemd/vault.service
sudo chmod 0664 ${SYSTEMD_DIR}/{vault*}

sudo systemctl enable vault
sudo systemctl start vault

echo "Complete"
