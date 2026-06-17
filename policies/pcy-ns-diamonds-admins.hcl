path "sys/namespaces/diamonds" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "sys/namespaces/diamonds/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "diamonds/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "diamonds/sys/auth" {
  capabilities = ["deny"]
}

path "diamonds/sys/auth/*" {
  capabilities = ["deny"]
}

path "diamonds/auth/token/*" {
  capabilities = ["deny"]
}
