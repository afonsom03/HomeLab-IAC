variable "vm_password" {
  description = "Password do utilizador sysadmin"
  type        = string
  sensitive   = true  # Isto esconde a password no terminal quando correres o terraform plan!
}

variable "proxmox_api_token" {
  description = "Token de acesso à API do Proxmox"
  type        = string
  sensitive   = true
}