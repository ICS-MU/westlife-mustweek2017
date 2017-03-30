
$code_dir = '/var/www/saxs'

ensure_packages('python-virtualenv')

$_custom_fragment = "
  <Directory '$code_dir'>
        Options +ExecCGI
        AddHandler cgi-script .cgi
        SetEnv  HTTP_EPPN john.hacker@somewhere.com
        SetEnv  HTTP_CN 'John Hacker'
        SetEnv  HTTP_MAIL john.hacker@somewhere.com
  </Directory>
"

::apache::vhost { 'http':
	ensure		=> present,
	port		=> 80,
	docroot		=> $code_dir,
	manage_docroot	=> true,
	custom_fragment	=> $_custom_fragment,
}

$_saxs_tgz = '/tmp/saxs-portal.tgz'

file { $_saxs_tgz:
	ensure 	=> file,
	source 	=> 'puppet:///modules/saxs/saxs-portal.tgz'
}

archive { $_saxs_tgz:
	extract		=> true,
	extract_path	=> $code_dir,
}
