#!/bin/sh
INSTALL_FILE="splunkforwarder-6.1.6-249101-Linux-x86_64.tgz"
SPLUNK_INDEXER="omgpwnd.no-ip.biz:9997"
HOST_NAME="hp-md-01"
SSH_PORT="1337"
KIPPO_HOST="dev01"

useradd splunk
useradd kippo

if [ -f /etc/debian_version ]; then
    apt-get -y update
    apt-get -y install python-twisted python-dev python-openssl python-pyasn1 authbind git python-pip libcurl4-gnutls-dev libssl-dev
    pip install pycurl
elif [ -f /etc/redhat-release ]; then
    yum -y update
    yum -y install wget python-devel python-zope-interface unzip git
    #####
    yum -y group install "Development Tools"
    #####
    easy_install Twisted pycrypto pyasn1
else
    DISTRO=$(uname -s)
fi

# Installing Kippo Honeypot
cd /opt
git clone https://github.com/micheloosterhof/kippo.git
cd kippo
cp kippo.cfg.dist kippo.cfg
sed -i "s/svr03/$KIPPO_HOST/" kippo.cfg
sed -i "s/2222/22/" kippo.cfg

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

#su splunk -c "/opt/splunkforwarder/bin/splunk add forward-server $SPLUNK_INDEXER -auth admin:changeme"
#su splunk -c "/opt/splunkforwarder/bin/splunk add monitor /opt/kippo/log/kippo.log -index honeypot -sourcetype kippo -host $HOST_NAME"

git clone https://github.com/aplura/Tango.git
cd Tango
mv tango_input /opt/splunkforwarder/etc/apps/
cd /opt/splunkforwarder/etc/apps/tango_input/default
sed -i "s/hostname/$HOST_NAME/"

chown -R splunk:splunk /opt/splunkforwarder
/opt/splunkforwarder/bin/splunk restart