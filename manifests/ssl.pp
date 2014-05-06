# ssl.pp
#
# https://ask.openstack.org/en/question/6192/horizon-unable-to-view-vnc-console-in-iframe-with-ssl/
#
# Openstack horizon module has ssl options for horizon,
# but they crash apache on our setup and generally aren't good news.
# I choose to manage the apache ssl myself and actually use the apache module classes/types,
# rather than a bunch of nasty file_line which conflict with apache module and fight back and forth changing the file every run :( ) eww.
#
# Also the openstack module does not offer to set the noVNC ssl setting either,
# which are set in nova config and
# which I am also managing here.
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

  include apache::mod::ssl
  include apache::mod::rewrite
  apache::listen { "0.0.0.0:443": }

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
