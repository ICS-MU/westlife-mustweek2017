class torque::scheduler (
  $packages = $torque::params::scheduler_packages,
  $service  = $torque::params::scheduler_service
) inherits torque::params {

  validate_array($packages)
  validate_string($service)

  contain ::torque::scheduler::install
  contain ::torque::scheduler::config
  contain ::torque::scheduler::service

  Class['::torque::scheduler::install']
    -> Class['::torque::scheduler::config']
    ~> Class['::torque::scheduler::service']
}
