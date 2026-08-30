terraform {
  cloud {
    organization = "HomeLab_Afonso"
    workspaces {
      name = "HomeLab-IAC"
    }
  }
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.63.0"
    }
  }
}

provider "proxmox" {
  endpoint  = "https://100.104.241.31:8006/"

  api_token = var.proxmox_api_token 

  insecure  = true
}

# A TUA MÁQUINA VIRTUAL
resource "proxmox_virtual_environment_vm" "ubuntu_server" {
  count       = 3
  name        = "ubuntu-iac-0${count.index + 1}"
  description = "Clone automático do Template 9000"
  node_name   = "pve" 

  # A instrução para clonar o nosso molde
  clone {
    vm_id = 108
  }

  cpu {
    cores = 2
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 20
  }

  memory {
    dedicated = 2048
  }
  
  network_device {
    bridge = "vmbr1"
  }

  agent {
    enabled = true
  }

  # Configurações do Sistema Operativo (Cloud-Init)
  initialization {
    ip_config {
      ipv4 {
        address = "dhcp" # Vai pedir um IP automaticamente ao teu router
      }
    }
    user_account {
      username = "sysadmin"
      password = var.vm_password

      keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILYHZ2QV/o8NVmw0NonNNzLuo4zQ9dCvHqIjlQZ3BIQL afons@Martins_Desktop",
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICe2l2+7K0HxqrkYk5lQbhDlxawzyxck0OkD3r+Qj7Ug user@DESKTOP-DTC7V07",
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKgbmvIAvyHM4S1QEjaxZGyV924pG6Hwvp5ZP8T3YbED afonso.martins003@gmail.com"
      ]
    }
  }
}

# Gerar o Inventário diretamente na pasta do Ansible no Linux!
resource "local_file" "ansible_inventory" {
  filename = "hosts.ini"
  
  content  = <<-EOT
    [linux_servers]
    %{ for vm in proxmox_virtual_environment_vm.ubuntu_server ~}
    ${vm.ipv4_addresses[1][0]} ansible_user=sysadmin
    %{ endfor ~}
  EOT
}