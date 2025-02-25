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
