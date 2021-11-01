module "infrastructure" {
  source             = "./modules/infrastructure"
  vsphere_datacenter = var.datacenter
  vsphere_cluster    = var.cluster
  vsphere_dvswitch   = var.dvswitch
  vsphere_datastore  = var.vsphere_datastore
  vsphere_folder     = var.folder
}
