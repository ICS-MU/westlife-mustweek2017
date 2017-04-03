define torque::mom::node (
  $ensure,
  $server_name,
  $np,
  $ntype,
  $properties,
  $membership,
  $provider
) {
  torque_node { $name:
    ensure       => $ensure,
    server_name  => $server_name,
    np           => $np,
    ntype        => $ntype,
    properties   => $properties,
    membership   => $membership,
    provider     => $provider,
    notify       => Class['::torque::server::service'],
  }
}
