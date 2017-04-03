class torque::mom (
  $packages    = $torque::params::mom_packages,
  $export_node = $torque::params::mom_export_node, #TODO
  $service     = $torque::params::mom_service,
  $server_name = $torque::params::server_name
) inherits torque::params {

  validate_array($packages)
  validate_string($service)
  validate_string($server_name)

  contain ::torque::mom::install
  contain ::torque::mom::config
  contain ::torque::mom::service

  Class['::torque::mom::install']
    -> Class['::torque::mom::config']
    ~> Class['::torque::mom::service']
}
