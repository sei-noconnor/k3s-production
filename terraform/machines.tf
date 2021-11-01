data "vsphere_virtual_machine" "template" {
  name          = var.template
  datacenter_id = module.infrastructure.dc.id
}

resource "vsphere_virtual_machine" "vms" {
  for_each         = var.vms
  resource_pool_id = module.infrastructure.cluster.resource_pool_id
  datastore_id     = module.infrastructure.datastore.id
  name             = each.key
  num_cpus         = each.value.cpus
  memory           = each.value.memory
  guest_id         = data.vsphere_virtual_machine.template.guest_id

  scsi_type = data.vsphere_virtual_machine.template.scsi_type
  network_interface {
    network_id   = data.vsphere_network.default.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    linked_clone  = true

    customize {
      linux_options {
        host_name = each.key
        domain    = var.domain
      }

      network_interface {
        ipv4_address = each.value.ip
        ipv4_netmask = var.default_netmask
      }

      ipv4_gateway    = var.default_gateway
      dns_server_list = var.dns_servers
      dns_suffix_list = tolist([var.domain])
    }
  }

  extra_config = try(each.value.extra_config,{})
}
output "vms" {
  value = var.vms
}