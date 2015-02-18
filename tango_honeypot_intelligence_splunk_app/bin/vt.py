import sys
import json
import requests

requests.packages.urllib3.disable_warnings()
sha = sys.argv[1]
url = "https://www.virustotal.com/vtapi/v2/file/report"
params = {
"resource": sha, 
"apikey": "149a08a494a4db323460180a09312b2f34e529230496eccfa868c01dead5b709"
}

r = requests.get(url, params=params, verify=False)
j = json.loads(r.text)
print "positives, scan_date, md5"
print str(j['positives']) + ", " + str(j['scan_date']) + ", " + str(j['md5'])
 
#print "positives=" + str(j['positives'])+", "+"scan_date="+str(j['scan_date']) +", " + "md5=" + str(j['md5']),

#for i in j['scans']:
#	if j['scans'][i]['result'] == None:
#		pass
#	else:
#		print ", sig=" + str(j['scans'][i]['result']),
