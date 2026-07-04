terraform {
  required_version = ">= 1.5.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  owner = var.github_owner
}

variable "github_owner" {
  description = "GitHub organization or user that owns the repository"
  type        = string
  default     = "sohel2020"
}

variable "github_repository" {
  description = "GitHub repository name"
  type        = string
  default     = "tf-helm-values"
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

variable "output_file_name" {
  description = "File name to create inside each helm-values subdirectory"
  type        = string
  default     = "values.yaml"
}

data "github_repository" "repo" {
  full_name = "${var.github_owner}/${var.github_repository}"
}

data "github_branch" "ref" {
  repository = data.github_repository.repo.name
  branch     = var.git_ref
}

data "github_tree" "repo" {
  repository = data.github_repository.repo.name
  tree_sha   = data.github_branch.ref.sha
  recursive  = true
}

locals {
  helm_values_tree_sha = one([
    for entry in data.github_tree.repo.entries :
    entry.sha
    if entry.path == var.helm_values_path && entry.type == "tree"
  ])

  cluster_name = "my-cluster"

  output_file_name = "${local.cluster_name}-values.yaml"
}

data "github_tree" "helm_values" {
  repository = data.github_repository.repo.name
  tree_sha   = local.helm_values_tree_sha
  recursive  = false
}

locals {
  helm_dirs = [
    for entry in data.github_tree.helm_values.entries :
    entry.path
    if entry.type == "tree"
  ]
}

resource "github_repository_file" "helm_values" {
  for_each = toset(local.helm_dirs)

  repository          = data.github_repository.repo.name
  branch              = var.git_ref
  file                = "${var.helm_values_path}/${each.value}/${local.output_file_name}"
  commit_message      = "Add ${local.output_file_name} for ${each.value} via Terraform"
  overwrite_on_create = true
  content             = "# Created by Terraform\n"

  lifecycle {
    ignore_changes = [content]
  }
}

output "repository_url" {
  description = "Connected GitHub repository"
  value       = data.github_repository.repo.html_url
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
