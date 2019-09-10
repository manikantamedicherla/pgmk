while [ "$#" -gt "0" ]
do
  echo "START \$1 is $1"
  shift
  if [ "$1" == "-c" ]
  then
	# echo 'd shift'
	shift
  fi
  echo "END \$1 is $1"
done   
