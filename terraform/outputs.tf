output "vm_ids" {
  description = "GitHub Runner VM IDs"
  value       = nirvana_compute_vm.runner[*].id
}

output "vm_public_ips" {
  description = "GitHub Runner VM public IPs"
  value       = nirvana_compute_vm.runner[*].public_ip
}

output "vpc_id" {
  description = "VPC ID"
  value       = nirvana_networking_vpc.runner.id
}

output "runner_count" {
  description = "Number of runners deployed"
  value       = var.runner_count
}
