#!/bin/bash

if [ `id -u` -ne 0 ]; then
	exec sudo -E /bin/bash -c "$0"
fi

set -x

# Install an Let's encrypt client
# N.B. The most straightforward way is used here, think of security implications.

wget -O /usr/local/sbin/dehydrated https://raw.githubusercontent.com/lukas2511/dehydrated/master/dehydrated
chmod +x /usr/local/sbin/dehydrated

mkdir -p /etc/dehydrated
cat > /etc/dehydrated/config <<EOF
BASEDIR=/etc/dehydrated
WELLKNOWN="/var/www/dehydrated"
#CONTACT_EMAIL=your@mail.org
#HOOK=/etc/dehydrated/hook.sh
EOF

/usr/local/sbin/dehydrated --register --accept-terms

# Adapt Apache configuration for letsencrypt

mkdir -p /var/www/dehydrated

cat > /etc/httpd/conf.d/letsencrypt.conf << EOF
Alias /.well-known/acme-challenge /var/www/dehydrated/

<Directory /var/www/dehydrated>
        Options None
        AllowOverride None
        Order allow,deny
        Allow from all
</Directory>
EOF

systemctl restart httpd

# Obtain host credentials

hostname -f >> /etc/dehydrated/domains.txt
/usr/local/sbin/dehydrated -c -f /etc/dehydrated/config

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

HOST_NAME=$(hostname -f)

# Install dependencies

yum -y install mod_auth_mellon php

# Configure Apache for auth_mellon

ENTITYID=urn:https://$HOST_NAME/

mkdir -p /etc/httpd/mellon
cd /etc/httpd/mellon
/usr/libexec/mod_auth_mellon/mellon_create_metadata.sh $ENTITYID "https://$HOST_NAME/mellon/"

# To craft the filename in the same way that mellon_create_metadata.sh does:
OUTFILE="$(echo "$ENTITYID" | sed 's/[^A-Za-z.]/_/g' | sed 's/__*/_/g')"

cat > /etc/httpd/conf.d/saml.conf << EOF
LoadModule auth_mellon_module /usr/lib64/httpd/modules/mod_auth_mellon.so

<Location />
	MellonSPPrivateKeyFile /etc/httpd/mellon/${OUTFILE}.key
	MellonSPCertFile /etc/httpd/mellon/${OUTFILE}.cert
	MellonSPMetadataFile /etc/httpd/mellon/${OUTFILE}.xml
	MellonIdPMetadataFile /etc/httpd/mellon/idp-metadata.xml
	MellonEndpointPath "/mellon"
</Location>

Alias /auth_test /var/www/html/auth_test
<Directory "/var/www/html/auth_test">
	Options +ExecCGI
	AddHandler cgi-script .cgi
	AuthType Mellon
	MellonEnable "auth"
	Require valid-user
</Directory>
EOF

# Obtain metadata from IdP

wget -O /etc/httpd/mellon/idp-metadata.xml https://auth.west-life.eu/simplesaml/saml2/idp/metadata.php

# Deploy a testing script

mkdir -p /var/www/html/auth_test
cat > /var/www/html/auth_test/index.cgi << EOF
#!/bin/bash

echo "Content-type: text/plain"
echo ""

env
EOF

# Restart the web server

systemctl restart httpd
