import simplejson
import urllib
import urllib2
url = "https://www.virustotal.com/vtapi/v2/file/report"
parameters = {"resource": "fb3a2b9fa8fce18c92a0523846a5caf15c0094bb4215ed5a1947a387f5a48365","apikey": "149a08a494a4db323460180a09312b2f34e529230496eccfa868c01dead5b709"}
data = urllib.urlencode(parameters)
req = urllib2.Request(url, data)
response = urllib2.urlopen(req)
json = response.read()
print json