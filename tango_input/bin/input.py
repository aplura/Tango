import subprocess
import sys
import os

output = subprocess.check_output('curl -s icanhazip.com', shell=True)
print "sensorIP="+output
