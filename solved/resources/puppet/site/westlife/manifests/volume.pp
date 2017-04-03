class westlife::volume (
  $device,
  $fstype,
  $mountpoint,
  $owner = 'root',
  $group = 'root',
  $mode  = '0777'
) {
  exec { "/usr/bin/mkdir ${mountpoint}":
    creates => $mountpoint,
  }

  if $facts['disks'][delete($device, '/dev/')] {
    mount { $mountpoint:
      ensure  => mounted,
      device  => $device,
      fstype  => $fstype,
      atboot  => true,
      options => 'defaults',
      require => Exec["/usr/bin/mkdir ${mountpoint}"],
      before  => File[$mountpoint],
    }
  }

  # fix dir. permissions after mount
  file { $mountpoint:
    ensure => directory,
    owner  => $owner,
    group  => $group,
    mode   => $mode,
  }
}
