class torque::server::config {
  exec { 'timeout --preserve-status 5 pbs_server -f -t create -D':
    path    => '/bin:/usr/bin:/sbin/:/usr/sbin',
    creates => $::torque::server::serverdb_file,
  }

  # collect exported/virtual resources
  Torque_node       <<| server_name == $::torque::server::server_name |>>
  Torque_node        <| server_name == $::torque::server::server_name |>
  Torque::Mom::Node <<| server_name == $::torque::server::server_name |>>
  Torque::Mom::Node  <| server_name == $::torque::server::server_name |>

  # create node resources from provided hash
  if size($::torque::server::nodes) > 0 { #TODO: length()
    ensure_resource(
      'torque_node',
      $::torque::server::nodes,
      { 'ensure' => 'present', })
  }
}
