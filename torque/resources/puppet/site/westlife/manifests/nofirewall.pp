class westlife::nofirewall {
  resources { 'firewall':
    purge => true,
  }

  class { '::firewall':
    ensure => 'stopped',
  }
}
