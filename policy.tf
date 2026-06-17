# Create admin policy in the root namespace
resource "vault_policy" "pcy-sec-admins" {
  name   = "pcy-sec-admins"
  policy = file("policies/pcy-sec-admins.hcl")
}

resource "vault_policy" "pcy-ns-hearts-admins" {
  name   = "pcy-ns-hearts-admins"
  policy = file("policies/pcy-ns-hearts-admins.hcl")
}

resource "vault_policy" "pcy-ns-diamonds-admins" {
  name   = "pcy-ns-diamonds-admins"
  policy = file("policies/pcy-ns-diamonds-admins.hcl")
}
