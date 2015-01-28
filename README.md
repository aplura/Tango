# Tango
A Splunk-managed Honeypot Solution

## Introduction
Tango is a Honeypot distribution and analysis platform useful for deploying and analyzing your large honeypot network, as well as generating rapid Threat Intelligence data. Tango works by installing a Splunk Universal Forwarder (UF), as well as the Kippo honeypot on a system. The logs from the honeypot are then sent securely to a Splunk Indexer where the logs can be parsed. Tango also includes a companion Splunk app that will present useful analysis and metrics on the honeypots data. The app will include dashboards for:
- Attacker Analysis
- Malware Analysis
- Sensor Management
- IOC Feed

This system is useful for generating Indicators of Compromise (IOCs) by analyzing the attackers and the Tools, Techniques and Procedures (TTPs) they utilize. This feed can then be exported and consumed by any tool which can consume Threat Intelligence data. Tango will provide end-users with the threat intelligence gathered from the honeypot network, which can be contributed to by anyone, which will expand the threat feed exponentially.

## How Tango Works

