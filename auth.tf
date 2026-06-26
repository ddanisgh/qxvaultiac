
resource "vault_auth_backend" "keycloak" {
  type = "oidc"
  path = "oidc"
}

resource "vault_generic_endpoint" "oidc_config" {
  path = "auth/oidc/config"

  data_json = jsonencode({
    "oidc_discovery_url" = "http://192.168.0.161:7080/realms/smaaspoc"
    "oidc_client_id"     = var.keycloak_client_id
    "oidc_client_secret" = var.keycloak_secret
    "namespace_in_state" = "true"
    "default_role"       = "admin-sso"
  })
}

resource "vault_generic_endpoint" "admin-sso" {
  path = "auth/oidc/role/admin-sso"

  data_json = jsonencode({
    "user_claim"            = "preferred_username"
    "oidc_scopes"           = [
	"profile", 
	"email"
    ]
    "bound_claims"	    = {
	"groups" = "/vault-users*"
    }
    "bound_claims_type"	    = "glob"
    "groups_claim"	    = "groups"
    "role_type" 	    = "oidc"
    "allowed_redirect_uris" = [
	"https://192.168.0.3:8200/v1/auth/oidc/callback",
	"https://192.168.0.3:8200/ui/vault/auth/oidc/oidc/callback",
	"http://localhost:8250/oidc/callback"
    ]
    "ttl" = "1h"
  })
}
