resource "vault_identity_group" "grp-sec-admins" {
  name     = "grp-sec-admins"
  type     = "external"
  policies = ["pcy-sec-admins"]

  metadata = {
    version = "1"
  }
}

resource "vault_identity_group_alias" "admingroup1" {
  name           = "/vault-users/admingroup1"
  mount_accessor = vault_auth_backend.keycloak.accessor
  canonical_id   = vault_identity_group.grp-sec-admins.id
}

resource "vault_identity_group" "grp-ns-hearts-admins" {
  name     = "grp-ns-hearts-admins"
  type     = "external"
  policies = ["pcy-ns-hearts-admins"]

  metadata = {
    version = "1"
  }
}

resource "vault_identity_group_alias" "testgroup1" {
  name           = "/vault-users/testgroup1"
  mount_accessor = vault_auth_backend.keycloak.accessor
  canonical_id   = vault_identity_group.grp-ns-hearts-admins.id
}

resource "vault_identity_group" "grp-ns-diamonds-admins" {
  name     = "grp-ns-diamonds-admins"
  type     = "external"
  policies = ["pcy-ns-diamonds-admins"]

  metadata = {
    version = "1"
  }
}

resource "vault_identity_group_alias" "testgroup2" {
  name           = "/vault-users/testgroup2"
  mount_accessor = vault_auth_backend.keycloak.accessor
  canonical_id   = vault_identity_group.grp-ns-diamonds-admins.id
}
