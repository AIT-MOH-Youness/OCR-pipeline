# DevSecOps CI Infrastructure (Single-host & Multi-host)

This Ansible/Bash project provides a **flexible CI infrastructure** that can be deployed:

- **On a single machine** using Docker Compose  
- **On multiple machines** using Ansible (one tool per VM if desired)

The objective is to keep:
- Jenkins pipelines **clean**
- Infrastructure **reproducible**
- Deployment **configurable without duplication**

---

## Architecture

### Single-host mode
All services run on **one machine** using Docker Compose.

- Jenkins (custom image)
- SonarQube
- Jenkins Agent (custom image)
- Trivy (inside agent)

### Multi-host mode
Each service runs on a **separate VM**, chosen by the user.

Ansible is used **only to initialize and deploy infrastructure**, not inside Jenkins pipelines.

---

## Purpose of Ansible in this project

Ansible is the **multi-host installer and orchestrator**. It:

- Installs Docker and required dependencies on target hosts
- Copies the custom Docker build contexts (Jenkins + Agent)
- Builds images on the target hosts
- Starts the containers with the correct configuration

This keeps Jenkins pipelines focused on **CI tasks**, while infra provisioning stays **reproducible and versioned** here.

---

## Tutorial (step-by-step)

### 1) Prepare your control machine (the VM where you run Ansible)

Install Ansible on the control VM (examples):

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y ansible

# RHEL/CentOS/Rocky
sudo dnf install -y ansible
```

You also need:
- Bash shell
- SSH access to target hosts (key-based auth recommended)

---

### 2) Create the ci-admin user and SSH access to target machines

On each target VM, create a dedicated admin user and allow sudo:

```bash
sudo useradd -m -s /bin/bash ci-admin
sudo usermod -aG sudo ci-admin
```

From the control machine, generate an SSH key (if you don’t already have one):

```bash
ssh-keygen -t ed25519 -C "ci-admin"
```

Copy the public key to each target VM:

```bash
ssh-copy-id ci-admin@<TARGET_IP>
```

Then connect once to verify:

```bash
ssh ci-admin@<TARGET_IP>
```

---

### 3) Prepare your target hosts (multi-host mode)

Each target VM must have:
- Linux OS
- Python installed (Ansible requires Python on the remote)
- Sudo privileges (to install Docker and run containers)

Ensure network access for:
- Jenkins: 8080
- SonarQube: 9000

---

### 4) Configure the Ansible inventory

Edit the inventory file and host variables:

- [ansible/inventory.ini](./inventory.ini)
- [ansible/host_vars](./host_vars)
- [ansible/group_vars](./group_vars)

Tip: set the SSH user and key for each host, for example:

```ini
ansible_user=ci-admin
ansible_ssh_private_key_file=~/.ssh/id_edxxxx
```

---

## Repository Structure

```
.
├── docker-compose.yml
│
└── scripts/
│   ├── infra-single-up.sh
│   ├── infra-multi-up.sh
│   ├── infra-up.sh
│   └── infra-down.sh
│  
├── jenkins_custom/
├── jenkins_custom_agent/
│
└── ansible/
    ├── inventory.ini
    ├── host_vars/
    ├── group_vars/
    ├── playbooks/
    │   ├── 00_bootstrap.yml
    │   ├── 05_push_build_context.yml
    │   └── 10_deploy_multi.yml
    └── roles/
```

---

## Single-host Deployment

Run from the scripts folder/directory:

```bash
INFRA_HOST=localhost ./infra-single-up.sh
```

---

## Multi-host Deployment

Option A — run the playbooks directly:

```bash
cd ansible
ansible-playbook playbooks/00_bootstrap.yml
ansible-playbook playbooks/05_push_build_context.yml
ansible-playbook playbooks/10_deploy_multi.yml
```

Option B — run the helper script from the scripts folder/directory:

```bash
./infra-multi-up.sh
```

---

## Unified Deployment Script (infra-up.sh)

The `infra-up.sh` script is a small wrapper that lets you choose the mode with one command.

Run from the scripts folder/directory:

```bash
# Default is single-host mode
./infra-up.sh

# Explicitly choose a mode
./infra-up.sh single
./infra-up.sh multi
```

Notes:
- `single` calls `infra-single-up.sh` (Docker Compose on one host)
- `multi` calls `infra-multi-up.sh` (Ansible multi-host deployment)

---


## Summary

One codebase, two deployment modes:
- Docker Compose for simplicity
- Ansible for scalable infrastructure
