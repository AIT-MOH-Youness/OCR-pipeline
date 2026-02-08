#!/usr/bin/env bash
set -euo pipefail



# ====== Config ======
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_DIR="${ANSIBLE_DIR:-"$SCRIPT_DIR/../ansible"}"
INVENTORY="${INVENTORY:-inventory.ini}"

# ====== Helpers ======
die() { echo "❌ $*" >&2; exit 1; }
info() { echo -e "\n✅ $*\n"; }

# ====== Pre-checks ======
[ -d "$ANSIBLE_DIR" ] || die "Ansible directory '$ANSIBLE_DIR' not found."
[ -f "$ANSIBLE_DIR/$INVENTORY" ] || die "Inventory '$ANSIBLE_DIR/$INVENTORY' not found."

# Ensure you're running from repo root (so ../jenkins_custom exists for copy role)
REPO_ROOT="$(pwd)"
[ -d "$REPO_ROOT/../jenkins_custom" ] || echo "!!!  jenkins_custom/ not found in repo root (copy step may fail)."
[ -d "$REPO_ROOT/../jenkins_custom_agent" ] || echo "!!!  jenkins_custom_agent/ not found in repo root (copy step may fail)."

cd "$ANSIBLE_DIR"

info "Installing Ansible Docker collection (community.docker)"
ansible-galaxy collection install community.docker

info "00_bootstrap.yml (install docker + deps on all target hosts)"
ansible-playbook -i "$INVENTORY" playbooks/00_bootstrap.yml --ask-become-pass

info "05_push_build_context.yml (copy your custom Dockerfile contexts to targets)"
ansible-playbook -i "$INVENTORY" playbooks/05_push_build_context.yml --ask-become-pass

info "10_deploy_multi.yml (build custom images on targets + run containers)"
ansible-playbook -i "$INVENTORY" playbooks/10_deploy_multi.yml --ask-become-pass

info "DONE! Multi-host infra deployed."
