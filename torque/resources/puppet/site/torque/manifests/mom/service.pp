class torque::mom::service {
  service { $::torque::mom::service:
    ensure  => running,
    enable  => true,
  }
}
