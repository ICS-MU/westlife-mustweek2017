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
