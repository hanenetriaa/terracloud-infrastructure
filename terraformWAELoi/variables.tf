variable "app_service_sku" {
  type    = string
  default = "B1"
}

# (vérifie aussi que tu as bien)
variable "app_name" {
  type = string
}

variable "container_image_repository" {
  description = "Docker image repository (e.g. myorg/app)"
  type        = string
  default     = "stricken008/terracloud-app"
}

variable "container_image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 80
}
