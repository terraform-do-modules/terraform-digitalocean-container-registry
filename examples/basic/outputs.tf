# ------------------------------------------------------------------------------
# Outputs
# ------------------------------------------------------------------------------
output "name" {
  value       = module.container_registry[*].name
  description = "The name of the container registry."
}
