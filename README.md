# Tango
#### A Splunk-managed Honeypot Solution

## About
Tango is a tool which helps organizations deploy honeypots and enable the secure communication of their logs back to you via Splunk, so you can analyze and track what is happening on your honeypots. Tango provides the scripts to install the Tango Server (Splunk Indexer/Search Head) as well as the Tango Sensors (Linux server running Kippo and a Splunk Universal Forwarder). By running the scripts provided, you can easily and rapidly deploy as many honeypots as you would like without worrying about the administration and management, so you can focus on the analysis and reacting to the threats.

## Installation
There are two parts to the installation, one is setting up the Tango Server, the other is setting up the sensors. 

### Server Installation
This has been tested on a brand-new install of Ubuntu 14.04 with no reported issues.

Copy server.sh to the server you wish to install on
```
su root
chmod +x server.sh
./server.sh
```
The script will install Splunk, which at this time is version 6.2.1 and set up receiving on port 9997. This script will also download the Tango Honeypot Intelligence Splunk App and install it in the right location. After installation, you can test the install was successful by logging into Splunk at http://server_ip:8000. The login credentials are admin:changeme, which will need to be changed at log on. Once logged in, you can click on the left-hand side to access the Tango Honeypot Intelligence App, this will contain all the dashboards, reports and analytics needed to monitor your honeypots.

### Client Installation
This script has been tested on a brand-new install of Ubuntu 14.04 with no reported issues.

Copy client.sh to the server you wish to install on

Before running the client.sh script you will need to edit the script and change the following:

- SPLUNK_INDEXER="" - Set this to your Tango Server's IP address
- HOST_NAME="hp-md-01" - You can change this if you would like, this is the name of the Tango Sensor that will be sent into Splunk. This would need to be changed on every new sensor so you can distinguish attacks by each sensor.
- SSH_PORT="1337" - This is the new SSH port that you can access the Tango Sensor on, since in the script we enable port forwarding on port 22 to Kippo's port 2222
- KIPPO_HOST="dev01" - This can be changed if you would like to change the Kippo honeypot name. This can also be changed in kippo.cfg

There are some other options you can change in /opt/kippo/kippo.cfg if you choose, however, some of these will break the forwarding of logs (such as changing the listening port set to 2222), however, there are some extra modules, such as mysql or xmpp logging you can enable if you choose.

Kippo is highly configurable, so if you wish to add extra commands or output to Kippo, there are tons of resources on github or google, which can help you do that if you choose.

After configuring, follow these steps:

```
su root
chmod +x client.sh
./client.sh
```

The script will install the required packages based on the OS, then install Kippo, and lastly, install the Splunk Universal Forwarder. 

#### Verifying Successful Installation

Once you have your server and sensors installed, log into your Tango Server (http://server_ip:8000) and log in with the password you configured earlier. Click on the "Search & Reporting" app located on the left-hand side. On the right-hand side in the text box, there is a time-selector, select "All time (real-time)". Then in the search bar, type in ```index=honeypot``` and then press enter. Next, open a terminal and attempt to ssh as root to the Tango Sensor IP address. At the password prompt, enter ```123456```. Open up your browser again, and in the Splunk results window, you should see events, this means your install is working. 



