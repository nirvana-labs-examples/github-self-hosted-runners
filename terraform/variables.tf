variable "project_id" {
  description = "Nirvana Labs project ID"
  type        = string
  default     = null
}

variable "region" {
  description = "Region to deploy resources"
  type        = string
  default     = "us-sva-2"
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
  default     = "github-runner-vpc"
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
  default     = "github-runner-subnet"
}

variable "vm_name" {
  description = "VM name prefix"
  type        = string
  default     = "github-runner"
}

variable "runner_count" {
  description = "Number of runner VMs to create"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "Instance type (e.g., n1-standard-2, n1-standard-4)"
  type        = string
  default     = "n1-standard-4"
}

variable "boot_volume_gb" {
  description = "Boot volume size in GB (min 64 for ABS)"
  type        = number
  default     = 64
}

variable "os_image" {
  description = "OS image name"
  type        = string
  default     = "ubuntu-noble-2025-10-01"
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}

variable "tags" {
  description = "Tags to apply to VPC"
  type        = list(string)
  default     = ["github-runner", "terraform"]
}

variable "tags_list" {
  description = "Tags to apply to resources (list format)"
  type        = list(string)
  default     = ["github-runner", "terraform"]
}
