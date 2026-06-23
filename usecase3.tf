# Requires pagila database just in time credentials configured in usecase1.tf

locals {
    uc3_vault_namespace = "diamonds"
}

resource "vault_policy" "pcy-pagila-reader" {
  namespace = local.uc3_vault_namespace
  
  name = "pcy-pagila-reader"
  
  policy = file("policies/pcy-ns-diamonds-pagila-reader.hcl")

}

resource "vault_auth_backend" "approle" {
  namespace = local.uc3_vault_namespace

  type = "approle"
}

resource "vault_approle_auth_backend_role" "appr-pagila-reader" {
  namespace = local.uc3_vault_namespace

  backend   = vault_auth_backend.approle.path
  role_name = "appr-pagila-reader"

  token_policies = [
    vault_policy.pcy-pagila-reader.name
  ]

  token_ttl          = 3600
  token_max_ttl      = 14400
  secret_id_num_uses = 0
  secret_id_ttl      = 3600
}
