define torque::qmgr::object (
  $ensure,
  $object,
  $object_name,
  $server_name = $::torque::client::server_name
) {
  Exec {
    path        => '/bin:/usr/bin',
    environment => 'KRB5CCNAME=/dev/null',
    require     => Class['::torque::client']
  }

  $_object_cpd = "${object} ${object_name}"

  case $ensure {
    'present': {
      exec { "qmgr -a -c 'create ${_object_cpd}' ${server_name}":
        unless => "qmgr -a -c 'print ${_object_cpd}' ${server_name}",
      }
    }

    'absent': {
      exec { "qmgr -a -c 'delete ${_object_cpd}' ${server_name}":
        onlyif => "qmgr -a -c 'print ${_object_cpd}' ${server_name}",
      }
    }

    default: {
      fail("Invalid ensure state $ensure")
    }
  }

}
