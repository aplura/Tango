#!/bin/bash
#Universal Forwarder Install Only for Tango Honeypot
#Should be compatible with Ubuntu and Debian.


#Disclaimer. Continues for yes, quits for no.
while true; do
    read -p "DISCLAIMER. DO YOU AGREE? (yes/no)" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

########################################

#User input variables
#Splunk Indexer hostname/IP address from user
echo "Enter your Splunk Indexer.
Can be a hostname or an IP address. The default port is 9997/tcp"
read SPLUNK_INDEXER
echo ""

#Sensor hostname from user
echo "Enter Sensor hostname. This controls what name your kippo server will have
when reviewing its data in the Tango Splunk App. Use unique names.
Suggestion: "hp-{country code}-{city}-{number}" such as: hp-US-Las_Vegas-01"
read HOST_NAME
echo""

#Location of Kippo Logs 
echo "Enter the location of your kippo honeypot logs.
For example, /opt/kippo/log/ or /home/user/kippo/log/"
read KIPPO_LOG_LOCATION

########################################



# Logging setup. This is done to log all the output from commands executed in the script to a file. This provides us troubleshooting data if the script fails.
logfile=/var/log/tango_install.log
mkfifo ${logfile}.pipe
tee < ${logfile}.pipe $logfile &
exec &> ${logfile}.pipe
rm ${logfile}.pipe

########################################

#metasploit-like print statements. Status messages, error messages, good status returns. I added in a notification print for areas users should definitely pay attention to.

function print_status ()
{
    echo -e "\x1B[01;34m[*]\x1B[0m $1"
}

function print_good ()
{
    echo -e "\x1B[01;32m[*]\x1B[0m $1"
}

function print_error ()
{
    echo -e "\x1B[01;31m[*]\x1B[0m $1"
}

function print_notification ()
{
	echo -e "\x1B[01;33m[*]\x1B[0m $1"
}
########################################

#Script does a lot of error checking. Decided to insert an error check function. If a task performed returns a non zero status code, something very likely went wrong.

function error_check
{

if [ $? -eq 0 ]; then
	print_good "$1 successfully completed."
else
	print_error "$1 failed. Please check $logfile for more details."
exit 1
fi

}

########################################

#BEGIN MAIN#

########################################

# These Variables Need to be set! #

#SPLUNK_INDEXER: This is the box that is going to process your splunk logs. Can be a hostname or an IP address. The default port is 9997/tcp. #
#SPLUNK_INDEXER="splunkserver.yourdomain.com:9997"

#HOST_NAME: This controls what name your kippo server will have when reviewing its data in the Tango Splunk App. #
# Use unique names. Suggestion: "hp-{country code}-{city}-{number}" such as: hp-US-Las_Vegas-01 #
#HOST_NAME="hp-countrycode-city-01"

#KIPPO_LOG_LOCATION: What is the location of your kippo honeypot logs? #
#For most bang for the buck, you'll want to send splunk "kippolog.json logs. #
#Assuming you are running Michel Oosterhof's branch of kippo (https://github.com/micheloosterhof/kippo).. #
#You should be getting shiny JSON logs by default. If not find the following section in kippo.cfg: #
#[database_jsonlog3]
#logfile = log/kippolog.json#
#Verify that these lines are uncommented. The log file (as indicated above will be in the kippo/log/kippolog.json.* #
#Set KIPPO_LOG_LOCATION to the absolutely directory path of the directory containing your kippolog.json files 
#For example, /opt/kippo/log/ or /home/user/kippo/log/#
#KIPPO_LOG_LOCATION='/opt/kippo/log/'

########################################

# Set the directory we are initially executing the script in.
execdir=`pwd`

########################################

#We need root privs to run most of this, this is a quick check to ensure that we are root. If not, bail.

print_status "Checking for root privs.."
if [ $(whoami) != "root" ]; then
	print_error "This script must be ran with sudo or root privileges."
	exit 1
else
	print_good "We are root."
fi
	 
########################################	

#We check what architecture the system is and download the correct splunk Universal Forwarder for that CPU arch.

arch=`uname -m`

if [[ $arch == "x86_64" ]]; then
	INSTALL_FILE="splunkforwarder-6.1.6-249101-Linux-x86_64.tgz"
	print_notification "System is $arch. Downloading: $INSTALL_FILE to /opt.."
	wget -O /opt/splunkforwarder-6.1.6-249101-Linux-x86_64.tgz 'http://www.splunk.com/page/download_track?file=6.1.6/universalforwarder/linux/splunkforwarder-6.1.6-249101-Linux-x86_64.tgz&ac=&wget=true&name=wget&platform=Linux&architecture=x86_64&version=6.1.6&product=splunk&typed=release' &>> $logfile
	error_check 'Splunk Forwarder Download'
elif [[ $arch == "i686" ]]; then
	INSTALL_FILE="splunkforwarder-6.1.6-249101-Linux-i686.tgz"
	print_notification "System is $arch. Downloading: $INSTALL_FILE to /opt.."
	wget -O /opt/splunkforwarder-6.1.6-249101-Linux-i686.tgz 'http://www.splunk.com/page/download_track?file=6.1.6/universalforwarder/linux/splunkforwarder-6.1.6-249101-Linux-i686.tgz&ac=&wget=true&name=wget&platform=Linux&architecture=i686&version=6.1.6&product=splunk&typed=release' &>> $logfile
	error_check 'Splunk Forwarder Download'
else
	print_error "System arch is not x86_64 or i686. Tango Honeypot is not yet supported on other CPU architectures."
	exit 1
fi

########################################

# Based on the OS (Debian or Redhat based), use the OS package manger to download required packages

if [ -f /etc/debian_version ]; then
    apt-get -y update &>> $logfile
	print_notification "Installing required packages via apt-get.."
    apt-get -y install python-dev python-openssl python-pyasn1 authbind git python-pip libgnutls-dev libcurl4-gnutls-dev libssl-dev &>> $logfile
	error_check 'Apt Package Installation'
	
	print_notification "Installing required python packages via pip.."
    pip install pycurl service_identity ipwhois &>> $logfile
	error_check 'Python pip'
elif [ -f /etc/redhat-release ]; then
    yum -y update &>> $logfile
	print_notification "Installing required packages via yum.."
    yum -y install wget python-devel python-zope-interface unzip git gnutls-devel gcc gcc-c++ &>> $logfile
	error_check 'Yum Package Installation'
	
	print_notification "Installing required python packages via easy_install.."
	easy_install pycrypto pyasn1 &>> $logfile
	error_check 'Python easy_install'
else
    print_error "Unable to determine correct package manager to use. This script currently supports apt-based Operating Systems (Debian, Ubuntu, Kali) and yum-based Operating Systems (Redhat, CentOS, etc.) and relies on either /etc/redhat-release or /etc/debian_version being present to determine the correct package manager to use."
	exit 1
fi

########################################

# Adding splunk user for service to run as. Shell is set to /bin/false.

print_status "Checking for splunk user and group.."

getent passwd splunk &>> $logfile
if [ $? -eq 0 ]; then
	print_status "splunk user exists. Verifying group exists.."
	id -g splunk &>> $logfile
	if [ $? -eq 0 ]; then
		print_notification "splunk group exists."
	else
		print_notification "splunk group does not exist. Creating.."
		groupadd splunk &>> $logfile
		usermod -G splunk splunk &>> $logfile
		error_check 'Creation of Splunk group and Addition of Splunk user to group'
	fi
else
	print_status "Creating splunk user and group.."
	groupadd splunk &>> $logfile
	useradd -g splunk splunk -d /home/splunk -s /bin/false &>> $logfile
	error_check 'Splunk user and group creation'
	
fi

chown -R splunk:splunk /home/splunk &>> $logfile

########################################

# Installing Splunk Universal Forwarder and setting it to persist on reboot

print_notification "Installing Splunk Universal Forwarder.."
cd /opt
tar -xzf $INSTALL_FILE &>> $logfile
chown -R splunk:splunk splunkforwarder &>> $logfile
sudo -u splunk /opt/splunkforwarder/bin/splunk start --accept-license --answer-yes --auto-ports --no-prompt &>> $logfile
error_check 'Universal Forwarder Configuration'
/opt/splunkforwarder/bin/splunk enable boot-start -user splunk &>> $logfile
error_check 'Universal Forwarder Install' 

########################################

#Check to see if the user tried to execute uf_only outside of the Tango directory. Yell at them if they did. Grab tango_input from the Tango directory (if it's there), configure inputs.conf, start up the forwarder. We done here.

print_notification "Installing tango_input.."

if [ ! -d "$execdir/tango_input" ]; then
        print_error "Unable to find tango_input directory in $execdir. tango_input should be in the same directory as uf_only.sh. Please correct this and run the script again."
		exit 1
else
	cp -r "$execdir/tango_input" /opt/splunkforwarder/etc/apps &>> $logfile
fi

print_notification "Configuring /opt/splunkforwarder/etc/apps/tango_input/default/inputs.conf and outputs.conf.."

cd /opt/splunkforwarder/etc/apps/tango_input/default 
sed -i "s/test/$HOST_NAME/" inputs.conf &>> $logfile
sed -i "s,/opt/kippo/log/,${KIPPO_LOG_LOCATION}," inputs.conf &>> $logfile
sed -i "s/test/$SPLUNK_INDEXER/" outputs.conf &>> $logfile

chown -R splunk:splunk /opt/splunkforwarder &>> $logfile
/opt/splunkforwarder/bin/splunk restart &>> $logfile
error_check 'Tango_input installation'

print_notification "If the location of your kippo log files changes or the hostname/ip of the indexer changes, you will need to modify /opt/splunkfowarder/etc/apps/tango_input/default/inputs.conf and outputs.conf respectively."

print_good "Install Completed. The splunk forwarder should be reporting and sending data to your indexer. Log file is located at /var/log/tango_install.log"

exit 0
