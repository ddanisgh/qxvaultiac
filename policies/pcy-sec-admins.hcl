# =====================================================================
# 1. EXPLICIT PROTECTIONS (These override everything else)
# =====================================================================

# Explicitly block them from reading, modifying, or deleting their own policy
path "sys/policies/acl/pcy-sec-admins" {
  capabilities = ["deny"]
}

# Explicitly block them from reading or tampering with the core system root policy
path "sys/policies/acl/root" {
  capabilities = ["deny"]
}

# Prevent them from looking into secret engines directly
path "secret/*" {
  capabilities = ["deny"]
}


# =====================================================================
# 2. GLOBAL SYSTEM MANAGEMENT
# =====================================================================

# Manage auth methods and identity systems
path "sys/auth*" { capabilities = ["create", "read", "update", "delete", "list", "sudo"] }
path "sys/identity*" { capabilities = ["create", "read", "update", "delete", "list"] }

# Manage ALL OTHER policies and namespaces globally (except the denied ones above)
path "sys/policies/*" { capabilities = ["create", "read", "update", "delete", "list", "sudo"] }
path "sys/namespaces/*" { capabilities = ["create", "read", "update", "delete", "list", "sudo"] }

# Allow global admins to view audit backends, but NOT create, delete, or modify them
path "sys/audit" {
  capabilities = ["read", "list"]
}
path "sys/audit/*" {
  capabilities = ["read", "list"]
}


# =====================================================================
# 3. TOKEN CREATION SAFEGUARDS
# =====================================================================

# Allow managing token lifecycle, but deny generating arbitrary elevated tokens
path "auth/token/create" {
  capabilities = ["create", "update"]
  denied_parameters = {
    "policies" = ["root", "pcy-sec-admins"]
  }
}
