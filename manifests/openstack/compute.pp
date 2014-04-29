# compute.pp
# Install and set up just compute openstack components with neutron networking
# Havana release - current at the time
#

class cse480::openstack::compute (
  # required passwords
  $rabbit_password,
  $cinder_db_password,
  $nova_db_password,
  $nova_user_password,
  $neutron_user_password,

  $controller_host = $cse480::params::controller_host,
) inherits cse480::params {

  validate_string($controller_host)

  class { '::openstack::compute':
    public_interface        => 'eth0',
    private_interface       => 'eth1',
    internal_address        => $::ipaddress_eth0,
    libvirt_type            => 'kvm',
    migration_support       => false,
    #fixed_range             => '10.0.0.0/24',
    multi_host              => false,
    db_host                 => $controller_host,
    rabbit_host             => $controller_host,
    rabbit_password         => $rabbit_password,
    rabbit_user             => 'openstack_rabbit',
    cinder_db_password      => $cinder_db_password,
    volume_group            => 'cinder-volumes',
    glance_api_servers      => "${controller_host}:9292",
    nova_db_password        => $nova_db_password,
    nova_user_password      => $nova_user_password,
    vnc_enabled             => true,
    vncproxy_host           => $controller_host,
    vncserver_listen        => '0.0.0.0',
    manage_volumes          => true,
    neutron                 => true,
    neutron_user_password   => $neutron_user_password,
    neutron_auth_url        => "http://${controller_host}:35357/v2.0",
    keystone_host           => $controller_host,
    neutron_host            => $controller_host,
    ovs_enable_tunneling    => false,
    neutron_firewall_driver => 'neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver',
    bridge_mappings         => ['physnet2:br-eth1'],
    bridge_uplinks          => ['br-eth1:eth1'],
    verbose                 => false,
  }

}
