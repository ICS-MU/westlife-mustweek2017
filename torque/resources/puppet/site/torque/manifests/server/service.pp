class torque::server::service {
  service { $::torque::server::service:
    ensure  => running,
    enable  => true,
  }
}
