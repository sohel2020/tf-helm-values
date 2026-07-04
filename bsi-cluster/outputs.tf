output "repository_url" {
  description = "Connected GitHub repository"
  value       = module.helm_values.repository_url
}

output "helm_directories" {
  description = "All directories discovered under helm-values/"
  value       = module.helm_values.helm_directories
}

output "created_files" {
  description = "Files created inside each helm-values subdirectory"
  value       = module.helm_values.created_files
}
