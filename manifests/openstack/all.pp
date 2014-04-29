# all.pp
# Install and set up core openstack components with neutron networking
# Havana release - current at the time
#
# requires: 'puppetlabs/openstack' module
# Our special brew with fixes: https://github.com/edestecd/puppet-openstack.git
# :ref => 'stable/havana'
#
#
# https://forge.puppetlabs.com/puppetlabs/openstack
# Manual stuff I did prior to using the puppetlabs/openstack module (The doc above calls for these)
# PuppetDB on puppet master (see modules/local/puppet/manifests/master)
# http://docs.openstack.org/havana/install-guide/install/apt/content/basics-packages.html
# Passwords/Tokens generated with:
# openssl rand -base64 11
# openssl rand -hex 10
#
#
# Neutron
# http://developer.rackspace.com/blog/neutron-networking-the-building-blocks-of-an-openstack-cloud.html
# http://developer.rackspace.com/blog/neutron-networking-simple-flat-network.html
# http://developer.rackspace.com/blog/neutron-networking-vlan-provider-networks.html
# http://developer.rackspace.com/blog/neutron-networking-l3-agent.html
#
# Get Images
# http://docs.openstack.org/image-guide/content/ch_obtaining_images.html
#

class cse480::openstack::all (
  # required passwords
  $admin_password,
  $cinder_db_password,
  $cinder_user_password,
  $keystone_db_password,
  $keystone_admin_token,
  $nova_db_password,
  $nova_user_password,
  $glance_db_password,
  $glance_user_password,
  $rabbit_password,
  $horizon_secret_key,
  $neutron_db_password,
  $neutron_user_password,
  $metadata_shared_secret,
  $mysql_root_password,

  $compute_hosts    = $cse480::params::compute_hosts,
  $data_vlan_ranges = $cse480::params::data_vlan_ranges,
  $admin_email      = $cse480::params::admin_email,
) inherits cse480::params {

  validate_array($compute_hosts)

  class { '::openstack::all':
    public_address          => $::ipaddress_eth0,
    public_interface        => 'eth0',
    private_interface       => 'eth1',
    admin_email             => $admin_email,
    admin_password          => $admin_password,
    cinder_db_password      => $cinder_db_password,
    cinder_user_password    => $cinder_user_password,
    volume_group            => 'cinder-volumes',
    keystone_db_password    => $keystone_db_password,
    keystone_admin_token    => $keystone_admin_token,
    keystone_admin_tenant   => 'admin',
    region                  => 'RegionOne',
    nova_db_password        => $nova_db_password,
    nova_user_password      => $nova_user_password,
    glance_db_password      => $glance_db_password,
    glance_user_password    => $glance_user_password,
    glance_backend          => 'file',
    rabbit_password         => $rabbit_password,
    rabbit_user             => 'openstack_rabbit',
    libvirt_type            => 'kvm',
    migration_support       => false,
    #floating_range          => '192.168.101.64/28',
    #fixed_range             => '10.0.0.0/24',
    auto_assign_floating_ip => false,
    secret_key              => $horizon_secret_key,
    horizon_app_links       => undef,
    vnc_enabled             => true,
    vncproxy_host           => $::fqdn,
    vncserver_listen        => '0.0.0.0',
    verbose                 => false,
    neutron                 => true,
    neutron_db_password     => $neutron_db_password,
    neutron_user_password   => $neutron_user_password,
    bridge_interface        => 'eth1.4011', # <- not used if bridge_mappings and bridge_uplinks defined
    external_bridge_name    => 'br-ex',     # <- not used if bridge_mappings and bridge_uplinks defined
    enable_metadata_agent   => true,
    metadata_shared_secret  => $metadata_shared_secret,
    firewall_driver         => 'neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver',
    ovs_enable_tunneling    => false,
    #ovs_local_ip            => $::ipaddress_eth0,
    network_vlan_ranges     => "physnet1,physnet2:${data_vlan_ranges}",
    bridge_mappings         => ['physnet1:br-ex', 'physnet2:br-eth1'],
    bridge_uplinks          => ['br-ex:eth1.4011', 'br-eth1:eth1'],
    tenant_network_type     => 'vlan',
    mysql_root_password     => $mysql_root_password,
    allowed_hosts           => $compute_hosts,
  }

  class { '::openstack::auth_file':
    admin_password       => $admin_password,
    controller_node      => '127.0.0.1',
    keystone_admin_token => $keystone_admin_token,
    admin_user           => 'admin',
    admin_tenant         => 'admin',
    region_name          => 'RegionOne',
  }

}
