data "vsphere_datacenter" "dc" {
    name = var.vsphere_datacenter
}

data "vsphere_compute_cluster" "cluster" {
    name = var.vsphere_cluster
    datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "ds" {
    name = var.vsphere_datastore
    datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_distributed_virtual_switch" "dvs" {
    count = var.vsphere_dvswitch != "" ? 1 : 0
    name = var.vsphere_dvswitch
    datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_folder" "folder" {
    path = var.vsphere_folder
}
