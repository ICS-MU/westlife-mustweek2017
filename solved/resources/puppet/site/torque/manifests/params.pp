class torque::params {
  $server_name = 'localhost'
  $nodes = {}
  $mom_export_node = true

  case $::operatingsystem {
    'redhat','centos','scientific','oraclelinux': {
      $mom_packages = ['torque-mom']
      $mom_service = 'pbs_mom'
      $munge_packages = ['munge']
      $munge_key_file = '/etc/munge/munge.key'
      $munge_key = 'kokotKOKOTkokotKOKOTkokotKOKOTkokotKOKOT' #TODO
      $munge_service = 'munge'
      $client_packages = ['torque-client']
      $client_service = 'trqauthd'
      $server_packages = ['torque-server']
      $server_name_file = '/etc/torque/server_name'
      $serverdb_file = '/var/lib/torque/server_priv/serverdb'
      $server_service  = 'pbs_server'
      $scheduler_packages = ['torque-scheduler']
      $scheduler_service = 'pbs_sched'
    }

    default: {
      fail("Unsupported OS: ${::operatingsystem}")
    }
  }
}
