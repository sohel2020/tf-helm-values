variable "github_owner" {
  description = "GitHub organization or user that owns the repository"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository name"
  type        = string
}

variable "cluster_name" {
  description = "Cluster name used to build the values file name (<cluster_name>-values.yaml)"
  type        = string
}

variable "git_ref" {
  description = "Git branch to read directories from and commit files to"
  type        = string
  default     = "main"
}

variable "helm_values_path" {
  description = "Path inside the repo where chart value directories live"
  type        = string
  default     = "helm-values"
}

variable "file_header" {
  description = "Initial content written when a values file is created"
  type        = string
  default     = "# Created by Terraform\n"
}
