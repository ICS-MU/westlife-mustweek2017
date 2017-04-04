include ::torque::scheduler
include ::torque::mom

class { '::torque::server':
  nodes => {
    $::fqdn    => { 'properties' => 'num_node_boards=1', },
    'localhost'=> { },
  }
}

# server
#::torque::qmgr::attribute { 'server operators':
#  object => 'server',
#  key    => 'operators',
#  #value  => "root@${::fqdn}",
#  value  => "root@localhost",
#}
#
#::torque::qmgr::attribute { 'server managers':
#  object => 'server',
#  key    => 'managers',
#  #value  => "root@${::fqdn}",
#  value  => "root@localhost",
#}

::torque::qmgr::attribute { 'server scheduling':
  object => 'server',
  key    => 'scheduling',
  value  => 'true',
}

::torque::qmgr::attribute { 'server keep_completed':
  object => 'server',
  key    => 'keep_completed',
  value  => '300',
}

::torque::qmgr::attribute { 'server mom_job_sync':
  object => 'server',
  key    => 'mom_job_sync',
  value  => 'true',
}

# queue batch
::torque::qmgr::object { 'queue batch':
  ensure      => 'present',
  object      => 'queue',
  object_name => 'batch',
}

::torque::qmgr::attribute { 'queue batch queue_type':
  object      => 'queue',
  object_name => 'batch',
  key         => 'queue_type',
  value       => 'execution',
  require     => ::Torque::Qmgr::Object['queue batch'],
}

::torque::qmgr::attribute { 'queue batch started':
  object      => 'queue',
  object_name => 'batch',
  key         => 'started',
  value       => 'true',
  require     => ::Torque::Qmgr::Object['queue batch'],
}

::torque::qmgr::attribute { 'queue batch enabled':
  object      => 'queue',
  object_name => 'batch',
  key         => 'enabled',
  value       => 'true',
  require     => ::Torque::Qmgr::Object['queue batch'],
}

::torque::qmgr::attribute { 'queue batch resources_default.walltime':
  object      => 'queue',
  object_name => 'batch',
  key         => 'resources_default.walltime',
  value       => '01:00:00',
  require     => ::Torque::Qmgr::Object['queue batch'],
}

::torque::qmgr::attribute { 'queue batch resources_default.nodes':
  object      => 'queue',
  object_name => 'batch',
  key         => 'resources_default.nodes',
  value       => '1',
  require     => ::Torque::Qmgr::Object['queue batch'],
}

::torque::qmgr::attribute { 'server default_queue':
  object   => 'server',
  key      => 'default_queue',
  value    => 'batch',
  require  => ::Torque::Qmgr::Object['queue batch'],
}
