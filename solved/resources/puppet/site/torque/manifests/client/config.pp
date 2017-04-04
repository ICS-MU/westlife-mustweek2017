class torque::client::config {
  file { $::torque::client::server_name_file:
    ensure  => file,
    content => $::torque::client::server_name,
  }
}
