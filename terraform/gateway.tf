resource "konnect_gateway_control_plane" "control_plane" {
  name          = var.control_plane
  description   = var.control_plane
  cloud_gateway = false
  auth_type     = "pinned_client_certs"
  cluster_type  = "CLUSTER_TYPE_CONTROL_PLANE"
}

resource "konnect_gateway_service" "openai" {
  control_plane_id = konnect_gateway_control_plane.control_plane.id

  name    = "upstream-openai-models"
  enabled = true

  # upstream config
  protocol   = "https"
  host       = "api.openai.com"
  port       = 443
  path       = "/v1/models"
  tls_verify = false
}

resource "konnect_gateway_service" "proxy" {
  control_plane_id = konnect_gateway_control_plane.control_plane.id

  name    = "upstream-openai-proxy"
  enabled = true

  # upstream config
  protocol = "http"
  host     = "localhost"
  port     = 8000
}

resource "konnect_gateway_route" "models" {
  control_plane_id = konnect_gateway_control_plane.control_plane.id
  service = {
    id = konnect_gateway_service.openai.id
  }

  name                       = "route-openai-models"
  methods                    = ["GET"]
  paths                      = ["/openai/v1/models"]
  path_handling              = "v0"
  https_redirect_status_code = 426

  strip_path         = true
  request_buffering  = true
  response_buffering = true
  preserve_host      = false
}

resource "konnect_gateway_route" "chat" {
  control_plane_id = konnect_gateway_control_plane.control_plane.id
  service = {
    id = konnect_gateway_service.proxy.id
  }

  name                       = "route-openai-chat"
  paths                      = ["/openai/v1/chat/completions"]
  path_handling              = "v0"
  https_redirect_status_code = 426

  strip_path         = true
  request_buffering  = true
  response_buffering = true
  preserve_host      = false
}

resource "konnect_gateway_plugin_ai_proxy" "ai_proxy" {
  control_plane_id = konnect_gateway_control_plane.control_plane.id
  route = {
    id = konnect_gateway_route.chat.id
  }

  enabled = true

  config = {
    auth = {
      allow_override = true
      header_name    = "Authorization"
      header_value   = "Bearer ${var.openai_access_token}"
    }

    logging = {
      log_payloads   = true
      log_statistics = true
    }

    route_type = "llm/v1/chat"
    model = {
      provider = "openai"
    }
  }
}

resource "konnect_gateway_plugin_ai_rate_limiting_advanced" "rate_limiter" {
  control_plane_id = konnect_gateway_control_plane.control_plane.id
  route = {
    id = konnect_gateway_route.chat.id
  }

  enabled = true

  config = {
    dictionary_name      = "kong_rate_limiting_counters"
    disable_penalty      = false
    error_code           = 429
    error_hide_providers = false
    error_message        = "AI token rate limit exceeded for provider(s): "
    hide_client_headers  = false
    identifier           = "consumer"

    llm_providers = [
      {
        limit       = 1
        name        = "openai"
        window_size = 15
      }
    ]

    retry_after_jitter_max = 0
    strategy               = "local"
    tokens_count_strategy  = "total_tokens"
    window_type            = "sliding"
  }

  protocols = [
    "grpc",
    "grpcs",
    "http",
    "https"
  ]
}

resource "tls_private_key" "konnect" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "konnect" {
  private_key_pem = tls_private_key.konnect.private_key_pem

  subject {
    common_name = "kong_clustering"
  }

  validity_period_hours = 3650 * 24
  is_ca_certificate     = true

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing"
  ]
}

resource "konnect_gateway_data_plane_client_certificate" "data_plane" {
  control_plane_id = konnect_gateway_control_plane.control_plane.id
  cert             = tls_self_signed_cert.konnect.cert_pem
}
