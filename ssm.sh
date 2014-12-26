#!/bin/bash

UNIX_USER="starbound"
STEAM_USER="aiprojectx"

HOME_DIR="/home/$UNIX_USER"

SERVER_FOLDER="$HOME_DIR/server"
SERVER_BACKUPS="$HOME_DIR/backups"
STEAMCMD_FOLDER="$HOME_DIR/SteamCMD"

LOG_DIR="$SERVER_FOLDER/ssm-logs"

usage() {
	echo -e "Usage: ssm [OPTIONS]"
	echo
	echo -e "=== OPTIONS ===="
	echo -e " -s start\tStarts the server"
	#echo -e " -s stop\tStops the server"
	#echo -e " -s status\tOutputs server status"
	echo -e " -b\t\tBacks up server to: $SERVER_BACKUPS"
	echo -e " -u\t\tUpdates the server to the newest version"
}

echoScreenInfo() {
	echo "- SCREEN DAEMON INFO -"
	echo "Server state saved in screen daemon of: $UNIX_USER"
	echo "Check screen sessions using: screen -ls"
	echo "Attach to screen daemon: screen -r"
	echo "Detach from screen daemon by pressing: Ctrl + a then d"
}

update() {
	$STEAMCMD_FOLDER/steamcmd.sh +login $STEAM_USER +app_update 211820 +force_install_dir $SERVER_FOLDER +quit
}

echoBackupComplete() {
	echo ""
	echo "####### Server Backup Complete #######"
	echo "Backups are being stored in:"
	echo "  ${SERVER_BACKUPS}"
	echo "######################################"
	echo ""
}

backup() {
	TIMESTAMP=$(date +%Y%m%d_%H%M%S)
	tar -czvf server-${TIMESTAMP}.tar.gz ${SERVER_FOLDER}
	mkdir -p ${SERVER_BACKUPS}
	mv server-${TIMESTAMP}.tar.gz ${SERVER_BACKUPS}
	echoBackupComplete
}

echoStartHeader() {
	echo ""
	echo "####### Starbound server starting #######"
	echo "Logs are being saved in:"
	echo "  $LOG_DIR"
	echo "#########################################"
	echo ""
}

stateStart() {
	TIMESTAMP=$(date +%Y%m%d_%H%M%S)
	echoStartHeader
	mkdir -p $LOG_DIR
	screen -dmS $UNIX_USER $SERVER_FOLDER/linux32/starbound_server | tee $LOG_DIR/$TIMESTAMP.txt
	echoScreenInfo
}

state() {
	VAR_s=$1
	if [[ $VAR_s == 'start' ]]; then
		stateStart
	elif [[ $VAR_s == 'stop' ]]; then
		stateStop
	elif [[ $VAR_s == 'status' ]]; then
		stateStatus
	else
		usage
	fi
}

validateUser() {
	# USER = $1
	# CMD = $2
	if [[ $(whoami) != $1 ]]; then
		echo "Must run: $2"
		echo " as user: $1"
		echo " you are currently: $(whoami)"
		exit
	fi
}

BOOL_s=0
VAR_s=''
BOOL_b=0
BOOL_u=0
OPTSTRING="hbus:"
while getopts $OPTSTRING opt; do
	case $opt in
		h)	usage
			exit
			;;
		s)	VAR_s=${OPTARG}
			BOOL_s=1
			;;
		u)	BOOL_u=1
			;;
		b)	BOOL_b=1
			;;
		\?)	usage
			exit
			;;
	esac
done

shift $((OPTIND-1))

if [[ $BOOL_u -eq 0 ]] && [[ $BOOL_s -eq 1 ]] && [[ $BOOL_b -eq 0 ]]; then
	validateUser "root" "-s"
	state ${VAR_s}
elif [[ $BOOL_u -eq 1 ]] && [[ $BOOL_s -eq 0 ]] && [[ $BOOL_b -eq 0 ]]; then
	validateUser "starbound" "-u"
	update
elif [[ $BOOL_u -eq 0 ]] && [[ $BOOL_s -eq 0 ]] && [[ $BOOL_b -eq 1 ]]; then
	backup
else
	usage
fi