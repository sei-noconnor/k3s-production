vsphere_server = "$VSPHERE_SERVER"
vsphere_user   = "$VSPHERE_USER"
vsphere_pass   = "$VSPHERE_PASSWORD"
datacenter     = "$VSPHERE_DATACENTER"
# Cluster needs to match VSPHERE_CLUSTER Environment variable
cluster           = "$VSPHERE_CLUSTER"
dvswitch          = "$VSPHERE_DV_SWITCH"
vsphere_datastore = "$VSPHERE_DATASTORE"
iso_datastore     = "$VSPHERE_ISO_DATASTORE"
# Must have a snapshot
template        = "$UBUNTU_TEMPLATE"
folder          = "$VSPHERE_DATACENTER/vm"
domain          = "$DOMAIN"
default_portgroup = "$VSHERE_DEFAULT_PORTGROUP"
default_netmask = "$DEFAULT_NETMASK"
default_gateway = "$DEFUALT_GATEWAY"
dns_servers     = ["$DNS_01", "$DNS_02"]
vms = {
  rancher = {
    ip     = "192.168.1.100"
    cpus   = 4
    memory = 4096
    extra_config = {

    }
  },
  k3-01 = {
    ip     = "192.168.1.101"
    cpus   = 4
    memory = 4096
    extra_config = {

    }
  },
  k3-02 = {
    ip     = "192.168.1.102"
    cpus   = 4
    memory = 4096
    extra_config = {

    }
  },
  k3-03 = {
    ip     = "192.168.1.103"
    cpus   = 4
    memory = 4096
    extra_config = {

    }
  },
  worker-01 = {
    ip     = "192.168.1.104"
    cpus   = 4
    memory = 8192
    extra_config = {

    }
  },
  worker-02 = {
    ip     = "192.168.1.105"
    cpus   = 4
    memory = 8192
    extra_config = {

    }
  },
  worker-03 = {
    ip     = "192.168.1.106"
    cpus   = 4
    memory = 8192
    extra_config = {

    }
  },
}
