variable "kong_access_token" {
  type        = string
  sensitive   = true
  description = "Konnect personal access token to use for authentication against Kong Konnect."
}

variable "openai_access_token" {
  type        = string
  sensitive   = true
  description = "OpenAI personal access token to use for authentication against OpenAI."
}

variable "control_plane" {
  type        = string
  default     = "demo"
  description = "Name of the control plane to manage."
}

#
# kubernetes
#
variable "kind_config" {
  type        = string
  default     = null
  nullable    = true
  description = "Path to local KIND config used for configuring the cluster."
}

variable "kube_config" {
  type        = string
  default     = "~/.kube/config"
  description = "Path to Kubeconfig file used for authentication against the Kubernetes cluster."
}

variable "kube_context" {
  type        = string
  default     = null
  nullable    = true
  description = "Cluster context from var.kubeconfig used for authentication against the Kubernetes cluster."
}

variable "chat_manifest_files" {
  type        = list(string)
  default     = ["../../manifests/chat-ui.yaml"]
  description = "List of Kubernetes manifest files that contain chat UI manifest files."
}

variable "kong_helm_values_file" {
  type        = string
  default     = "../../values.yaml"
  description = "Location of the Kong values file."
}
