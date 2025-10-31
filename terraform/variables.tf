variable "app_service_sku" {
  type    = string
  default = "B1"
}

# (vérifie aussi que tu as bien)
variable "app_name" {
  type = string
}

variable "mysql_name"     { type = string, default = "terracloud-mysql" }
variable "mysql_admin"    { type = string, default = "dbadmin" }
variable "mysql_password" { type = string }           # passe-la via TF_VAR_mysql_password
variable "mysql_db_name"  { type = string, default = "appdb" }
