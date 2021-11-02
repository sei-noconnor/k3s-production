output "dc" {
  description = "vcenter datacenter"
  value = data.vsphere_datacenter.dc
}

output "cluster" {
  description = "vcenter cluster"
  value = data.vsphere_compute_cluster.cluster
}

output "dvswitch" {
  description = "vcenter dv switch where portgroups will be deployed"
  value = data.vsphere_distributed_virtual_switch.dvs
}

output "datastore" {
  description = "vcenter datastore"
  value = data.vsphere_datastore.ds
}

output "folder" {
  description = "vcenter folder"
  value = data.vsphere_folder.folder
}