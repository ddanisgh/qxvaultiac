variable "uc1_postgres_admin_password" {
    sensitive = true
}

locals {
    uc1_vault_namespace 	= "diamonds"
    uc1_postgres_host 		= "192.168.2.128"
    uc1_postgres_port		= "30432"
    uc1_postgres_database_name	= "pagila"
    uc1_postgres_admin_user	= "postgres"
}


resource "vault_mount" "database" {
    namespace		= local.uc1_vault_namespace
    type		= "database"
    path		= "database"
    description		= "Use case 1 dynamic database credential secrets validation."

    depends_on = [
        vault_namespace.diamonds
    ]
}


resource "vault_database_secret_backend_connection" "pagila" {
    namespace = local.uc1_vault_namespace

    backend = vault_mount.database.path
    name    = local.uc1_postgres_database_name

    allowed_roles = [
        "readonly"
    ]

    postgresql {
        connection_url = "postgresql://${local.uc1_postgres_admin_user}:${var.uc1_postgres_admin_password}@${local.uc1_postgres_host}:${local.uc1_postgres_port}/${local.uc1_postgres_database_name}?sslmode=disable"
    }

    depends_on = [
        vault_mount.database
    ]
}


resource "vault_database_secret_backend_role" "readonly" {
    
    namespace = local.uc1_vault_namespace

    backend = vault_mount.database.path
    name    = "readonly"
    db_name = vault_database_secret_backend_connection.pagila.name

    creation_statements = [
        <<-SQL
        CREATE ROLE "{{name}}"
            WITH LOGIN
            PASSWORD '{{password}}'
            VALID UNTIL '{{expiration}}';

        GRANT CONNECT ON DATABASE pagila TO "{{name}}";
        GRANT USAGE ON SCHEMA public TO "{{name}}";
        GRANT SELECT ON ALL TABLES IN SCHEMA public TO "{{name}}";
        SQL
    ]

    revocation_statements = [
        <<-SQL
		

	REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public
	FROM "{{name}}";

  	REVOKE USAGE ON SCHEMA public
    	FROM "{{name}}";

  	REVOKE CONNECT ON DATABASE pagila
    	FROM "{{name}}";

        DROP ROLE IF EXISTS "{{name}}";
        SQL
    ]

    default_ttl = 3600
    max_ttl     = 86400

}
