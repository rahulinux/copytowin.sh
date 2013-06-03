#!/bin/bash
# Author  : Rahul Patil
# Date    : Tue Apr  3 15:30:00 IST 2012
# Purpose : Copy logs to windows share ( from Ubuntu server)

# Change/Update following Details
WIN_PC_IP="IP_OF_WINDOWS/logbkp"
WIN_USER="remoteuser"
WIN_PASSWORD="password"
RSYNC=$(which rsync)
DESTPATH="/windows-share"
LOGFILE="/var/log/copy.log"

# check samba installed or not if not then install
if [ ! -x /usr/bin/smbclient ]; then
  echo "smb-client package not installed"
	echo "installing smb-client packge.."
	sleep 2s
	aptitude install samba-client -y
fi

# check mount
if [ ! -d $DESTPATH ]; then
	mkdir $DESTPATH
fi

# check winshre mounted or not
if mount | grep "$WIN_PC_IP" 1>/dev/null; then
	echo "Windowsshare OK"
else
	mount -o username=$WIN_USER,password=$WIN_PASSWORD -t cifs //$WIN_PC_IP $DESTPATH
	[[ $? == 0 ]] && :  ||  (echo "Network Connecvity issue or windows share issue" ; exit 1)

fi


# Insert LOG PATH in 'single qoat' as follow
# SOURCEPATH=('/opt/safesquid/ccil/logs/access/' '/opt/safesquid/ccil/logs/extended/' '/opt/safesquid/admin/logs/extended/'
SOURCEPATH=( '/opt/safesquid/logs/extended/gzip/' '/opt/safesquid/logs/extended/gzip/' '/opt/safesquid/logs/extended/gzip/' '/opt/safesquid/logs/extended/gzip/')
{
echo -e '\n\n' 
echo "Coping Compresslogs" 
for f in  ${!SOURCEPATH[@]}; do

	$RSYNC -av ${SOURCEPATH[$f]} $DESTPATH
done
echo "Completed at: $( date +%d-%b-%y-%T)"| tee -a  $LOGFILE
} | tee -a $LOGFILE
