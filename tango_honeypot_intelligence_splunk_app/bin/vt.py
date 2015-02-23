import requests
import json
import sys

try:
	sha = sys.argv[1]
	requests.packages.urllib3.disable_warnings()
	url = "https://www.virustotal.com/vtapi/v2/file/report"
	params = {
    		"resource": sha,
    		"apikey": "<enter your API key here"
   	 }
	r = requests.get(url, params=params, verify=False)
	j = json.loads(r.text)
	print "scan_date, shasum, vendors, signatures"
	print j['scan_date']+",",j['sha256']+",",j['positives'],",",

	for i in j['scans']:
		if j['scans'][i]['result'] == None:
			pass		
		else:
			print j['scans'][i]['result'] + "|",

except:
	pass
