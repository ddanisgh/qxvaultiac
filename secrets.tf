# Enable KV v2 secrets engine in OpenBao
resource "vault_mount" "kv" {
  path    = "secret"
  type    = "kv"
  options = { version = "2" }
}

# Write a secret
resource "vault_kv_secret_v2" "app_config" {
  mount = vault_mount.kv.path
  name  = "prod/app"

  data_json = jsonencode({
    db_host     = "db.internal"
    db_password = var.db_password
    api_key     = var.api_key
  })
}
