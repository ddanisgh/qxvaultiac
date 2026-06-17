terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }
  }
}

provider "vault" {
  address = "https://192.168.0.3:8200"
  # Token via VAULT_TOKEN (OpenBao reads the same env var as Vault)
  skip_tls_verify = true
}
