# GitHub Self-Hosted Runners on Nirvana Labs

Deploy GitHub Actions self-hosted runners on Nirvana Labs cloud infrastructure.

## Structure

```
.
├── terraform/          # Infrastructure provisioning
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── ansible/            # Runner installation
│   ├── playbook.yml
│   ├── ansible.cfg
│   └── inventory.ini.example
├── scripts/
│   └── generate-inventory.sh
└── README.md
```

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/) >= 2.9
- Nirvana Labs account and API key
- SSH key pair
- GitHub Personal Access Token (PAT) with:
  - `repo` scope (for repository-level runners)
  - `admin:org` scope (for organization-level runners)

## Resources Created

| Resource | Specification |
|----------|---------------|
| VPC | With subnet in us-sva-2 |
| Firewall | Port 22 (SSH) |
| VM | 4 vCPU, 8 GB RAM, 64 GB SSD |

## Quick Start

### 1. Provision Infrastructure

```bash
cd terraform

export NIRVANA_LABS_API_KEY="your-api-key"

terraform init
terraform plan -var='ssh_public_key=ssh-ed25519 AAAA...' -var='project_id=your-project-id'
terraform apply -var='ssh_public_key=ssh-ed25519 AAAA...' -var='project_id=your-project-id'
```

Note the `vm_public_ips` output.

### 2. Install GitHub Runner

```bash
# Generate inventory from terraform output
cd ..
./scripts/generate-inventory.sh

# Run playbook
cd ansible
ansible-playbook playbook.yml
```

The playbook will prompt for:
1. **GitHub PAT** - Your Personal Access Token
2. **GitHub Owner** - Your username or organization name
3. **GitHub Repo** - Repository name (leave empty for org-level runner)

### 3. Verify Runner

1. Go to your repository/organization Settings → Actions → Runners
2. You should see your runner(s) listed as "Idle"

## Multiple Runners

Deploy multiple runners by setting `runner_count`:

```bash
terraform apply -var='ssh_public_key=...' -var='project_id=...' -var='runner_count=3'
```

Each runner will be registered separately with GitHub.

## Terraform Variables

| Name | Description | Default |
|------|-------------|---------|
| `project_id` | Nirvana Labs project ID | - |
| `region` | Deployment region | `us-sva-2` |
| `vm_name` | VM name prefix | `github-runner` |
| `runner_count` | Number of runner VMs | `1` |
| `vcpu` | Number of vCPUs | `4` |
| `memory_gb` | Memory in GB | `8` |
| `boot_volume_gb` | Boot volume in GB (min 64) | `64` |
| `ssh_public_key` | SSH public key | - |

## Outputs

| Name | Description |
|------|-------------|
| `vm_ids` | Runner VM IDs |
| `vm_public_ips` | Runner VM public IPs |
| `vpc_id` | VPC ID |
| `runner_count` | Number of runners deployed |

## Ansible Variables

The playbook uses these defaults (can be overridden):

| Variable | Default | Description |
|----------|---------|-------------|
| `runner_version` | `2.321.0` | GitHub runner version |
| `runner_user` | `runner` | Linux user for runner |
| `runner_dir` | `/opt/actions-runner` | Installation directory |
| `runner_labels` | `self-hosted,Linux,X64` | Runner labels |

## Creating a GitHub PAT

1. Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Select scopes:
   - For repo-level runner: `repo` (full control)
   - For org-level runner: `admin:org`
4. Copy the token and use it when running the playbook

## Clean Up

### Remove Runner from GitHub

SSH into the VM and run:

```bash
cd /opt/actions-runner
sudo ./svc.sh stop
sudo ./svc.sh uninstall
./config.sh remove --token YOUR_REMOVAL_TOKEN
```

Get the removal token from: Settings → Actions → Runners → [Your Runner] → Remove

### Destroy Infrastructure

```bash
cd terraform
terraform destroy -var='ssh_public_key=...' -var='project_id=...'
```

## Troubleshooting

### Runner not appearing in GitHub

1. Check runner service status:
   ```bash
   ssh ubuntu@<ip> "cd /opt/actions-runner && sudo ./svc.sh status"
   ```

2. Check runner logs:
   ```bash
   ssh ubuntu@<ip> "journalctl -u actions.runner.* -f"
   ```

### Docker permission denied

Ensure the runner user is in the docker group:
```bash
ssh ubuntu@<ip> "sudo usermod -aG docker runner && sudo systemctl restart actions.runner.*"
```
