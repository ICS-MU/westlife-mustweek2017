class torque::munge (
  $packages       = $torque::params::munge_packages,
  $munge_key_file = $torque::params::munge_key_file,
  $munge_key      = $torque::params::munge_key,
  $service        = $torque::params::munge_service
) inherits torque::params {

  validate_array($packages)
  validate_string($service)
  validate_absolute_path($munge_key_file)
  validate_string($munge_key)

  contain ::torque::munge::install
  contain ::torque::munge::config
  contain ::torque::munge::service

  Class['::torque::munge::install']
    -> Class['::torque::munge::config']
    ~> Class['::torque::munge::service']
}
