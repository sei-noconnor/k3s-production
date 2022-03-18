vsphere_server = "$VSPHERE_SERVER"
vsphere_user   = "$VSPHERE_USER"
vsphere_pass   = "$VSPHERE_PASS"
datacenter     = "$VSPHERE_DATACENTER"
# Cluster needs to match VSPHERE_CLUSTER Environment variable
cluster           = "$VSPHERE_CLUSTER"
dvswitch          = "$VSPHERE_DV_SWITCH"
vsphere_datastore = "$VSPHERE_DATASTORE"
iso_datastore     = "$VSPHERE_ISO_DATASTORE"
# Must have a snapshot
template          = "$UBUNTU_TEMPLATE"
folder            = "$VSPHERE_DATACENTER/vm"
domain            = "$DOMAIN"
default_portgroup = "$VSPHERE_DEFAULT_PORTGROUP"
default_netmask   = "$DEFAULT_NETMASK"
default_gateway   = "$DEFUALT_GATEWAY"
dns_servers       = ["$DNS_01", "$DNS_02"]
vms = {
  rancher = {
    ip     = "$BASE_IP.100"
    cpus   = 4
    memory = 4096
    extra_config = {

    }
  },
  k3-01 = {
    ip     = "$BASE_IP.101"
    cpus   = 4
    memory = 4096
    extra_config = {

    }
  },
  worker-01 = {
    ip     = "$BASE_IP.102"
    cpus   = 4
    memory = 8192
    extra_config = {

    }
  },
  worker-02 = {
    ip     = "$BASE_IP.103"
    cpus   = 4
    memory = 8192
    extra_config = {

    }
  },
}
