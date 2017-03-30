include ::westlife::volume
include ::westlife::nofirewall

if ($::cloudify_ctx_type == 'node-instance') {
  class { '::torque::mom':
    server_name => $::torque_server_name,
  }

} elsif ($::cloudify_ctx_type == 'relationship-instance') {
  $_node_fqdn = regsubst($::fqdn, '\.', '_', 'G')
  ctx { "torque_node_${_node_fqdn}":
    value => 1,  # we want the node exclusively
    #value => $facts['processors']['count'],
    side  => 'target',
  }

} else {
  fail('Standalone execution')
}
