class torque::client::service {
  service { $::torque::client::service:
    ensure  => running,
    enable  => true,
  }
}
