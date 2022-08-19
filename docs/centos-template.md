## CentOS 7 Prereqs

- Cannot use centos base and must use centos minimum, terraform needs perl in order to do vm customization
- install epel-release `yum instal epel-release`
- longhorn needs open-iscsi and the iscsid deamon `yum install iscsi-initiator-utils`
- longhorn needs nfsv4 client `yum install nfs-utils`
- mount propagation must be enabled run this script after ansible cluster init
  `curl -sSfL https://raw.githubusercontent.com/longhorn/longhorn/v1.2.1/scripts/environment_check.sh | bash`
