# init.pp
# Main class of cse480 openstack server
# Declare main config here
#

class cse480 (
  $all              = $cse480::params::all,
  $controller       = $cse480::params::controller,
  $compute          = $cse480::params::compute,
  $openstack        = $cse480::params::openstack,
  $repo             = $cse480::params::repo,
  $network          = $cse480::params::network,
  $volumes          = $cse480::params::volumes,
  $users            = $cse480::params::users,
  $ssl              = $cse480::params::ssl,

  $compute_hosts    = $cse480::params::compute_hosts,
  $controller_host  = $cse480::params::controller_host,
  $data_vlan_ranges = $cse480::params::data_vlan_ranges,

  $cert_path        = $cse480::params::cert_path,
  $cert_file        = $cse480::params::cert_file,
  $key_file         = $cse480::params::key_file,
  $ca_file          = $cse480::params::ca_file,
) inherits cse480::params {

  validate_bool($all)
  validate_bool($controller)
  validate_bool($compute)
  validate_bool($openstack)
  validate_bool($repo)
  validate_bool($network)
  validate_bool($volumes)
  validate_bool($users)
  validate_bool($ssl)

  $any      = ($openstack and ($all or $controller or $compute))
  $sclasses = []

  if $openstack {
    if $all and ($controller or $compute) {
      fail("${module_name}: all should not be used with (controller or compute)")
    }

    if $all {
      class { 'cse480::openstack::all':
        compute_hosts    => $compute_hosts,
        data_vlan_ranges => $data_vlan_ranges,
      }
      $tal = concat($sclasses, ['cse480::openstack::all'])
    }
    if $controller {
      class { 'cse480::openstack::controller':
        compute_hosts    => $compute_hosts,
        data_vlan_ranges => $data_vlan_ranges,
      }
      $tct = concat($sclasses, ['cse480::openstack::controller'])
    }
    if $compute {
      class { 'cse480::openstack::compute':
        controller_host => $controller_host,
      }
      $tcp = concat($sclasses, ['cse480::openstack::compute'])
    }
  }

  if $repo {
    class { 'openstack::repo':
      release => 'havana',
      before  => $any ? {
        true  => Class[$sclasses],
        false => undef,
      },
    }
  }

  if $network {
    class { 'cse480::network':
      all        => $all,
      controller => $controller,
      compute    => $compute,
      before => $any ? {
        true  => Class[$sclasses],
        false => undef,
      },
    }
  }

  if $volumes {
    class { 'cse480::volumes':
      before => $any ? {
        true  => Class[$sclasses],
        false => undef,
      },
    }
  }

  if $users {
    #class { 'cse480::users':
    #  before => $any ? {
    #    true  => Class[$sclasses],
    #    false => undef,
    #  },
    #}
  }

  if $ssl and $openstack and ($all or $controller) {
    class { 'cse480::ssl':
      cert_path => $cert_path,
      cert_file => $cert_file,
      key_file  => $key_file,
      ca_file   => $ca_file,
      require   => $any ? {
        true  => Class[$sclasses],
        false => undef,
      },
    }
  }

  if $ssl and $openstack and ($all or $controller) {
    class { 'cse480::neutron_dhcp':
      require   => $any ? {
        true  => Class[$sclasses],
        false => undef,
      },
    }
  }

}
