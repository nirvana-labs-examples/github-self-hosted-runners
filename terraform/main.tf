terraform {
  required_providers {
    nirvana = {
      source = "nirvana-labs/nirvana"
    }
  }
}

provider "nirvana" {}

# VPC for GitHub Runner
resource "nirvana_networking_vpc" "runner" {
  name        = var.vpc_name
  region      = var.region
  project_id  = var.project_id
  subnet_name = var.subnet_name
  tags        = var.tags
}

# Firewall rule - SSH access
resource "nirvana_networking_firewall_rule" "runner_ssh" {
  vpc_id              = nirvana_networking_vpc.runner.id
  name                = "runner-ssh"
  protocol            = "tcp"
  source_address      = "0.0.0.0/0"
  destination_address = nirvana_networking_vpc.runner.subnet.cidr
  destination_ports   = ["22"]
  tags                = var.tags_list
}

# GitHub Runner VM(s)
resource "nirvana_compute_vm" "runner" {
  count = var.runner_count

  name              = var.runner_count > 1 ? "${var.vm_name}-${count.index + 1}" : var.vm_name
  project_id        = var.project_id
  region            = var.region
  os_image_name     = var.os_image
  public_ip_enabled = true
  subnet_id         = nirvana_networking_vpc.runner.subnet.id

  cpu_config = {
    vcpu = var.vcpu
  }

  memory_config = {
    size = var.memory_gb
  }

  boot_volume = {
    size = var.boot_volume_gb
    type = "abs"
    tags = var.tags_list
  }

  ssh_key = {
    public_key = var.ssh_public_key
  }

  tags = var.tags_list
}
