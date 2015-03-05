import requests
from ipwhois import IPWhois

r = requests.get('http://icanhazip.com')

ip = r.text

ip = ip.rstrip()
obj = IPWhois(ip)
results = obj.lookup()
print "sensorIP="+str(ip)+", ASN="+str(results['asn'])+", ASN_Country="+str(results['asn_country_code'])+", description="+str(results['nets'][0]['description']) + ", network_name="+str(results['nets'][0]['name'])+", network_range="+str(results['nets'][0]['range'])
