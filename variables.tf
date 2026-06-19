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
