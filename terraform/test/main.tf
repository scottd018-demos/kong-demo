variable "kong_access_token" {}
variable "openai_access_token" {}

module "test" {
  source = "../"

  kong_access_token   = var.kong_access_token
  openai_access_token = var.openai_access_token
  kube_config         = "./kubeconfig"
  kind_config         = "../../kind.yaml"
  manifest_files = [
    "../../manifests/metallb.yaml"
  ]
  # manifest_file = "../../manifests/metallb.yaml"
}
