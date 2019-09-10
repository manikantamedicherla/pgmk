#!/bin/sh
echo "PROVIDE SSH USER NAME"
read USER
ssh $USER@13.235.49.174 "sudo -u postgres -i pg_dump -Fc admissions_copy_april30>/home/emkay/ssh_file_ut.dump"
if [ "$?" -eq 0 ] ; then
	echo "Dumping succeeded"
#	rsync -avz $USER@13.235.49.175:~/ssh_file_ut.dump ./ssh_file_ut.dum
	rsync -avz emkay@13.235.49.174:~/ssh_file_ut.dump ./ssh_file_ut.dump
	if [ "$?" -eq 0 ] ; then
		echo "file copied to local successfully"
	fi
fi
