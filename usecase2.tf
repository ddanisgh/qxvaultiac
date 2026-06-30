variable "kubernetes_host" {
  description = "Kubernetes API server endpoint used by the OpenBao Kubernetes auth backend."
  type        = string
}

variable "kubernetes_ca_cert_file" {
  description = "PEM encoded Kubernetes cluster CA certificate path."
  type        = string
}

data "external" "reviewer_token" {
  program = [
    "bash",
    "${path.module}/scripts/get-reviewer-token.sh"
  ]
}

resource "vault_mount" "secret" {
  namespace = vault_namespace.diamonds.path

  path = "secret"
  type = "kv-v2"
}


resource "vault_kv_secret_v2" "demo" {
  namespace = vault_namespace.diamonds.path

  mount = vault_mount.secret.path
  name  = "demo"

  data_json = jsonencode({
    api_key  = "abcd1234"
    password = "itsanotherpassword"
  })
}

resource "vault_auth_backend" "kubernetes" {
  namespace = vault_namespace.diamonds.path

  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "this" {
  namespace = vault_namespace.diamonds.path

  backend = vault_auth_backend.kubernetes.path

  kubernetes_host    = var.kubernetes_host
  kubernetes_ca_cert = file("${path.root}/${var.kubernetes_ca_cert_file}")

  token_reviewer_jwt     = data.external.reviewer_token.result.token_reviewer_jwt
  disable_iss_validation = true
}

resource "vault_kubernetes_auth_backend_role" "demo" {
  namespace = vault_namespace.diamonds.path

  backend = vault_auth_backend.kubernetes.path

  role_name = "demo"

  bound_service_account_names = [
    "sa-demo"
  ]

  bound_service_account_namespaces = [
    "default"
  ]

  token_policies = [
    vault_policy.demo_secret.name
  ]
}

resource "vault_policy" "demo_secret" {
  namespace = vault_namespace.diamonds.path

  name = "pcy-demo-secret"

  policy = file("policies/pcy-ns-diamonds-demo-secret.hcl")
}

