import pycurl
from StringIO import StringIO

buffer = StringIO()
c = pycurl.Curl()
c.setopt(c.URL, 'http://icanhazip.com')
c.setopt(c.WRITEDATA, buffer)
c.perform()
c.close()

body= buffer.getvalue()
print "sensorIP="+(body)
