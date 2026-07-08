locals {
    uc5_vault_namespace         = "hearts"
    uc5_k8s_api_server          = "https://192.168.0.56:6443"
    uc5_vault_host		= "https://vault.example.com:8200"
    uc5_pki_int_url 		= "${local.uc5_vault_host}/v1/${local.uc5_vault_namespace}/${vault_mount.pki_int.path}"
}


data "external" "uc5_reviewer_token" {
  program = [
    "bash",
    "${path.module}/scripts/get-reviewer-token.sh",
    "vault-reviewer",
    "cert-manager"
  ]
}

resource "vault_mount" "pki_root" {
  namespace                 = local.uc5_vault_namespace
  path                      = "pki_root"
  type                      = "pki"
  max_lease_ttl_seconds     = 315360000 # 10 years
}

resource "vault_mount" "pki_int" {
  namespace = local.uc5_vault_namespace

  path = "pki_int"
  type = "pki"
}

resource "vault_pki_secret_backend_root_cert" "root" {
  namespace = local.uc5_vault_namespace

  backend = vault_mount.pki_root.path

  type        = "internal"
  common_name = "Hearts Root CA"

  ttl = "87600h"
}

resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate" {
  namespace = local.uc5_vault_namespace

  backend = vault_mount.pki_int.path

  type        = "internal"
  common_name = "Hearts Intermediate CA"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "intermediate" {
  namespace = local.uc5_vault_namespace

  backend = vault_mount.pki_root.path

  csr         = vault_pki_secret_backend_intermediate_cert_request.intermediate.csr
  common_name = "Hearts Intermediate CA"

  ttl = "26280h"
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" {
  namespace = local.uc5_vault_namespace

  backend = vault_mount.pki_int.path

  certificate = vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate
}

resource "vault_pki_secret_backend_config_urls" "pki_int" {
  namespace = local.uc5_vault_namespace

  backend = vault_mount.pki_int.path

  issuing_certificates = [
    "${local.uc5_pki_int_url}/ca"
  ]

  crl_distribution_points = [
    "${local.uc5_pki_int_url}/crl"
  ]
}

resource "vault_pki_secret_backend_role" "internal_services" {
  namespace = local.uc5_vault_namespace

  backend = vault_mount.pki_int.path
  name    = "internal-services"

  allowed_domains = [
    "internal.example.com",
    "svc.cluster.local"
  ]

  allow_subdomains          = true
  allow_localhost           = true
  allow_bare_domains        = false
  allow_wildcard_certificates = true
  allow_ip_sans             = true

  server_flag = true
  client_flag = true

  key_type = "ec"
  key_bits = 256

  key_usage = [
    "DigitalSignature"
  ]

  ext_key_usage = [
    "ServerAuth",
    "ClientAuth"
  ]

  ttl     = "1h"
  max_ttl = "168h"
}

resource "vault_pki_secret_backend_role" "web_servers" {
  namespace = local.uc5_vault_namespace

  backend = vault_mount.pki_int.path
  name    = "web-servers"

  allowed_domains = [
    "example.com"
  ]

  allow_subdomains            = true
  allow_bare_domains          = true
  allow_localhost             = true
  allow_wildcard_certificates = true
  allow_ip_sans               = true

  server_flag = true
  client_flag = true

  key_type = "rsa"
  key_bits = 2048

  key_usage = [
    "DigitalSignature",
    "KeyEncipherment"
  ]

  ext_key_usage = [
    "ServerAuth"
  ]

  ttl     = "24h"
  max_ttl = "720h"
}

resource "vault_policy" "cert_manager" {
  namespace = local.uc5_vault_namespace

  name = "pcy-ns-hearts-cert-manager"

  policy = file("policies/pcy-ns-hearts-cert-manager.hcl")
}

resource "vault_auth_backend" "uc5_kubernetes" {
  namespace = local.uc5_vault_namespace

  type = "kubernetes"
  path = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "uc5_kubernetes" {
  namespace = local.uc5_vault_namespace

  backend = vault_auth_backend.uc5_kubernetes.path

  kubernetes_host    = local.uc5_k8s_api_server
  kubernetes_ca_cert = file("${path.module}/infra/oke/ca.crt")

  token_reviewer_jwt = data.external.uc5_reviewer_token.result.token_reviewer_jwt

  disable_iss_validation = true
}

resource "vault_kubernetes_auth_backend_role" "uc5_cert_manager" {
  namespace = local.uc5_vault_namespace

  backend = vault_auth_backend.uc5_kubernetes.path

  role_name = "cert-manager"

  bound_service_account_names = [
    "vault-issuer"
  ]

  bound_service_account_namespaces = [
    "cert-manager"
  ]

  audience = "vault://vault-issuer"

  token_policies = [
    vault_policy.cert_manager.name
  ]

  token_ttl = 3600
}
