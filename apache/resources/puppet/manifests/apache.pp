# clean firewall rules
resources { 'firewall':
   purge => true,
}

include ::firewall

# setup Apache
include ::apache

file { '/var/www/cgi-bin/index.py':
  ensure  => file,
  mode   => '0755',
  source => "puppet:///modules/helloworld/index.py",
}
