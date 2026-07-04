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
}

locals {
  helm_values_tree_sha = one([
    for entry in data.github_tree.repo.entries :
    entry.sha
    if entry.path == var.helm_values_path && entry.type == "tree"
  ])

  output_file_name = "${var.cluster_name}-values.yaml"
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
  content             = var.file_header

  lifecycle {
    ignore_changes = [content]
  }
}
