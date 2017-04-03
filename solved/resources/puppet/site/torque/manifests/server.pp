class torque::server (
  $packages      = $torque::params::server_packages,
  $serverdb_file = $torque::params::serverdb_file,
  $nodes         = $torque::params::nodes,
  $service       = $torque::params::server_service
) inherits torque::params {

  validate_array($packages)
  validate_string($service)
  validate_absolute_path($serverdb_file)
  validate_hash($nodes)

  require ::torque::client
  contain ::torque::server::install
  contain ::torque::server::config
  contain ::torque::server::service
  contain ::torque::server::live_config

  Class['::torque::server::install']
    -> Class['::torque::server::config']
    ~> Class['::torque::server::service']
    -> Class['::torque::server::live_config']
}
