variable "kong_access_token" {}
variable "openai_access_token" {}

module "test" {
  source = "/Users/dscott/VSCode/github/scottd018/demos/kong-demo/terraform"

  kong_access_token   = var.kong_access_token
  openai_access_token = var.openai_access_token
  kube_config         = "./kubeconfig"
  kind_config         = "../../kind.yaml"
}
