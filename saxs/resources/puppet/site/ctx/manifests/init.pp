define ctx (
  $side = '',
  $key  = $title,
  $value, 
) {
  exec { "ctx ${side} instance runtime_properties ${key} ${value}":
    path => '/tmp/cloudify-ctx:/bin:/usr/bin',
  }
}
