class torque::munge::config {
  file { $::torque::munge::munge_key_file:
    ensure  => file,
    content => $::torque::munge::munge_key,
    owner   => 'munge',
    group   => 'munge',
    mode    => '0400',
  }
}
