data "vsphere_network" "default" {
  name          = var.default_network
  datacenter_id = module.infrastructure.dc.id
}
