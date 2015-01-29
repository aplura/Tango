# Tango
#### A Splunk-managed Honeypot Solution

## How Tango Works

Tango is essentially two different solutions. The first is the data collection and analysis, and the second is the Threat Intelligence portion, which is a free set of threat intel provided to end-users for use in their security monitoring tools. 

The first part of Tango, the data collection and analysis is performed by Splunk Universal Forwarders installed on each host system running the honeypot. The honeypot will generate the logs, and the UF will send the logs generated to a listening Splunk Indexer residing elsewhere. In addition to sending honeypot logs to the Indexer, the host will send it's system logs to the Splunk Indexer as well. This is to alert Tango users of an actual compromise by monitoring the processes, users and network connections on the host. Since the honeypots shouldn't be used in any sort of official capacity or have any meaningful data on it, any new process or user on the machine should provide some indication that something isn't right. 

Once the data is received by the Indexer, the logs will be parsed and displayed in the Tango Threat Intelligence Splunk App. This app will include dashboards for the following:
- Attacker Analysis
- Malware Analysis
- Sensor Management

This is where the second solution comes into play...

After the data has been analyzed and parsed by our Splunk app, we will provide various metrics on the data collected. All of the data will be displayed in one of the dashboards above, however, almost all of the data will be included in the Tango Threat Intelligence (TTI) feed. The TTI will be compromised of all the Indicators of Compromise (IOCs) that were discovered in the Honeypot analysis. This could include IP addresses of known C2 nodes, MD5/SHA1 hashes of malware downloaded by the attacker, URL's of sites hosting malware, etc. The TTI is compeletly free and will be distributed to end-users by downloading the feed from our GitHub page. Updates to the feed will be done daily, and provided in various formats to ease the integration into your security tools.
