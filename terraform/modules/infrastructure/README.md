# Terraform vSphere Infrasturcture Module

Infrastructure module for vsphere, this module aims to set up the vsphere infrastructure for an exercise. 

The following list of variables are required for this module.  
## Inputs
|Name|Description|Type|Default|
|---|:---|:---:|:---:|
| vsphere_datacenter | Name of the the vsphere datacenter | `string` | "A200" |
| vsphere_cluster | Name of the vsphere cluster | `string` | "MDT-Crucible" |
| vsphere_dvswitch | Name of the vsphere distributed virtual switch | `string` | "mdt-crucible-dvswitch" |
| vsphere_folder | Name of the vsphere vm folder | `string` | "/A200/vm/MDT" |


## Outputs
|Name|Description|Type|Default|
|---|:---|:---:|:---:|
|dc_id| vsphere object id of the datacenter | `string<guid>` | none |
|cluster_id| vsphere object id of the cluster | `string<guid>` | none |
|dvswitch_id| vsphere object id of the dv switch | `string<guid>` | none |
|datastore_id| vsphere object id of the datastore | `string<guid>` | none |
|folder_id| vsphere object id of the vm folder | `string<guid>` | none |

## Usage
*With defaults*

```hcl
module "infrastructure" {
    source = "git::https://gitlab.cyberforce.site/terraform-modules/infrastructure?ref=v0.0.1"
}
```

*With override*
```hcl
module "infrastructure" {
    source = "git::https://gitlab.cyberforce.site/terraform-modules/infrastructure?ref=v0.0.1"
    vsphere_datacenter = "A200"
    vsphere_cluster = "MDT-Crucible"
    vsphere_dvswitch = "mdt-crucible-dvswitch"
    vsphere_folder = "/A200/vm/MDT"
}
```
*Accessing outputs*
```
resource "vshpere_folder" {
  datacenter_id = module.infrastructure.dc_id
}
```
## License

[MIT](LICENSE)