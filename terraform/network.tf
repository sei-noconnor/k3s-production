data "vsphere_network" "default" {
  name          = var.default_portgroup
  datacenter_id = module.infrastructure.dc.id
}
