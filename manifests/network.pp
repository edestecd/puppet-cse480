# network.pp
#
# https://github.com/stackforge/puppet-openstack/tree/stable/havana#networking
# https://help.ubuntu.com/community/KVM/Networking
# https://wiki.ubuntu.com/vlan
# http://docs.openstack.org/havana/install-guide/install/apt/content/neutron-install-network-node.html
# http://docs.openstack.org/havana/install-guide/install/apt/content/install-neutron.install-plug-in.ovs.html
# http://docs.openstack.org/havana/install-guide/install/apt/content/install-neutron.configure-networks.html
#
# Neutron Troubleshooting
# http://docs.openstack.org/havana/config-reference/content/under_the_hood_openvswitch.html
# http://www.mirantis.com/blog/identifying-and-troubleshooting-neutron-namespaces/
#
# Dell PowerConnect Switch Help
# ftp://ftp.dell.com/Manuals/Common/powerconnect-6224_Reference%20Guide_en-us.pdf
# cdpr - Cisco Discovery Protocol Reporter
#
# show running-config
# show interface status
# configure interface ethernet <port>
#

class cse480::network (
  $all        = $cse480::params::all,
  $controller = $cse480::params::controller,
  $compute    = $cse480::params::compute,
) inherits cse480::params {

  package { ['ethtool', 'bridge-utils', 'vlan']:
    ensure => installed,
  }

  # Openstack module is probably doing these three already...
  # forward may not be needed on compute node
  file_line { 'net_ipv4_ip_forward':
    path    => '/etc/sysctl.conf',
    match   => '^[#\s]*net.ipv4.ip_forward=.*$',
    line    => "net.ipv4.ip_forward=1",
    require => Package['ethtool', 'bridge-utils', 'vlan'],
  }

  file_line { 'net_ipv4_conf_all_rp_filter':
    path    => '/etc/sysctl.conf',
    match   => '^[#\s]*net.ipv4.conf.all.rp_filter=.*$',
    line    => "net.ipv4.conf.all.rp_filter=0",
    require => File_line['net_ipv4_ip_forward'],
  }

  file_line { 'net_ipv4_conf_default_rp_filter':
    path    => '/etc/sysctl.conf',
    match   => '^[#\s]*net.ipv4.conf.default.rp_filter=.*$',
    line    => "net.ipv4.conf.default.rp_filter=0",
    require => File_line['net_ipv4_conf_all_rp_filter'],
  }

  # Ensure vlan tagging kernel module is loaded at boot
  file_line { '8021q_kernel_module':
    path    => '/etc/modules',
    line    => "8021q",
    require => File_line['net_ipv4_conf_default_rp_filter'],
  }

  if $all or $controller or $compute {
    # Internal interface for VM data vlans 1000-1099
    network_config { 'eth1':
      ensure      => present,
      family      => inet,
      method      => manual,
      onboot      => true,
      hotplug     => true,
      options     => {'up' => 'ifconfig $IFACE 0.0.0.0 up'},
      require     => File_line['8021q_kernel_module'],
      #reconfigure => true,
    }
  }

  if $all or $controller { # not on compute
    # External interface/bridge for Neutron in OpenStack
    # TIP: Do not set br-ex to auto. Because of the order that processes are started at boot, the interface must be brought up using rc.local
    network_config { 'eth1.4011':
      ensure      => present,
      family      => inet,
      method      => manual,
      onboot      => true,
      hotplug     => true,
      options     => {'up' => ['ifconfig $IFACE 0.0.0.0 up', 'ifconfig $IFACE promisc'], 'vlan-raw-device' => 'eth1'},
      require     => Network_config['eth1'],
      #reconfigure => true,
    }
  }

}
