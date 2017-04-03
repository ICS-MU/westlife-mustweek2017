class torque::mom::config {
  #TODO
  file { '/etc/torque/mom/config':
    ensure  => file,
    content => "
# Configuration for pbs_mom is managed by Puppet
\$pbsserver ${::torque::mom::server_name}
\$mom_host ${::fqdn}
"
  }

  #TODO
  file { '/etc/torque/mom/mom.layout':
    ensure  => file,
    content => 'nodes=1',
  }
}
