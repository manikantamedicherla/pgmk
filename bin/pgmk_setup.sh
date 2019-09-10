#!/bin/bash
mkdir -p ~/.pgmk/bin/

sh_file=~/.pgmk/bin/pgmk
CONFIG_FILE=~/.pgmk/pgmk.config


if [ -f ./pgmk.sh ]
then
	file=$(cat ./pgmk.sh)
    touch $sh_file
    chmod 777 ${sh_file}
    cat > ${sh_file} <<EOF
$file
EOF
	# APPENDING ~/.pgmk/bin to PATH varible only if doesn't exist 

	is_pgmk_PATH_exists=$(grep "PATH=\$PATH:$HOME/.pgmk/bin" ~/.bashrc -c)
	if [ $is_pgmk_PATH_exists = 0 ]
	then
		echo "PATH=\$PATH:$HOME/.pgmk/bin" >> ~/.bashrc	
	fi
else
    echo "pgmk.sh file not found"
fi

write_default_config() {
	# REMOTE_DB_NAME="admissions_copy_april30"
	cat <<EOF >$CONFIG_FILE
# ___________________PGMK ___________________

	SSH_USER_NAME=""
	REMOTE_IP="13.127.234.211"
	REMOTE_DB_NAME="unit_test_db"
	LOCAL_DB_NAME="database_pgmk"
	LOCAL_DB_USER="letseduvate_pgmk"
	LOCAL_DB_USER_PASS="letseduvate_pgmk"

	perform_dump_on_every_attempt="yes"
	# perform dump database on every attempt of pgmk in remote
	# if cronjob is assigned to take dump in remote machine==>make variable as "no" if not "yes"

# ___________________PGMK ___________________

EOF

}

# Providing default configurations if ~/.pgmk/pgmk.config doesnt exists
if [ ! -f $CONFIG_FILE ]
then
	write_default_config
fi