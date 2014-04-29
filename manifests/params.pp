# params.pp
# Set up cse480 parameters defaults etc.
# For openstack et all
#

class cse480::params {

  #### class vars ####
  $all        = false
  $controller = false
  $compute    = false
  $openstack  = false
  $repo       = false
  $network    = false
  $volumes    = false
  $users      = false
  $ssl        = false

  # openstack
  # all.pp/controller.pp
  #$compute_hosts    = ['localhost', '172.17.29.16']
  #$data_vlan_ranges = '1000:1099'

  # compute.pp
  #$controller_host = 'osd.cec.miamioh.edu'

  # openstack/*
  $admin_email = 'root@localhost'

  # ssl.pp
  $cert_path = file_join('', 'etc', 'nova', 'ssl')
  $cert_file = file_join($cert_path, 'certs', "${fqdn}.pem")
  $key_file  = file_join($cert_path, 'private_keys', "${fqdn}.pem")
  $ca_file   = file_join($cert_path, 'certs', 'ca.pem')

  if ($::osfamily == 'Debian') and ($::operatingsystemrelease >= 12.0) {
    # set some default params for Debian
  } else {
    fail("The ${module_name} module is not supported on a ${::osfamily} based system with version ${::operatingsystemrelease}.")
  }

}
