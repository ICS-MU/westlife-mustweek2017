class torque::client (
  $packages         = $torque::params::client_packages,
  $server_name_file = $torque::params::server_name_file,
  $server_name      = $torque::params::server_name,
  $service          = $torque::params::client_service
) inherits torque::params {

  validate_array($packages)
  validate_absolute_path($server_name_file)
  validate_string($service)

  require ::torque::munge
  contain ::torque::client::install
  contain ::torque::client::config
  contain ::torque::client::service

  Class['::torque::client::install']
    -> Class['::torque::client::config']
    ~> Class['::torque::client::service']
}
