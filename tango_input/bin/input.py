import pycurl
from StringIO import StringIO
from ipwhois import IPWhois

buffer = StringIO()
c = pycurl.Curl()
c.setopt(c.URL, 'http://icanhazip.com')
c.setopt(c.WRITEDATA, buffer)
c.perform()
c.close()

body= buffer.getvalue()
ip = body.rstrip()
obj = IPWhois(ip)
results = obj.lookup()
print "sensorIP="+str(ip)+", ASN="+str(results['asn'])+", ASN_Country="+str(results['asn_country_code'])+", description="+str(results['nets'][0]['description']) + ", network_name="+str(results['nets'][0]['name'])+", network_range="+str(results['nets'][0]['range'])
