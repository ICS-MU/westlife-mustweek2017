class torque::munge::service {
  service { $::torque::munge::service:
    ensure  => running,
    enable  => true,
  }
}
