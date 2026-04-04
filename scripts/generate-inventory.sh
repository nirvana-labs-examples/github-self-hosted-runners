#!/bin/bash
# Generate Ansible inventory from Terraform output

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/../terraform"
ANSIBLE_DIR="$SCRIPT_DIR/../ansible"

cd "$TERRAFORM_DIR"

# Get runner IPs from terraform output
RUNNER_IPS=$(terraform output -json vm_public_ips | jq -r '.[]')
RUNNER_COUNT=$(terraform output -raw runner_count)

# Generate inventory file
INVENTORY_FILE="$ANSIBLE_DIR/inventory.ini"

echo "[runners]" > "$INVENTORY_FILE"

i=1
for IP in $RUNNER_IPS; do
  if [ "$RUNNER_COUNT" -eq 1 ]; then
    echo "github-runner ansible_host=$IP ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_ed25519" >> "$INVENTORY_FILE"
  else
    echo "github-runner-$i ansible_host=$IP ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_ed25519" >> "$INVENTORY_FILE"
  fi
  ((i++))
done

echo ""
echo "Inventory generated at $INVENTORY_FILE"
echo "Runner IPs: $(echo $RUNNER_IPS | tr '\n' ' ')"
