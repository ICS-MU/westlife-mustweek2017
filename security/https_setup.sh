#!/bin/bash

if [ `id -u` -ne 0 ]; then
	exec sudo -E /bin/bash -c "$0"
fi

set -x

# Install the TLS module

yum -y install mod_ssl

# Configure Apache

HOSTNAME=$(hostname -f)

cat > /etc/httpd/conf.modules.d/socache_shmcb.load << EOF
LoadModule socache_shmcb_module modules/mod_socache_shmcb.so
EOF

cat > /etc/httpd/conf.d/20-default-tls.conf << EOF
<VirtualHost *:443>
	ServerName $HOSTNAME
	DocumentRoot /var/www/saxs

	SSLEngine on
	SSLCertificateFile /etc/dehydrated/certs/${HOSTNAME}/cert.pem
	SSLCertificateChainFile /etc/dehydrated/certs/${HOSTNAME}/chain.pem
	SSLCertificateKeyFile /etc/dehydrated/certs/${HOSTNAME}/privkey.pem
</VirtualHost>
EOF

# Restart the web server

systemctl restart httpd
