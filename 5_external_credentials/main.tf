terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "2.19.0"
    }
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "1.24.3"
    }
  }
}

provider "vault" {
  address = var.vault_address
  token   = var.vault_token
}

provider "vsphere" {
  user                 = data.vault_generic_secret.vsphere.data.username
  password             = data.vault_generic_secret.vsphere.data.password
  vsphere_server       = data.vault_generic_secret.vsphere.data.hostname
  allow_unverified_ssl = true
}


# Read vSphere credentials from Vault
data "vault_generic_secret" "vsphere" {
  path = "pvt21/vsphere_credentials"
}

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.vsphere_resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_vm_portgroup
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vsphere_vm_template
  datacenter_id = data.vsphere_datacenter.dc.id
}


resource "vsphere_virtual_machine" "vm" {
  name             = var.vsphere_vm_name
  #  name             = "${var.vsphere_vm_name}-${terraform.workspace}"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.vsphere_folder

  num_cpus = 2
  memory   = var.vsphere_vm_memory 
  guest_id = var.vsphere_vm_guest 
  cpu_hot_add_enabled = true
  memory_hot_add_enabled = true

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label = "disk0"
    size  = var.vsphere_vm_disksize
  }

  # disk {
  #   label = "disk1"
  #   size  = 5
  #   unit_number = 1
  # }
 
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    linked_clone  = var.linked_clone
    timeout       = var.timeout
  }
}