#
# requirements
#
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }

    konnect = {
      source  = "kong/konnect"
      version = ">=2.3.0"
    }

    # kind = {
    #   source  = "tehcyx/kind"
    #   version = ">=0.8.0"
    # }

    # kubernetes = {
    #   source  = "hashicorp/kubernetes"
    #   version = ">=2.35.1"
    # }
  }
}

#
# provider configuration
#
provider "konnect" {
  personal_access_token = var.kong_access_token
}

# provider "kubernetes" {
#   config_path    = var.kube_config
#   config_context = var.kube_context
# }
