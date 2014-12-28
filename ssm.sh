#!/bin/bash

UNIX_USER="starbound"
STEAM_USER="aiprojectx"

HOME_DIR="/home/$UNIX_USER"

SERVER_BASE="$HOME_DIR/Steam/steamapps/common/Starbound/linux32"
SERVER_BACKUPS="$HOME_DIR/ssm-backups"
SERVER_LOGS="$SERVER_BASE/ssm-logs"

STEAMCMD_FOLDER="$HOME_DIR/SteamCMD"

BLACK='\033[0;30m'
DARK_GRAY='\033[1;30m'
BLUE='\033[0;34m'
LIGHT_BLUE='\033[1;34m'
GREEN='\033[0;32m'
LIGHT_GREEN='\033[1;32m'
CYAN='\033[0;36m'
LIGHT_CYAN='\033[1;36m'
RED='\033[0;31m'
LIGHT_RED='\033[1;31m'
PURPLE='\033[0;35m'
LIGHT_PURPLE='\033[1;35m'
ORANGE='\033[0;33m'
YELLOW='\033[1;33m'
LIGHT_GRAY='\033[0;37m'
WHITE='\033[1;37m'
NO_COLOR='\033[0m'

# Params: (<func> $1 $2 $3 ...etc)
# $1 = Color to make text
# $2 = Text output
# Description:
# Echoes the text given in the given color
echoColor() {
    # Include color termination at the EOL
    COLORED_STRING="$1$2${NO_COLOR}"
    echo -e $COLORED_STRING
}

usage() {
	echo -e "Usage: ssm [OPTIONS]"
	echo
	echoColor $ORANGE "=== OPTIONS ===="
	echo -e " -s start\tStarts the server"
	#echo -e " -s stop\tStops the server"
	#echo -e " -s status\tOutputs server status"
	echo -e " -b\t\tBacks up server to: $SERVER_BACKUPS"
	echo -e " -u\t\tUpdates the server to the newest version"
	echo
	echoColor $ORANGE "=== COLORS ==="
	echo -e "Each color represents a different program log level."
	echo -e "Please see below for the color to log level associations."
	echoColor $GREEN "Green - Success"
	echoColor $CYAN "Cyan - Info"
	echoColor $RED "Red - Error"
}

echoScreenInfo() {
	echoColor $CYAN "- SCREEN DAEMON INFO -"
	echoColor $CYAN "Server state saved in screen daemon of: $UNIX_USER"
	echoColor $CYAN "Check screen sessions using: screen -ls"
	echoColor $CYAN "Attach to screen daemon: screen -r"
	echoColor $CYAN "Detach from screen daemon by pressing: Ctrl + a then d"
}

echoScreenError() {
	echoColor $RED "ERROR: Could not bind a screen to tty, please try to manually enter a screen"
}

echoUpdateComplete() {
	echoColor $GREEN "####### Update process complete #######"
}

update() {
	$STEAMCMD_FOLDER/steamcmd.sh +login $STEAM_USER +app_update 211820 +force_install_dir $SERVER_BASE +quit
	echoUpdateComplete
}

# $1 = Archive location for backup
echoBackupInfo() {
	echo ""
	echoColor $CYAN "Backing up $SERVER_BASE"
	echoColor $CYAN " to archive: $1"
	echo ""
}

echoBackupComplete() {
	echo ""
	echoColor $GREEN "####### Server Backup Complete #######"
	echoColor $GREEN "Backups are being stored in:"
	echoColor $GREEN "  ${SERVER_BACKUPS}"
	echoColor $GREEN "######################################"
	echo ""
}

backup() {
	TIMESTAMP=$(date +%Y%m%d_%H%M%S)
	BACKUP_LOCATION="$SERVER_BACKUPS/${TIMESTAMP}.tar.gz"
	echoBackupInfo $BACKUP_LOCATION
	mkdir -p ${SERVER_BACKUPS}
	tar zvcf $BACKUP_LOCATION $SERVER_BASE
	echoBackupComplete
}

# $1 = Logging location
echoStartHeader() {
	echo ""
	echoColor $CYAN "####### Starbound server starting #######"
	echoColor $CYAN "Logs are being saved to:"
	echoColor $CYAN "  $1"
	echoColor $CYAN "#########################################"
	echo ""
}

stateStart() {
	TIMESTAMP=$(date +%Y%m%d_%H%M%S)
	SERVER_EXECUTABLE="$SERVER_BASE/starbound_server"
	LOG_LOCATION="$SERVER_LOGS/$TIMESTAMP.log"
	echoStartHeader $LOG_LOCATION
	mkdir -p $SERVER_LOGS
	screen -dmS $UNIX_USER $SERVER_EXECUTABLE | tee $LOG_LOCATION
	checkScreenError
}

checkScreenError() {
	ERROR_COUNT=$(screen -ls | grep -c No)
	if [[ $ERROR_COUNT -ge 1 ]]; then
		echoScreenError
	else
		echoScreenInfo
	fi
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
		echoColor $RED "Error: Invalid user"
		echoColor $CYAN "Must run: $2"
		echoColor $CYAN " as user: $1"
		echoColor $CYAN " and you are: $(whoami)"
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
