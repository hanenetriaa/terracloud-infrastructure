variable "vm_name" {
  description = "Nom de la VM"
  type        = string
  default     = "terracloud-vm"
}

variable "admin_user" {
  description = "Utilisateur admin Linux"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "Clé publique SSH (ssh-ed25519 ... ou ssh-rsa ...)"
  type        = string
}

variable "tags" {
  description = "Tags communs"
  type        = map(string)
  default = {
    managedBy = "terraform"
    workload  = "terracloud"
  }
}
