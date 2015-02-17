###### *This app is still in heavy development. Please note that if you do download this, it is not the final copy and code may be wrong or not optimized, and definitely not meeting best practices in most cases. We are working on this app and will continue to update this page as it gets developed.*

# Tango | Honeypot Intelligence

## About
Tango is a tool which helps organizations deploy honeypots and enables the tranmission of their logs back to you via Splunk, so you can analyze and track what is happening on your honeypots. Tango provides scripts which allow you to install everything you need on a brand-new system, or if you have existing honeypots that you want to start collecting logs from. By running the scripts provided, you can easily and rapidly deploy as many honeypots as you would like without worrying about the administration and management, so you can focus on the analysis and reacting to the threats.

<p align="center">
<img src="http://f.cl.ly/items/2w113m143M2U0x0P0B2Q/Slide1.png"></p>

## Sensor Installation (Kippo and Splunk Universal Fowarder)
This script has been tested on a brand-new install of Ubuntu 14.04 with no reported issues.

Copy sensor.sh to the server you wish to install Kippo and Splunk on.

Before running the sensor.sh script you will need to edit the script and change the following:

- SPLUNK_INDEXER="" - Set this to your Splunk Indexer/Heavy Forwarder
- HOST_NAME="hp-md-01" - You can change this if you would like, this is the name of the Tango Sensor that will be sent into Splunk.
- SSH_PORT="1337" - This is the new SSH port that you can access the Tango Sensor on, since in the script we enable port forwarding on port 22 to Kippo's port 2222
- KIPPO_HOST="dev01" - This can be changed if you would like to change the Kippo honeypot name. This can also be changed in kippo.cfg

There are some other options you can change in /opt/kippo/kippo.cfg if you choose, however, some of these will break the forwarding of logs (such as changing the listening port set to 2222), however, there are some extra modules, such as mysql or xmpp logging you can enable if you choose.

Kippo is highly configurable, so if you wish to add extra commands or output to Kippo, there are tons of resources on github or google, which can help you do that if you choose.

After configuring, follow these steps:

```
su root
chmod +x sensor.sh
./sensor.sh
```

The script will install the required packages based on the OS, then install Kippo, and lastly, install the Splunk Universal Forwarder. 

## Sensor Installation (Splunk UF Only)

If you already have Kippo honeypots deployed and wish to start analyzing their logs in the Tango Honeypot Intelligence Splunk App, you can run the uf_only.sh script, which will install the Splunk UF on your host, and configure the inputs and outputs necessary to start viewing your logs.

To get started, place the uf_only.sh script on the server you are running Kippo. Edit the shell script to change your Splunk Indexer/Forwarder name, you can also change the Host Name to whatever you choose. Lastly, you will need to change the location of the Kippo logs to wherever they are stored on your machine.

After you have made the necessary changes:

```
su root
chmod +x uf_only.sh
./uf_only.sh
```

## Server Installation

In order to view the logs you are sending from Kippo, you will need to install Splunk Enterprise on a server, and install the Tango Honeypot Intelligence for Splunk App from this repo. There are plenty of guides on Splunk's website to get Splunk Enterprise running, however, the basic gist of setting up a server is this:

- Download Splunk Enterprise from Splunk
- Copy the Tango Honeypot Intelligence for Splunk App into $SPLUNK_HOME/etc/apps/
- Create a Splunk listener on port 9997 (It's not required to be on 9997, however, the scripts are configured to use that port, so, if you change the port, change it everywhere)
- Restart Splunk

Once in Splunk, you can start using the Tango app to analyze your Honeypot logs.

### Tango Honeypot Intelligence for Splunk App

Now that you have your sensors and server running, you'll want to use the Tango Splunk App to analyze your logs and start identifying what the attackers are doing on your systems. Start by logging into Splunk and clicking on the "Tango Honeypot Intelligence App" on the left-hand side.

<p align="center">
<img src="http://f.cl.ly/items/1v1c083s1G232m1F1O18/Screen%20Shot%202015-02-17%20at%204.11.00%20PM.png"></p>

You'll notice in the navigation bar, there's a few different dashboards to choose from, which include:

- Attack Analysis
  - Attack Overview (Provides high-level details about # of attacks, latest attacks, attempts vs. successes, distinct attacker IP's)
<p align="center">
<img src="http://f.cl.ly/items/130H3W1b1p183O143g1w/Screen%20Shot%202015-02-17%20at%204.27.46%20PM.png"></p>
  - Session Playlog (Allows you to replay the attackers session on your honeypot so you can see what commands where entered during each session.)
<p align="center">
<img src="http://f.cl.ly/items/130H3W1b1p183O143g1w/Screen%20Shot%202015-02-17%20at%204.27.46%20PM.png"></p>
-  Session Analysis (Provides details on the information taken from session initiation, to include SSH Key Algorithms, SSH Versions, PTY Request Options, specific environment details (Language, Keyboard encoding))
<p align="center">
<img src="http://f.cl.ly/items/1V1s0p331h2D3V3W223y/Screen%20Shot%202015-02-17%20at%204.23.30%20PM.png"></p>
-  Location Overview (Gives location-based data, such as where attackers are coming from and where they are attacking most)
<p align="center">
<img src="http://f.cl.ly/items/201U2t0o1N3G2r08130i/Screen%20Shot%202015-02-17%20at%204.28.43%20PM.png"></p>
-  Username/Password Analysis (General username/password statistics, top username/password combos, etc.)
<p align="center">
<img src="http://f.cl.ly/items/133N1p2f3z3Z2Y220b1k/Screen%20Shot%202015-02-17%20at%204.29.19%20PM.png"></p>
- Malware Analysis
-   File Analysis (When a user successfully downloads malware on the Honeypot, the inforamtion about that file will be provided here, to include SHA hash as well as information taken from VirusTotal's API (# of vendors that ID'ed the malware, malware names, etc.))
<p align="center">
<img src="http://f.cl.ly/items/133N1p2f3z3Z2Y220b1k/Screen%20Shot%202015-02-17%20at%204.29.19%20PM.png"></p>
-   URL Analysis (Any URL's or IP Addresses seen in the session will be analyzed here. A lot of times, the attacker will paste commands in the terminal and mess something up, or try to include a URL in a long, complicated command which was messed up, which means it won't actually get downloaded. For those scenarios, you can look at the analysis of the attempted malware downloads and URL's/Domains that were hit in this dashboard. This will provide the same information from the File Analysis portion as well, from VirusTotal.)
<p align="center">
<img src="http://f.cl.ly/items/0f1z1Z1g3y271V2n2I23/Screen%20Shot%202015-02-17%20at%204.31.42%20PM.png"></p>
- Sensor Management (Gives details about each deployed sensor, their location, ISP, netblock, etc.)
- Threat Feed (This is more of a placeholder currently, this will eventually store the various feeds (C2, IP Addresses, URL's, Domains, File Hashes, etc.) that you can download and integrate with other tools.)
