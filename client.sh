#!/bin/sh
INSTALL_FILE="splunkforwarder-6.1.6-249101-Linux-x86_64.tgz"
SPLUNK_INDEXER="omgpwnd.no-ip.biz:9997"
HOST_NAME="hp-md-01"
SSH_PORT="1337"
KIPPO_HOST="dev01"

useradd splunk
useradd kippo

if [ -f /etc/debian_version ]; then
    apt-get -y install python-twisted
elif [ -f /etc/redhat-release ]; then
    yum -y update
    yum -y install wget python-devel python-zope-interface unzip
    yum -y group install "Development Tools"
    easy_install Twisted
    easy_install pycrypto
    easy_install pyasn1
else
    DISTRO=$(uname -s)
fi

# Installing Kippo Honeypot
cd /opt
wget -O kippo.zip https://github.com/desaster/kippo/archive/master.zip
unzip kippo.zip
mv kippo-master/ kippo
cd kippo
cp kippo.cfg.dist kippo.cfg
sed -i "s/svr03/$KIPPO_HOST/" kippo.cfg


cd /etc/ssh/
sed -i "s/Port 22/Port $SSH_PORT/" sshd_config

if [ -f /etc/debian_version ]; then
    service ssh restart
elif [ -f /etc/redhat-release ]; then
    service sshd restart
else
    echo "Please restart SSH manually"
fi

#############################
iptables -t nat -A PREROUTING -p tcp --dport 22 -j REDIRECT --to-port 2222
#############################


chown -R kippo:kippo /opt/kippo
cd /opt/kippo
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
#/opt/splunkforwarder/bin/splunk edit user admin -password password -roles admin -auth admin:changeme

cd /opt/splunkforwarder/etc/apps
mkdir kippo_input
cd kippo_input
mkdir default local
cd local
su splunk -c "/opt/splunkforwarder/bin/splunk add forward-server $SPLUNK_INDEXER -auth admin:changeme"
su splunk -c "/opt/splunkforwarder/bin/splunk add monitor /opt/kippo/log/kippo.log -index honeypot -sourcetype kippo -host $HOST_NAME"

chown -R splunk:splunk /opt/splunkforwarder
/opt/splunkforwarder/bin/splunk restart