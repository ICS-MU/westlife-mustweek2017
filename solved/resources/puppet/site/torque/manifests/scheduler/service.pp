class torque::scheduler::service {
  service { $::torque::scheduler::service:
    ensure  => running,
    enable  => true,
  }
}
