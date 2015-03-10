#!/bin/bash
INSTALL_FILE="splunkforwarder.tgz"
SPLUNK_INDEXER="indexer:9997"
HOST_NAME="hp-md-01"
KIPPO_LOG_LOCATION='/opt/kippo/log/kippolog.json.*'

# Adding required users
useradd splunk

# Based on the OS (Debian or Redhat based), use the OS package manger to download required packages
if [ -f /etc/debian_version ]; then
    apt-get -y update
    apt-get -y install python-dev python-openssl python-pyasn1 authbind git python-pip libcurl4-gnutls-dev libssl-dev
    pip install pycurl
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
sed -i "s,/opt/kippo/log/kippo.log,${KIPPO_LOG_LOCATION}," inputs.conf
sed -i "s/test/$SPLUNK_INDEXER/" outputs.conf

chown -R splunk:splunk /opt/splunkforwarder
/opt/splunkforwarder/bin/splunk restart
