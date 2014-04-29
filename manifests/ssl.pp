# ssl.pp
#
# https://ask.openstack.org/en/question/6192/horizon-unable-to-view-vnc-console-in-iframe-with-ssl/
#

class cse480::ssl (
  $cert_path = $cse480::params::cert_path,
  $cert_file = $cse480::params::cert_file,
  $key_file  = $cse480::params::key_file,
  $ca_file   = $cse480::params::ca_file,
) inherits cse480::params {

  validate_absolute_path($cert_path)
  validate_absolute_path($cert_file)
  validate_absolute_path($key_file)
  validate_absolute_path($ca_file)

  # Apache ssl
  file { '/etc/apache2/conf-available/openstack-dashboard.conf':
    ensure  => file,
    mode    => 0644,
    owner   => $::root_user,
    group   => $::root_group,
    content => template("${module_name}/ssl/openstack-dashboard.conf.erb"),
    notify  => Service['httpd'],
  }

  # noVNC proxy ssl
  nova_config {
    'DEFAULT/ssl_only': value => true;
    'DEFAULT/cert': value => $cert_file;
    'DEFAULT/key': value => $key_file;
    'DEFAULT/ca': value => $ca_file;
  }

}
