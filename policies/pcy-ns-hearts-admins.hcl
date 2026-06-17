path "sys/namespaces/hearts" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "sys/namespaces/hearts/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "hearts/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "hearts/sys/auth" {
  capabilities = ["deny"]
}

path "hearts/sys/auth/*" {
  capabilities = ["deny"]
}

path "hearts/auth/token/*" {
  capabilities = ["deny"]
}
