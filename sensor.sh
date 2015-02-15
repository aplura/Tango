#!/bin/sh
INSTALL_FILE="splunkforwarder-6.1.6-249101-Linux-x86_64.tgz"
SPLUNK_INDEXER="omgpwnd.no-ip.biz:9997"
HOST_NAME="hp-md-01"
SSH_PORT="1337"
KIPPO_HOST="dev01"

# Adding required users
useradd splunk
useradd kippo

# Based on the OS (Debian or Redhat based), use the OS package manger to download required packages
if [ -f /etc/debian_version ]; then
    apt-get -y update
    apt-get -y install python-dev python-openssl python-pyasn1 authbind git python-pip libcurl4-gnutls-dev libssl-dev
    pip install pycurl
    pip install pycrypto
    pip install service_identity
    pip install ipwhois
elif [ -f /etc/redhat-release ]; then
    yum -y update
    yum -y install wget python-devel python-zope-interface unzip git
    # Development Tools isn't needed, so, we need to figure out the packages we need
    yum -y group install "Development Tools"
    easy_install pycrypto pyasn1
else
    DISTRO=$(uname -s)
fi

# Grabbing Twisted Source
cd /tmp
wget https://pypi.python.org/packages/source/T/Twisted/Twisted-15.0.0.tar.bz2
tar -xvf Twisted-15.0.0.tar.bz2
cd Twisted-15.0.0/twisted/python
# Adding our custom time format to include microseconds
sed "s/%d-%02d-%02d %02d:%02d:%02d%s%02d%02d/%d-%02d-%02d %02d:%02d:%02d.%02d %s%02d%02d" log.py
sed "s/when.hour, when.minute, when.second,/when.hour, when.minute, when.second,when.microsecond" log.py
cd ../..
python setup.py install

# Installing Kippo Honeypot
cd /opt
# Using a fork of Kippo from Michel Oosterhof, which adds some new commands and better logging
git clone https://github.com/micheloosterhof/kippo.git
cd kippo
cp kippo.cfg.dist kippo.cfg
# Changing the Honeypot name as well as changing the port that Kippo listens on
sed -i "s/svr03/$KIPPO_HOST/" kippo.cfg
sed -i "s/2222/22/" kippo.cfg

# Changing the port that SSH listens on to the variable set above
if [ -f /etc/debian_version ]; then
    cd /etc/ssh/
    sed -i "s/Port 22/Port $SSH_PORT/" sshd_config
    service ssh restart
elif [ -f /etc/redhat-release ]; then
    cd /etc/ssh/
    sed -i "s/#Port 22/Port $SSH_PORT/" sshd_config
    service sshd restart
    cd /tmp
    git clone https://github.com/tootedom/authbind-centos-rpm.git
    cd authbind-centos-rpm/authbind/RPMS/x86_64/
    rpm -i authbind-2.1.1-0.x86_64.rpm
else
    echo
fi

# Setting up authbind to allow kippo user to bind to privileged port
touch /etc/authbind/byport/22
chown kippo:kippo /etc/authbind/byport/22
chmod 777 /etc/authbind/byport/22
chown -R kippo:kippo /opt/kippo
cd /opt/kippo
sed -i "s,twistd -y kippo.tac -l log/kippo.log --pidfile kippo.pid,authbind --deep twistd -y kippo.tac -l log/kippo.log --pidfile kippo.pid," start.sh
su kippo -c "./start.sh"

# Installing Splunk Universal Forwarder
mkdir /home/splunk
chown -R splunk:splunk /home/splunk
cd /opt
wget -O splunkforwarder-6.1.6-249101-Linux-x86_64.tgz 'http://www.splunk.com/page/download_track?file=6.1.6/universalforwarder/linux/splunkforwarder-6.1.6-249101-Linux-x86_64.tgz&ac=&wget=true&name=wget&platform=Linux&architecture=x86_64&version=6.1.6&product=splunk&typed=release'
tar -xzf $INSTALL_FILE
chown -R splunk:splunk splunkforwarder
su splunk -c "/opt/splunkforwarder/bin/splunk start --accept-license --answer-yes --auto-ports --no-prompt"
/opt/splunkforwarder/bin/splunk enable boot-start -user splunk

# Installing the tango_input app which configures inputs and outputs and hostname
git clone https://github.com/aplura/Tango.git
cd Tango
mv tango_input /opt/splunkforwarder/etc/apps/
cd /opt/splunkforwarder/etc/apps/tango_input/default
sed -i "s/test/$HOST_NAME/" inputs.conf

chown -R splunk:splunk /opt/splunkforwarder
/opt/splunkforwarder/bin/splunk restart
