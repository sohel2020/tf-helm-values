output "repository_url" {
  description = "Connected GitHub repository"
  value       = data.github_repository.repo.html_url
}

output "cluster_name" {
  description = "Cluster name used for values files"
  value       = var.cluster_name
}

output "output_file_name" {
  description = "Values file name created in each helm-values subdirectory"
  value       = local.output_file_name
}

output "helm_directories" {
  description = "All directories discovered under helm-values/"
  value       = local.helm_dirs
}

output "created_files" {
  description = "Files created inside each helm-values subdirectory"
  value = {
    for name, file in github_repository_file.helm_values : name => file.file
  }
}
