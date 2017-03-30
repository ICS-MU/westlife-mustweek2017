#!/bin/bash

if [ `id -u` -ne 0 ]; then
	exec sudo -E /bin/bash -c "$0"
fi

set -x

PATH=/tmp/cloudify-ctx:$PATH

ctx logger info "Runnig at `hostname`"

# Install necessary tools
ctx logger info "Installing dependencies"
yum -y install python-virtualenv wget python34

# Setup apache for SAXS
ctx logger info "Configuring Apache"
rm -f /etc/httpd/conf.d/welcome.conf
#sed -i 's@^DocumentRoot.*@DocumentRoot "/var/www/saxs"@' /etc/httpd/conf/httpd.conf
for f in /etc/httpd/conf/httpd.conf /etc/httpd/conf.d/*.conf; do
	sed -i 's@DocumentRoot.*@DocumentRoot "/var/www/saxs"@' $f
done
cat > /etc/httpd/conf.d/saxs.conf << EOF
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

# Setup SAXS portal application
ctx logger info "Setting up web interface"
ctx download-resource resources/saxs-portal/saxs-portal.tar.gz '@{"target_path": "/tmp/saxs-portal.tar.gz"}'
cd /var/www
tar xvzf /tmp/saxs-portal.tar.gz
cd /var/www/saxs
virtualenv flask
source flask/bin/activate
pip install -r requirements.txt

# Setup SAXS portal database with one default user
ctx logger info "Configuring database"
mkdir -p /var/www/SaxsExperiments/1
python /var/www/saxs/db_create.py
sqlite3 /var/www/SaxsExperiments/app.db "insert into users values (1,'John Hacker','john.hacker@somewhere.com','john.hacker@somewhere.com',1,1);"
groupadd saxs
chown -R apache:saxs /var/www/SaxsExperiments

# Install server-side scripts
ctx logger info "Setting up submission server"
#wget http://fi.muni.cz/~xracek/westlife/saxs-server.tar.gz
ctx download-resource resources/saxs-portal/saxs-server.tar.gz '@{"target_path": "/tmp/saxs-server.tar.gz"}'
cd /
tar xvzf /tmp/saxs-server.tar.gz 

# Setup syslog for SAXS
echo "local7.* /var/log/saxs.log" > /etc/rsyslog.d/30-saxs.conf
systemctl restart rsyslog

# Fire things up
#firewall-cmd --add-service=http --permanent
#firewall-cmd --reload

#systemctl enable httpd.service
#systemctl start httpd.service

#su -s /bin/bash saxs -c "cd /usr/local/saxs/; ./saxsd.sh &"


ctx logger info "Sleeping"
sleep 300
