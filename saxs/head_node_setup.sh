#!/bin/bash

if [ `id -u` -ne 0 ]; then
	exec sudo -E /bin/bash -c "$0"
fi

set -x

# Install necessary tools
yum -y -d1 install python-virtualenv wget python34

# Setup apache for SAXS
rm -f /etc/httpd/conf.d/*.conf
cat > /etc/httpd/conf.d/saxs.conf << EOF
DocumentRoot	/var/www/saxs
Alias /static /var/www/saxs/app/static
ScriptAlias / /var/www/saxs/run.cgi/

<Directory /var/www/saxs>
    Options +ExecCGI
    AddHandler cgi-script .cgi
    SetEnv  HTTP_EPPN john.hacker@somewhere.com
    SetEnv  HTTP_CN "John Hacker"
    SetEnv  HTTP_MAIL john.hacker@somewhere.com
</Directory>
EOF

adduser saxs
usermod -g saxs apache

# Setup SAXS portal application
#TODO Extract saxs-portal.tar.gz to /var/www
# Set owner:group to apache:saxs

cd /var/www/saxs
virtualenv flask
source flask/bin/activate
pip install -r requirements.txt &>/dev/null

# Setup SAXS portal database with one default user
mkdir -p /var/www/SaxsExperiments/1
python /var/www/saxs/db_create.py
sqlite3 /var/www/SaxsExperiments/app.db "insert into users values (1,'John Hacker','john.hacker@somewhere.com','john.hacker@somewhere.com',1,1);"

sed -i 's/Group apache/Group saxs/' /etc/httpd/conf/httpd.conf
chown -R apache:saxs /var/www/SaxsExperiments

# Handle ssh keys - we need worker node to be able to connect to saxs user
#TODO Double check the permissions on .ssh and included files
mkdir ~saxs/.ssh
chown -R saxs ~saxs/.ssh
chmod 700 ~saxs/.ssh

# Install server-side scripts
#TODO Extract saxs-server.tar.gz to /

# Setup syslog for SAXS
echo "local7.* /var/log/saxs.log" > /etc/rsyslog.d/30-saxs.conf
systemctl restart rsyslog

# Restart apache
systemctl restart httpd

# Run the whole thing
su -s /bin/bash saxs -c "cd /usr/local/saxs/; ./saxsd.sh &"
