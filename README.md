cse480
=============

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with cse480](#setup)
    * [What cse480 affects](#what-mobileconfig_profile-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with cse480](#beginning-with-mobileconfig_profile)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

##Overview

Puppet Module to set up Open Stack with Neutron on Ubuntu 12.04 LTS for my CSE 480 class

##Module Description

**Miami University**  
**CSE 480 Research Project**  
**Spring Semester 2013-2014**  
**Student: Chris Edester**  
**Instructor: Dr. Scott Campbell**  

1. Overview of Research
  * Investigate and set up various features for OpenStack cloud computing software (http://www.openstack.org).  OpenStack is used to manage Virtual Machines used by students taking classes at Miami.  Many of these features may aid in instructing students. CEC IT already has an existing openstack cloud infrastructure and this work will extend its capabilities.

  * Suggested Features:
    * Add multiple NIC support *****
    * Add multiple network support (private networks for individual vm’s)
    * Get neutron working
    * Setup test system
    * Get vnc working
    * Add vlan support
    * Add default openvpn support


2. Deliverables
  * Presentation delivered to CSE617-Spring 14
  * Working implementations
  * Research notes about feature: working or if not feasible why?
  * Scripts/Puppet manifests to deploy features

##Setup

###What cse480 affects

* OpenStack cloud repo added
* All of OpenStack
* Various network settings (/etc/sysctl.conf, load 8021q kernel module)
* Create network interfaces in /etc/network/interfaces for neutron nets
* Volume group(s) for cinder created
* Apache config and ssl

###Setup Requirements

pluginsync needs to be enabled on agents  
Others here: (https://github.com/stackforge/puppet-openstack/tree/3.0.0)

###Beginning with cse480

This module provides the `cse480` class for turning on different parts.  
Run everything with:

```puppet
class { 'cse480':
  all       => true,
  openstack => true,
  repo      => true,
  network   => true,
  ssl       => true,
}
```

##Usage

You will likely also want some hiera config files (yaml, json etc...) to specify some options and passwords.

###Example  hiera yaml (for all)

```yaml
---
# puppetlabs/horizon has a file_line that conflicts with the ip being blank and they go back and forth changing this line.
apache::ip: "0.0.0.0"
# By default RabbitMQ will bind to all interfaces, on IPv4 and IPv6 if available.
# Set this if you only want to bind to one network interface or address family.
rabbitmq::server::node_ip_address: "0.0.0.0"
# Move sql settings to neutron::server; They belong ther now
# Openstack module - neutron.pp is setting these in neutron::plugins::ovs which is dep resulting in sqlite db being used
neutron::server::sql_connection: false
neutron::server::connection: "mysql://neutron:pass@127.0.0.1/neutron?charset=utf8"
# keystone_default_role should be '_member_' now - whatever sets this up used '_member_' not 'Member'
openstack::horizon::keystone_default_role: "_member_"
# Specify the vncproxy_port for noVNC
nova::compute::vncproxy_protocol: "https"
nova::compute::vncproxy_port: "8080"
nova::vncproxy::port: "8080"


# Our settings
cse480::compute_hosts:
  - "localhost"
  - "192.168.1.1"
cse480::data_vlan_ranges: "100:200"


# Passwords
cse480::openstack::all::admin_password:         "password"
cse480::openstack::all::cinder_db_password:     "password"
cse480::openstack::all::cinder_user_password:   "password"
cse480::openstack::all::keystone_db_password:   "password"
cse480::openstack::all::keystone_admin_token:   "password"
cse480::openstack::all::nova_db_password:       "password"
cse480::openstack::all::nova_user_password:     "password"
cse480::openstack::all::glance_db_password:     "password"
cse480::openstack::all::glance_user_password:   "password"
cse480::openstack::all::rabbit_password:        "password"
cse480::openstack::all::horizon_secret_key:     "password"
cse480::openstack::all::neutron_db_password:    "password"
cse480::openstack::all::neutron_user_password:  "password"
cse480::openstack::all::metadata_shared_secret: "password"
cse480::openstack::all::mysql_root_password:    "password"
```

##Reference

### Usefull Classes

* `cse480`: Manages everything by just setting a few booleans
* `cse480::openstack::all`: Install and set up all openstack components with neutron networking
* `cse480::openstack::compute`: Install and set up just compute openstack components with neutron networking
* `cse480::openstack::controller`: Install and set up just controller openstack components with neutron networking

##Limitations

This module has been built on and tested against Puppet 3.2.4 and higher.  
While I am sure other versions work, I have not tested them.

This module has been tested on Ubuntu 12.04 LTS only.  
With little changes, it should work on RedHat as well (openstack modules and others used support RedHat)

No plans to support other versions at this time (unless you add it :)..

##Development

Pull Requests welcome

##Contributors

Chris Edester (edestecd)
