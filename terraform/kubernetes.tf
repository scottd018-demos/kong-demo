# #
# # cluster
# #
# resource "kind_cluster" "gateway" {
#   name            = var.control_plane
#   wait_for_ready  = true
#   kubeconfig_path = var.kube_config

#   # TODO: kind_config block.  workaround is to port-forward on MacOS
#   # kind_config {}
# }

# #
# # resources
# #
# locals {
#   manifests_all = flatten(
#     [
#       for manifest_file in var.manifest_files : provider::kubernetes::manifest_decode_multi(file(manifest_file))
#     ]
#   )

#   manifests_crds  = [for manifest in local.manifests_all : manifest if manifest.kind == "CustomResourceDefinition"]
#   manifests_other = [for manifest in local.manifests_all : manifest if manifest.kind != "CustomResourceDefinition"]
# }

# resource "kubernetes_manifest" "crds" {
#   count = length(local.manifests_crds)

#   manifest = local.manifests_crds[count.index]

#   timeouts {
#     create = "2m"
#     update = "2m"
#     delete = "2m"
#   }

#   wait {
#     rollout = true
#   }

#   depends_on = [kind_cluster.gateway]
# }

# resource "kubernetes_manifest" "other" {
#   count = length(local.manifests_other)

#   manifest = local.manifests_other[count.index]

#   timeouts {
#     create = "2m"
#     update = "2m"
#     delete = "2m"
#   }

#   wait {
#     rollout = true
#   }

#   depends_on = [kind_cluster.gateway, kubernetes_manifest.crds]
# }

#
# kong gateway
#
resource "kubernetes_namespace" "kong" {
  metadata {
    name = "kong"
  }
}

resource "kubernetes_secret" "kong_tls" {
  type = "kubernetes.io/tls"

  metadata {
    name      = "kong-cluster-cert"
    namespace = kubernetes_namespace.kong.metadata[0].name
  }

  data = {
    "tls.crt" = tls_self_signed_cert.konnect.cert_pem
    "tls.key" = tls_private_key.konnect.private_key_pem
  }
}

locals {
  control_plane_endpoint = replace(konnect_gateway_control_plane.control_plane.config.control_plane_endpoint, "https://", "")
  telemetry_endpoint     = replace(konnect_gateway_control_plane.control_plane.config.telemetry_endpoint, "https://", "")
}

resource "helm_release" "kong" {
  name       = "kong"
  namespace  = kubernetes_namespace.kong.metadata[0].name
  repository = "https://charts.konghq.com"
  chart      = "kong"
  version    = "2.47.0"

  values = [
    "${file(var.kong_helm_values_file)}"
  ]

  set {
    name  = "env.cluster_control_plane"
    value = "${local.control_plane_endpoint}:443"
  }

  set {
    name  = "env.cluster_server_name"
    value = local.control_plane_endpoint
  }

  set {
    name  = "env.cluster_telemetry_endpoint"
    value = "${local.telemetry_endpoint}:443"
  }

  set {
    name  = "env.cluster_telemetry_server_name"
    value = local.telemetry_endpoint
  }

  depends_on = [kubernetes_secret.kong_tls]
}

#
# chat ui
#
resource "kubernetes_namespace" "chat_ui" {
  metadata {
    name = "chat-ui"
  }
}

resource "kubernetes_secret" "openai_access_token" {
  metadata {
    name      = "openai-access-token"
    namespace = kubernetes_namespace.chat_ui.metadata[0].name
  }

  data = {
    "OPENAI_API_KEY" = var.openai_access_token
  }
}

resource "kubernetes_manifest" "chat_ui" {
  count = length(var.chat_manifest_files)

  manifest = provider::kubernetes::manifest_decode(file(var.chat_manifest_files[count.index]))

  timeouts {
    create = "2m"
    update = "2m"
    delete = "2m"
  }

  wait {
    rollout = true
  }

  depends_on = [kubernetes_namespace.chat_ui, kubernetes_secret.openai_access_token]
}
