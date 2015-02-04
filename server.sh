#!/bin/sh

useradd splunk
cd /opt
wget -O splunk.tgz http://download.splunk.com/products/splunk/releases/6.2.1/splunk/linux/splunk-6.2.1-245427-Linux-x86_64.tgz
tar -xvf splunk.tgz
chown -R splunk:splunk splunk
cd splunk
su splunk -c "/opt/splunk/bin/splunk start --accept-license --answer-yes --auto-ports --no-prompt"
/opt/splunk/bin/splunk enable boot-start -user splunk
mkdir /home/splunk
chown -R splunk:splunk /home/splunk
su splunk -c "/opt/splunk/bin/splunk enable listen 9997 -auth admin:changeme"

