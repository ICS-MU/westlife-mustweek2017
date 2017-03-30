define torque::qmgr::attribute (
  $object,
  $key,
  $value,
  $object_name = '',
  $server_name = $::torque::client::server_name
) {
  if ($object_name != '') {
    $_object_cpd = "${object} ${object_name}"
  } else {
    $_object_cpd = "${object}"
  }

  $_cmd = "set ${_object_cpd} ${key} = ${value}"

  exec { "qmgr -a -c '${_cmd}' ${server_name}":
    unless      => "qmgr -a -c 'print ${_object_cpd}' | grep -iq '${_cmd}'",
    path        => '/bin:/usr/bin',
    environment => 'KRB5CCNAME=/dev/null',
    require     => Class['::torque::client'],
  }
}
