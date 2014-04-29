# neutron_dhcp.pp
#
# Turn on some neutron dhcp agent options in:
# /etc/neutron/dhcp_agent.ini
#
# These options allow the metadata to work on isolated nets.
# Or rather external public nets that are not natted through neutron routers.
#
# http://developer.rackspace.com/blog/neutron-networking-vlan-provider-networks.html
# http://openstack.redhat.com/forum/discussion/607/havana-mutlinode-with-neutron/p1
#

class cse480::neutron_dhcp inherits cse480::params {

  neutron_dhcp_agent_config {
    'DEFAULT/enable_isolated_metadata': value => true;
    #'DEFAULT/enable_metadata_network':  value => true;
  }

}
