#!/bin/bash
INSTALL_FILE="splunkforwarder.tgz"
SPLUNK_INDEXER="indexer:9997"
HOST_NAME="hp-md-01"
SSH_PORT="1337"
KIPPO_HOST="dev01"

# Adding required users
useradd splunk
useradd kippo

# Based on the OS (Debian or Redhat based), use the OS package manger to download required packages
if [ -f /etc/debian_version ]; then
    apt-get -y update
    apt-get -y install python-dev python-openssl python-pyasn1 authbind git python-pip libcurl4-gnutls-dev libssl-dev openssh-server
    pip install pycrypto
    pip install service_identity
    pip install requests
    pip install ipwhois
    pip install twisted
elif [ -f /etc/redhat-release ]; then
    yum -y update
    yum -y install wget python-devel python-zope-interface unzip git
    # Development Tools isn't needed, so, we need to figure out the packages we need
    yum -y group install "Development Tools"
    easy_install pycrypto pyasn1 twisted requests
else
    DISTRO=$(uname -s)
fi

# Installing Kippo Honeypot
cd /opt
# Using a fork of Kippo from Michel Oosterhof, which adds some new commands and better logging
git clone https://github.com/micheloosterhof/kippo.git
cd kippo
cp kippo.cfg.dist kippo.cfg
# Changing the Honeypot name as well as changing the port that Kippo listens on
sed -i "s/svr03/$KIPPO_HOST/" kippo.cfg
sed -i "s/#listen_port = 2222/listen_port = 22/" kippo.cfg

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

if [ $(uname -m) == 'x86_64' ]; then
    wget -O ${INSTALL_FILE} 'http://www.splunk.com/page/download_track?file=6.2.2/universalforwarder/linux/splunkforwarder-6.2.2-255606-Linux-x86_64.tgz&ac=&wget=true&name=wget&platform=Linux&architecture=x86_64&version=6.2.2&product=splunk&typed=release'
else
    wget -O ${INSTALL_FILE} 'http://www.splunk.com/page/download_track?file=6.2.2/universalforwarder/linux/splunkforwarder-6.2.2-255606-Linux-i686.tgz&ac=&wget=true&name=wget&platform=Linux&architecture=i686&version=6.2.2&product=splunk&typed=release'
fi

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
sed -i "s/test/$SPLUNK_INDEXER/" outputs.conf

chown -R splunk:splunk /opt/splunkforwarder
/opt/splunkforwarder/bin/splunk restart
