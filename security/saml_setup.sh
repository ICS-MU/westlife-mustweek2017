#!/bin/bash

if [ `id -u` -ne 0 ]; then
	exec sudo -E /bin/bash -c "$0"
fi

set -x

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
#!/bin/sh

echo "Content-type: text/plain"
echo ""

env
EOF
chmod +x /var/www/html/auth_test/index.cgi

# Restart the web server

systemctl restart httpd
