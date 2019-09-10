#!/bin/bash
debug=no
perform_dump_on_every_attempt=no


# --------------------------------HELPER FUNCTIONS START--------------------
# helper function 1
say() {
	if [ "${debug}" = "yes" ]
	then
		echo "$@"
		echo
	fi
}
# helper function 2
ensure_create() {
	say "ensure_create() invoked ----------"
	# this function is to create directories or files if does not exist
	if [ ! -e $2 ]
	then
		# "file | dir does not exits"
		# running command to create
		# sudo $@
		$@
		say "$2 created"
	else
		# "file | dir exists"
		say "$2 exits"
	fi
}
#helper function 3
notify() {
	if [ "${print_verbose}" = "yes" ]
	then
		echo "$@"
		echo
	fi
}
# --------------------------------HELPER FUNCTIONS END--------------------


# SSH_USER_NAME=emkay
# REMOTE_IP=13.235.49.174
# REMOTE_DB_NAME=admissions_copy_april30

# LOCAL_DB_NAME=unit_test_db
# LOCAL_DB_USER=letseduvate_unittest
# LOCAL_DB_USER_PASS="${LOCAL_DB_USER}"

# PUBKEY_FILE="./pubkeys/pgmk_idrsa"

# variables of directories LOCAL
readonly HOME=~
readonly PGMK_HOME="${HOME}/.pgmk"
readonly CONFIG_FILE="${PGMK_HOME}/pgmk.config"

make_dir_vars() {

	# readonly HOME=/opt
	# readonly PGMK_HOME="${HOME}/pgmk"

	bin_dir="${PGMK_HOME}/bin"
	dumps_dir="${PGMK_HOME}/dumps"
	passkeys_dir="${PGMK_HOME}/passkeys"

	# variables of file names LOCAL
	exec_file_name="pgmk.sh"
	exec_file="${bin_dir}/${exec_file_name}"

	dump_file_name="${REMOTE_DB_NAME}_${REMOTE_IP}.dump"
	dump_file="${dumps_dir}/${dump_file_name}"

	dump_logs_file_name="dumplogs.txt"
	dump_logs_file="${dumps_dir}/${dump_logs_file_name}"

	postgres_pass_file_name="postgres_pass"
	postgres_pass_file="${passkeys_dir}/${postgres_pass_file_name}"

	ssh_pass_file_name="ssh_pass"
	ssh_pass_file="${passkeys_dir}/${ssh_pass_file_name}"


	# variables of dir and files REMOTE
	#	remote_HOME="/home/${SSH_USER_NAME}/.pgmk"
	remote_HOME="/opt/pgmk"
	remote_dump_file="${remote_HOME}/dumps/pgmk.dump"

}




# --------------------------sourcing pgmk.config START-------------------------------


source_config_file() {
	say "source_config_file invoked()---------"
	write_config() {
		say "source_config_file===> write_config invoked()---------"
		say "CONFIG_FILE=$CONFIG_FILE"
		cat <<min_EOF >$CONFIG_FILE
		SSH_USER_NAME="$SSH_USER_NAME"
		REMOTE_IP="$REMOTE_IP"
		REMOTE_DB_NAME="$REMOTE_DB_NAME"
		LOCAL_DB_NAME="$LOCAL_DB_NAME"
		LOCAL_DB_USER="$LOCAL_DB_USER"
		LOCAL_DB_USER_PASS="$LOCAL_DB_USER"

		perform_dump_on_every_attempt="${perform_dump_on_every_attempt}"
		# yes or no
min_EOF
	}

	# source ./pgmk.configd > check_config 2>&1
	# is_config_present=$(cat check_config | grep "pgmk.configd: No such file or directory" -ci)
	# if [ is_config_present = 0 ] 
	source $CONFIG_FILE
	if [ $? = 0 ] 
	then 
		say "Sourcing pgmk.config"
	else
		say "pgmk.config file doesn't exist"
		mkdir -p $PGMK_HOME
		write_config
		source $CONFIG_FILE
	fi

	## define an array ##
	arrayname=( SSH_USER_NAME REMOTE_IP REMOTE_DB_NAME LOCAL_DB_NAME LOCAL_DB_USER )

	## get item count using ${arrayname[@]} ##
	for m in "${arrayname[@]}"
	do
		if [ ${!m} ]
		then
			echo "=> $m=${!m}"
		else 
			read -p "Provide $m: " temp 
			export ${m}="${temp}"
			echo "=>  $m=${!m}"
			unset temp
			write_config
		fi
	done

	write_config
	# check if any vars entered empty strings
	for m in "${arrayname[@]}"
	do
		if [ ! ${!m} ] ; then echo "Please provide cofiguration variable: $m"; exit ; fi
	done
	# sourcing file finally
	source $CONFIG_FILE
}
# --------------------------sourcing pgmk.config END-------------------------------











# --------------------------write_full_config START-------------------------------
write_full_config() {
	say "write_full_config Invoked ()"
	cat <<write_EOF >$CONFIG_FILE
# ___________________PGMK ___________________

# Configuartions needed from user

	SSH_USER_NAME="$SSH_USER_NAME"
	REMOTE_IP="$REMOTE_IP"
	REMOTE_DB_NAME="$REMOTE_DB_NAME"
	LOCAL_DB_NAME="$LOCAL_DB_NAME"
	LOCAL_DB_USER="$LOCAL_DB_USER"
	LOCAL_DB_USER_PASS="$LOCAL_DB_USER"

	perform_dump_on_every_attempt="${perform_dump_on_every_attempt}"
	# perform dump database on every attempt of pgmk in remote
	# if cronjob is assigned to take dump in remote machine==>make variable as "no" if not "yes"



# Directories for user reference

	# HOME="$HOME"
	# PGMK_HOME="$PGMK_HOME"
	# dumps_dir="$dumps_dir"
	# passkeys_dir="$passkeys_dir"
	# exec_file_name="$exec_file_name"
	# exec_file="$exec_file"
	# dump_file_name="$dump_file_name"
	# dump_file="$dump_file"
	# dump_logs_file_name="$dump_logs_file_name"
	# dump_logs_file="$dump_logs_file"
	# postgres_pass_file_name="$postgres_pass_file_name"
	# postgres_pass_file="$postgres_pass_file"
	# ssh_pass_file_name="$ssh_pass_file_name"
	# ssh_pass_file="$ssh_pass_file"
	# remote_HOME="$remote_HOME"
	# remote_dump_file="$remote_dump_file"

# ___________________PGMK ___________________
write_EOF
}
# --------------------------write_full_config END-------------------------------






source_and_write_config() {
	source_config_file
	make_dir_vars
	write_full_config
}







# --------------------------------STEP 1 START--------------------
# function to chmod
chmod_file() {
	# sudo chmod $@
	chmod $@
	if [ $? -ne 0 ]; then echo "chmod $@ failed"; fi
}
# creation of filesystem hierarchy standard (fhs)
fhs() {
	say "fhs() invoked ----------"
	#mkdir

	# $HOME/pgmk
	ensure_create mkdir ${PGMK_HOME}
	# $HOME/pgmk/bin
	ensure_create mkdir ${bin_dir}
	# $HOME/pgmk/dumps
	ensure_create mkdir ${dumps_dir}
	# $HOME/pgmk/passkeys
	ensure_create mkdir ${passkeys_dir}

	# touch files
	ensure_create touch ${exec_file}
	# +x to .sh file
	chmod_file 777 ${exec_file}
	
	ensure_create touch ${dump_logs_file}
	# rw-rw-rw- to dumps log files
	chmod_file 666 "${dump_logs_file}"
	
	ensure_create touch ${dump_file}
	# rw-rw-rw- to dump file
	chmod_file 666 ${dump_file}
}
# --------------------------------STEP 1 END--------------------


# --------------------------------STEP 2 start--------------------
# append date command output to dumpslog file
append_dump_log() {
	say "append_dump_log() invoked ----------"
	if [ ! -e ${dump_logs_file} ]
	then
		# "dumps file does not exits"
		# running command to create
		touch ${dump_logs_file}
		say "touch ${dump_logs_file} created from append_dump_log()"
		chmod_file 666 "${dump_logs_file}"
	else
		say "${dump_logs_file} exists: message from from append_dump_log()"
		# "dump file exists"
	fi	
	
	date=$(date)
	# file_size=$(ls -l ${dump_file}  --block-size=M | awk '{print $5}')
	file_size=$(ls -l ${dump_file} | awk '{print $5}')
	log_report="${date} - ${file_size}"
	echo ${log_report} >> ${dump_logs_file}

}
perform_rsync() {
	say "perform_rsync() invoked ----------"
	rsync -avzP "${SSH_USER_NAME}@${REMOTE_IP}:${remote_dump_file}" "${dump_file}"
	
	# as a root user with its own id_rsa_key
	# sudo rsync -avzP -e "ssh -i ${PUBKEY_FILE}" "${SSH_USER_NAME}@${REMOTE_IP}:${remote_dump_file}" "${dump_file}"
	
	if [ $? -eq 0 ]
	then
		say "file: "${remote_dump_file}" copied to local: ${dump_file} successfully"
		append_dump_log
	else
		say "file: "${remote_dump_file}" rsync failed"
		# echo "rsync failed, calling make dump again with perform_dump_on_every_attempt=yes"
		# perform_dump_on_every_attempt=yes
		# make_dump
		exit 1
	fi
}
make_dump() {
	say "make_dump() invoked ----------"
	
	say "remote home: ${remote_HOME}"
	if [ "$perform_dump_on_every_attempt" = yes ]
	then
		# this step is being done by ansible---> ansiblerepo/playbooks/cronjobs/unittesting/unittesting_db_dump.yml
		# sudo mkdir -p ${remote_HOME} && sudo chown -R postgres:postgres ${remote_HOME} && sudo chmod -R 777 ${remote_HOME} 
		# ssh ${SSH_USER_NAME}@${REMOTE_IP} "sudo -u postgres -i pg_dump -Fc ${REMOTE_DB_NAME}>${remote_dump_file}"
		
		# as a root user with its own id_rsa_key
		#  include this --> -i ${PUBKEY_FILE}

		echo "Please wait, Performing dump export from PostgreSQL database ${REMOTE_DB_NAME} in remote machine using ssh ${SSH_USER_NAME}@${REMOTE_IP} "
		ssh ${SSH_USER_NAME}@${REMOTE_IP} "sudo mkdir -p ${remote_HOME}/dumps && sudo chown -R postgres:postgres ${remote_HOME} && sudo chmod -R 777 ${remote_HOME} && sudo chown -R postgres:postgres ${remote_HOME}/dumps && sudo chmod -R 777 ${remote_HOME}/dumps && sudo -u postgres -i pg_dump -Fc ${REMOTE_DB_NAME}>${remote_dump_file}" 
		if [ $? -eq 0 ]
		then
			say "Dumping succeeded"
			perform_rsync
		else
			echo "Dumping failed: check ur ssh connection ${SSH_USER_NAME}@${REMOTE_IP}, on success of this command, re-run pgmk"
			echo -e "failed command \n ssh ${SSH_USER_NAME}@${REMOTE_IP} sudo mkdir -p ${remote_HOME} &&sudo -u postgres -i pg_dump -Fc ${REMOTE_DB_NAME}>${remote_dump_file} "
			exit 1
		fi
	else
		say "skipping dump statement cause perform_dump_on_every_attempt = $perform_dump_on_every_attempt"
		perform_rsync
	fi
}
# --------------------------------STEP 2 END--------------------


# --------------------------------STEP 3 START--------------------
# STEP 3 variables for manipulation of operation
# local_DB_exists yes | no
# local_DB_USER_exists yes | no 
# core = no of cpu cores (example  quadcore then 4)
check_func() {
	say "check_func() Invoked --------------------------"
	check_db_exists
	check_db_user_exists
}
check_db_exists() {
	say "check_db_exists() Invoked --------------------------"
	# check local dbname exists in db list -- command \l
	temp1=$(sudo -u postgres -i psql -c '\l' | awk '{print $1}' | grep ${LOCAL_DB_NAME} -o -w -c)
	if [ ${temp1} -gt 0 ]
	then
		local_DB_exists=yes
		say "local_DB_exists= ${local_DB_exists}"
	else
		local_DB_exists=no
		say "local_DB_exists= ${local_DB_exists}"
	fi
}
check_db_user_exists() {
	say "check_db_user_exists() Invoked --------------------------"
	# check local dbuser exists in postgres psql  -- command \du
	temp2=$(sudo -u postgres -i psql -c '\du' | awk '{print $1}' | grep ${LOCAL_DB_USER} -o -w -c)
	if [ ${temp2} -gt 0 ]
	then
		local_DB_USER_exists=yes
		say "local_DB_USER_exists=${local_DB_USER_exists}... cmd==>sudo -u postgres -i psql -c '\du' | awk '{print $1}' | grep ${LOCAL_DB_USER} -o -w -c"
	else
		local_DB_USER_exists=no
		say "local_DB_USER_exists=${local_DB_USER_exists}... cmd==>sudo -u postgres -i psql -c '\du' | awk '{print $1}' | grep ${LOCAL_DB_USER} -o -w -c"
	fi
}

create_db() {
	say "create_db() invoked ---------"
	# check_func to update db and db user exists vars
	check_func

	if [ ${local_DB_exists} == no ]
	then
		sudo -u postgres -i createdb ${LOCAL_DB_NAME} -O ${LOCAL_DB_USER} > /dev/null 2>&1
		if [ $? -eq 0 ]
		then
			say "DB ${LOCAL_DB_NAME} Creation succeeded"
		else
			say "DB ${LOCAL_DB_NAME} Creation failed"
		fi
	else
		say "DB ${LOCAL_DB_NAME} Creation failed, cause db exist ${local_DB_exists}"
	fi
}
drop_db() {
	say "delete_db() invoked ---------"

	# check_func to update db and db user exists vars
	check_func

	sudo -u postgres -i dropdb ${LOCAL_DB_NAME} --if-exists > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
		say "DB ${LOCAL_DB_NAME} Deletion succeeded"
	else
		say "DB ${LOCAL_DB_NAME} Deletion failed"
	fi
}
create_user() {
	say "create_user() invoked -------"

	# check_func to update db and db user exists vars
	check_func

	if [ ${local_DB_USER_exists} == no ]
	then
		sudo -u postgres -i createuser ${LOCAL_DB_USER} --no-createdb  --superuser --no-createrole > /dev/null 2>&1
		if [ $? -eq 0 ]
		then
			say "user ${LOCAL_DB_USER} Creation succeeded"
			set_password_to_user
		else
			say "user ${LOCAL_DB_USER} Creation failed"
		fi
	else
		say "user ${LOCAL_DB_USER} Creation failed, cause user exists.. ${local_DB_USER_exists}"
	fi
}
set_password_to_user() {

	# check_func to update db and db user exists vars
	check_func
	if [ ${local_DB_USER_exists} == yes ]
	then
		sudo -u postgres -i psql -c "ALTER USER ${LOCAL_DB_USER} with password '${LOCAL_DB_USER_PASS}'" > /dev/null 2>&1
		if [ $? -eq 0 ]
		then
			say "user ${LOCAL_DB_USER} ALter password with ${LOCAL_DB_USER_PASS} succeeded"
		else
			say "user ${LOCAL_DB_USER} ALter password with ${LOCAL_DB_USER_PASS} failed"
		fi
	else
		say "user ${LOCAL_DB_USER} ALter password with ${LOCAL_DB_USER_PASS} failed, cause user exits -- ${local_DB_USER_exists}"
	fi
}
drop_user() {
	
	say "drop_user() invoked -------"

	# check_func to update db and db user exists vars
	check_func

	# before dropping user , need to delete databases mapped to the user
	drop_db

	sudo -u postgres -i dropuser ${LOCAL_DB_USER} > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
		say "user ${LOCAL_DB_USER} Deletion succeeded"
	else
		say "user ${LOCAL_DB_USER} Deletion failed, cause user exist -- ${local_DB_USER_exists}"
	fi
}
getcore() {
	say "getcore() Invoked ----------------------------"
	core=$(grep -c ^processor /proc/cpuinfo)
	say "Core ${core}"
}
load_db_init() {
	say "load_db_init() Invoked ----------------------------"
	# check_func to update db and db user exists vars
	check_func
	
	# for safe dropping db, user if  exists, inside drop user, there func call to drop db before dropuser to avoid errors
	drop_user

	# creating user, inside creat usr, a func call to set pasword
	create_user
	# creating db
	create_db

	# get number of cores to perform concurrent operations
	getcore

	#  loads data into empty db
	say "load_db_init() invoked ---------"
	echo "Please wait, Performing dump import to PostgreSQL database ${LOCAL_DB_NAME} (init)"
	sudo -u postgres -i pg_restore -j${core} -d ${LOCAL_DB_NAME} ${dump_file}
	# --verbose
}
load_db_main() {
	say "load_db_main() Invoked ----------------------------"
	# check_func to update db and db user exists vars
	check_func

	# get number of cores to perform concurrent operations
	getcore

	#  cleans the db 's existing data and load new data from latest dump
	say "load_db_main() invoked ---------"
	echo "Please wait, Performing dump import to PostgreSQL database ${LOCAL_DB_NAME}"
	sudo -u postgres -i pg_restore -j${core} -c -d ${LOCAL_DB_NAME} ${dump_file}
	# --verbose
}
perform_postgres_operations() {
	say "perform_postgres_operations() invoked ---------"
	
	# get number of cores to perform concurrent operations
	getcore
	
	# check_func to update db and db user exists vars
	check_func

	if [ ${local_DB_exists} == yes -a ${local_DB_USER_exists} == yes ] 
	then
		say "user exists ${local_DB_USER_exists}, db exists ${local_DB_exists} "
		load_db_main
	else 
		say "user exists ${local_DB_USER_exists}, db exists ${local_DB_exists} "

		load_db_init
	fi
}

# --------------------------------STEP 3 END--------------------
main() {
	say "main() invoked ----------"
	# --------------------------------STEP 0--------------------
		# source pgmk.config if available else write 
	source_and_write_config

	# --------------------------------STEP 1--------------------
	# fhs is a function to create ~/.pgmk/.....
		# 1. Creates folder structure as follows
			# ~/.pgmk/-bin 		--> -pgmk.sh
					# -dumps	-->	- <dbname_remoteIP>.dump
								# 	- dumplogs.txt
					# -passkeys --> - <file>.pub
								# 	- postgres
	fhs

	# --------------------------------STEP 2--------------------
	#make_dump performs
		# 1. dump file in remote through ssh connenction and saves it in ~/.pgmk/pgmk.dump
		# 2. rysnc remote file to local ~/.pgmk/dumps/<file>.dump
		# 3. records log in ~.pgmk/dumps/dumplogs.txt
	make_dump


	# --------------------------------STEP 3--------------------
	perform_postgres_operations
}
drop_db_setup() {
	source_and_write_config
	check_func
	drop_user
}
initialize_setup() {
	rm -rf ~/.pgmk
	fhs
	make_dump
	load_db_init
}

# -v, --verbose		:	Notifies operations performed
# --initialize		:	Initializes whole setup, creation of db, dbuser, dump files, logs etc..
usage() {
	cat 1>&2 <<usage_EOF
	
	pgmk 0.0.4

	USAGE:
		pgmk				:	Executes pgmk
		pgmk --dropdbsetup		:	Drops local db_user and database and exits
		pgmk --user			:	Change ssh user ( prompt ) and continues to execute pgmk
		pgmk --database			:	Change remote database to dump ( prompts ) and continues to execute pgmk
		pgmk --help			:	Prints help information and exits
		pgmk --version			:	Prints version information and exits
		pgmk --debug			:	Prints performed operations info and continues to execute pgmk
		pgmk --viewconfig		:	Prints pgmk configuration file and exits
	
usage_EOF
}

version() {
	cat 1>&2 <<version_EOF
pgmk-init 0.0.4 (Wed Jul 24 16:42:33 IST 2019)
version_EOF
}
invalid_arg() {
	cat 1>&2 <<invalid_EOF
Invalid arguments
--help to get help info
invalid_EOF
}
change_remote_db() {
	read -p "Enter existing remote database name: " db_name
	REMOTE_DB_NAME=$db_name
	perform_dump_on_every_attempt=yes
}
change_user() {
	echo -n "Enter ssh user name: "
	read user
	if [ ${user} ]
	then
		say "new shh user $user"
		SSH_USER_NAME=$user
		while true; do
			read -p "Do you wish to change remote database ? (yes/no) " yn
			case $yn in
				[Yy]* )
					change_remote_db
					break;;
				[Nn]* ) break;;
				* ) echo "Please answer yes or no.";;
			esac
		done
	fi

}
view_config() {
	cat $CONFIG_FILE
}
for arg in "$@"
do	
	case "$arg" in 
		--help)
			usage
			exit
			;;
		--version)
			version
			exit
			;;
		-v|--verbose)
			print_verbose=yes
			;;
		--debug)
			debug=yes
			;;
		--user)
			source_and_write_config
			change_user
			write_config
			;;
		--database)
			source_and_write_config
			change_remote_db
			write_config
			;;
		--initialize)
			time initialize_setup
			exit
			;;
		--dropdbsetup)
			drop_db_setup
			exit
			;;
		--viewconfig)
			view_config
			exit
			;;
		*)
			invalid_arg
			exit 1
			;;
	esac
done

time main

# TIPS
# 1.To hide the output of any command usually the stdout and stderr are redirected to /dev/null.
# 	command > /dev/null 2>&1
# 	Explanation:
# 	1.command > /dev/null: redirects the output of command(stdout) to /dev/null
# 	2.2>&1: redirects stderr to stdout, so errors (if any) also goes to /dev/null
