module "helm_values" {
  source = "../modules/helm-values"

  github_owner      = "sohel2020"
  github_repository = "tf-helm-values"
  git_ref           = "main"
  helm_values_path  = "helm-values"
  cluster_name      = "tenant-1"
}

