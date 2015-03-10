<p align="center">
<img src="http://i.imgur.com/r8Hpjvj.png"></p>

## About
Tango is a set of scripts and Splunk apps which help organizations and users quickly and easily deploy honeypots and then view the data and analysis of the attacker sessions. There are two scripts provided which facilitate the installation of the honeypots and/or Splunk Universal Forwarder. One of the scripts `uf_only.sh` will install the Splunk Universal Forwarder and install the necessary input and output configuration files. The other script `sensor.sh` will install the Splunk Universal Forwarder along with the Kippo honeypot required for the Tango Honeypot Intelligence app to work.

<p align="center">
<img src="http://f.cl.ly/items/2w113m143M2U0x0P0B2Q/Slide1.png"></p>

## Before You Begin

There are a few things that should be noted before you install:

- When you deploy the input app on a sensor, the app will communicate with the website, [ipv4.icanhazip.com](www.ipv4.icanhazip.com) to get the external IP address of the sensor. This is useful information for the sensor management portion of the app. Please feel free to remove if you'd rather not communicate with that site. Please note that if you do not use this, a lot of the "Sensor Management" fields will be blank.
- The Tango Honeypot Intelligence Splunk App is built to use JSON formatted data from Kippo, this was made available in the fork maintained by Michel Oosterhof, which can be found on his [github](https://github.com/micheloosterhof/kippo). He recently added this feature, so you will need to grab the latest copy for this app to work properly (if deploying the honeypot and Splunk separately.)
- You will need to add your own VirusTotal API key to the Splunk app, which can be configured at /opt/splunk/etc/apps/tango/bin/vt.py  The API is free to obtain, you will just need to follow the procedures found on their website to receive one. Please note that you are limited to 4 requests per minute, so if you attempt to do more than that, you will not receive any information. This pertains to the File Analysis section of the Splunk Honeypot Intelligence app.

## Installation


### Sensor Installation (Kippo and Splunk Universal Fowarder)
This script has been tested on a brand-new install of Ubuntu 14.04 and Cent OS 7 with no reported issues.

Copy sensor.sh to the server you wish to install Kippo and Splunk on.

Before running the sensor.sh script you will need to edit the script and change the following:

Variable | Purpose
--- | ---
SPLUNK_INDEXER | Set this to your Splunk Indexer/Intermediate Forwarder
HOST_NAME | This is the hostname for the sensor that will appear in Splunk
SSH_PORT | You will need to SSH to the sensor on this port
KIPPO_HOST | *optional* This is the hostname of the honeypot attackers will see

There are some other options you can change in /opt/kippo/kippo.cfg if you choose, however, some of these will break the forwarding of logs (such as changing the listening port set to 2222), however, there are some extra modules, such as mysql or xmpp logging you can enable if you choose.

Kippo is highly configurable, so if you wish to add extra commands or output to Kippo, there are tons of resources on github or google, which can help you do that if you choose.

After configuring, follow these steps:

```
su root
chmod +x sensor.sh
./sensor.sh
```

The script will install the required packages based on the OS, then install Kippo, and lastly, install the Splunk Universal Forwarder. 

### Sensor Installation (Splunk UF Only)

If you already have Kippo honeypots deployed and wish to start analyzing their logs in the Tango Honeypot Intelligence Splunk App, you can run the uf_only.sh script, which will install the Splunk UF on your host, and configure the inputs and outputs necessary to start viewing your logs.

To get started, place the uf_only.sh script on the server you are running Kippo. Edit the shell script to change your Splunk Indexer/Forwarder name, you can also change the Host Name to whatever you choose. Lastly, you will need to change the location of the Kippo logs to wherever they are stored on your machine.

After you have made the necessary changes:

```
su root
chmod +x uf_only.sh
./uf_only.sh
```

### Server Installation

In order to view the logs you are sending from Kippo, you will need to install Splunk Enterprise on a server, and install the Tango Honeypot Intelligence for Splunk App from this repo. There are plenty of guides on Splunk's website to get Splunk Enterprise running, however, the basic gist of setting up a server is this:

- Download Splunk Enterprise from Splunk
- Copy the Tango Honeypot Intelligence for Splunk App into $SPLUNK_HOME/etc/apps/
- Create a Splunk listener on port 9997 (It's not required to be on 9997, however, the scripts are configured to use that port, so, if you change the port, change it everywhere)
- Add your VirusTotal API key to /opt/splunk/etc/apps/tango/bin/vt.py
- Restart Splunk

Once in Splunk, you can start using the Tango app to analyze your Honeypot logs.

## Tango Honeypot Intelligence for Splunk App

Now that you have your sensors and server running, you'll want to use the Tango Splunk App to analyze your logs and start identifying what the attackers are doing on your systems. Start by logging into Splunk and clicking on the "Tango Honeypot Intelligence App" on the left-hand side.

Once you enter the app, you'll be first taken to the "Attack Overview" portion of the app, which shows a broad overview of the attacks against your sensors. This includes Attempts vs. Successes, Latest Logins, Attackers logging into multiple locations, etc.

You'll notice at the top of the app, in the navigation pane, there are multiple categories of reports available to you, which include:

- Attack Analysis
- File Analysis
- Network Analysis
- Sensor Management
- Threat Feed

Below we will go through each section and describe some of the data available in each section.

### Attack Analysis

##### Attack Overview

This dashboard shows a broad overview of the attacks against your sensors. This includes Attempts vs. Successes, Latest Logins, Attackers logging into multiple locations, etc.

##### Session Playlog

This is one of the most beneficial dashboards available in the app, since it actually shows you what the attacker is doing on your honeypot. At the top of the dashboard, you can see the most recent sessions along with a filter to select a particular sensor. Clicking on a session will populate the panels below, which includes the passwords attempted/accepted, the commands entered, any files downloaded during the session and the raw logs for the session.

##### Attacker Profile

Using this dashboard, you can inquire about a certain IP and if seen in the app, you can get valuable information pertaining to that IP to include:

- Geolocational data
- Times seen
- SSH Client versions
- Sessions seen
- Files Downloaded

##### Session Analysis

This series of dashboards contains some analytical information, to include the % of sessions with interaction, the various SSH versions seen, some environment details extracted by the session, and a Human vs. Bot Identification dashboard.

##### Location Overview

In this section, you are able to see various geographical data related to each session and attacker. There are currently three dashboards available:

- Top countries from which attackers have logged in from
- Top countries where attackers have scanned from
- Top sensors that have been attacked

We also include a map which includes the location of attackers seen.

##### Username/Password Analysis

Currently, this dashboard contains the top usernames and passwords seen being attempted by the attackers, as well as the top username/password combinations.

### Malware Analysis

##### File Analysis

Starting at the top of this page, you can see the latest files downloaded by attackers, which includes the following:

- URL of file
- SHA256 Hash of file
- Sensor which the file was seen being download
- The session identifier of the session, which the file was downloaded
- The time that the file was downloaded

Below that is the latest "Attempted" file downloads. This contains URL's that were seen in a session that do not have a corresponding SHA256 hash (which indicates a successful download). This can be due to a server error on the hosting website, an incorrect spelling of the file, or if this URL was seen elsewhere in the command, perhaps as an argument or target site of the malware.

Lastly, is a panel which you are able to look up a particular SHA256 hash seen previously downloaded in VirusTotal to retrieve the following information:

- Date Scanned
- SHA256 Hash
- How many AV vendors identified this file
- The various signatures of the file

Please note that the VirusTotal API is limited to 4 requests per minute. With that being said, you can use this panel to quickly lookup the file hashes seen by in your sessions.

This "lookup" will produce a local "cache" to use in other dashboards, so it's useful to run lookups on any malware you see. This was created do to limitations in the Virustotal API, and will be used as a workaround for the time being.

##### Malware Analysis

This dashboard will show the Top 10 Malware Signatures we've seen over time, as well as the most recent legitimate malware. This dashboard is populated from the VirusTotal local "cache" found on the File Analysis page. This dashboard will also show you files that have been downloaded, but, produced no signatures in Virustotal.

##### Malware Campaigns

This set of reports give you information on possible campaigns associated with your sessions. Currently this includes:

- Potential Malware Campaigns (By URL)
- Potential Malware Campaigns (By Domain)
- Potential Malware Campaigns (By Filename)
- Potential Malware Campaigns (By SHA Hash)

This section will continue to be developed to include other possible campaign attribution by looking at other TTP's associated with each session. This could include commands entered during each session, terminal variables (size, language, SSH keys, etc.). For now, we can see the URL's, Domain's and Filenames that have been seen being used by multiple attackers.

### Network Analysis

This dashboard currently includes reports on the following:

- Top Domains Seen
- Same URI on Multiple Domains
- Latest IP Addresses Seen

### Sensor Management

##### Sensor Status

This dashboard provides geographical information pertaining to each sensor currently deployed. You will find the following information available to you in this dashboard:

- Sensor Name
- Last Active
- Sensor IP Address (External IP)
- ASN
- ASN Country
- Network Name
- Network Range

This dashboard also provides you with a map populated with the locations of all your sensors deployed.

##### Edit Sensor

In this dashboard, you are able to edit a few fields for your sensors, these fields are:

- Owner
- Owner Email
- Comment


### Threat Feed

Lastly, this dashboard contains feeds which you can download and integrate with other network monitoring solutions, which will hopefully be automated in the future.

The feeds currently available are:

- IP Addresses
- Potentially Malicious URLs
- SHA File Hashes
- Potentially Malicious Domains
- File Names

### Screenshots

Below are some screenshots which illustrate the features of Tango:

#### Attack Overview
<p align="center">
<img src="http://i.imgur.com/2ZkYzAF.png"></p>

#### Session Analysis
<p align="center">
<img src="http://i.imgur.com/O3WLbK0.png"></p>

#### Malware Campaigns
<p align="center">
<img src="http://i.imgur.com/sNhpSGo.png"></p>

#### Session Playlog
<p align="center">
<img src="http://i.imgur.com/nu4m5Eg.png"></p>

#### IOC Feed
<p align="center">
<img src="http://i.imgur.com/fT1XCSj.png"></p>

#### Network Analysis
<p align="center">
<img src="http://i.imgur.com/Rj29b9r.png"></p>

#### Malware Analysis
<p align="center">
<img src="http://i.imgur.com/SToO8q3.png"></p>

### To-Do
- Utilize Data Models to speed up searches
- Auto-extract indicators inside of malware
- TOR Exit Node Identifier
