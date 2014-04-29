# controller.pp
# Install and set up just controller openstack components with neutron networking
# Havana release - current at the time
#

class cse480::openstack::controller (
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

  class { '::openstack::controller':
    public_address          => $::ipaddress_eth0,
    public_interface        => 'eth0',
    private_interface       => 'eth1',
    admin_email             => $admin_email,
    admin_password          => $admin_password,
    multi_host              => false,
    network_manager         => 'nova.network.manager.FlatDHCPManager',
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
    #floating_range          => '192.168.101.64/28',
    #fixed_range             => '10.0.0.0/24',
    auto_assign_floating_ip => false,
    secret_key              => $horizon_secret_key,
    horizon_app_links       => undef,
    vnc_enabled             => true,
    vncproxy_host           => $::fqdn,
    verbose                 => false,
    neutron                 => true,
    neutron_db_password     => $neutron_db_password,
    neutron_user_password   => $neutron_user_password,
    bridge_interface        => 'eth1.4011',
    external_bridge_name    => 'br-ex',
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
    mysql_ssl               => false,
    mysql_ca                => undef,
    mysql_cert              => undef,
    mysql_key               => undef,
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
