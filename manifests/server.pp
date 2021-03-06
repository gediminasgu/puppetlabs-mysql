# Class: mysql::server
#
# manages the installation of the mysql server.  manages the package, service,
# my.cnf
#
# Parameters:
#   [*package_name*] - name of package
#   [*service_name*] - name of service
#   [*config_hash*]  - hash of config parameters that need to be set.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mysql::server (
  $package_name     = $mysql::params::server_package_name,
  $package_ensure   = 'present',
  $service_name     = $mysql::params::service_name,
  $service_provider = $mysql::params::service_provider,
  $config_hash      = {}
) inherits mysql::params {

  Class['mysql::server'] -> Class['mysql::config']

  $config_class = {}
  $config_class['mysql::config'] = $config_hash

  create_resources( 'class', $config_class )

  package { 'mysql-server':
    name   => $package_name,
    ensure => $package_ensure,
  }

  service { 'mysqld':
    name     => $service_name,
    ensure   => running,
    enable   => true,
    require  => Package['mysql-server'],
    provider => $service_provider,
  }

  puppi::check { 'MYSQL-Proc-Check':
    command => "check_procs -c 1:1 -C mysqld",
    hostwide => 'yes',
  }

}
