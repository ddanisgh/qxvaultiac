variable "db_password" {
    description = "Database password"
    type = string	
}

variable "api_key" {
    description = "API key"
    type = string
}

variable "syslog_host_ip" {
    description = "IP address of the host running syslog container"
    type        = string
}

variable "keycloak_client_id" {
    description = "Client identifier for Keycloak OIDC connection."
    type	= string
    sensitive   = true
}

variable "keycloak_secret" {
    description = "Client secret for Keycloak OIDC connection."
    type	= string
    sensitive 	= true
}

