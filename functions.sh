# This script contains the helper functions.
# Coding note: variables in "" are user supplied.

# Checks the required variables and sets the defaults
check (){
	if [ -z "$REMOTE_SERVER" ]  || [ -z "$SSHD_PORT" ] || [ -z "$SSH_USER" ] || [ -z "$SSH_IDENTITY" ] || [ -z "$REMOTE_VOLUME_PATH" ] || [ -z "$SECRET_FILE" ] || [ -z "$FILE_LIST"  ]; then
		return 1
	fi

	if [ -z "$LOCAL_MOUNTPOINT" ]; then
		LOCAL_MOUNTPOINT=$DEFAULT_LOCAL_MOUNTPOINT
	fi

	if [ -z "$BACKUP_FOLDER" ]; then
		BACKUP_FOLDER=$DEFAULT_BACKUP_FOLDER
	fi

	if [ -z "$LOCAL_SSH_MOUNTPOINT" ]; then
		LOCAL_SSH_MOUNTPOINT=$DEFAULT_LOCAL_SSH_MOUNTPOINT
	fi

	if [ -z "$BASEDIR" ]; then
		BASEDIR=$DEFAULT_BASEDIR
	fi

	return 0
}

# Decrypts and mounts the remote storage on the remote machine
decrypt(){

REMOTE_DIR=$(dirname "$REMOTE_VOLUME_PATH")
TC_VOLUME=$LOCAL_SSH_MOUNTPOINT/$(basename "$REMOTE_VOLUME_PATH")

sshfs "$SSH_USER"@"$REMOTE_SERVER":$REMOTE_DIR "$LOCAL_SSH_MOUNTPOINT" -C -p "$SSHD_PORT"  -o StrictHostKeyChecking=no -o allow_root
truecrypt --text --non-interactive --keyfiles="$SECRET_FILE" $TC_VOLUME $LOCAL_MOUNTPOINT
return $?
}

sync(){
echo "sync"

# fully qualify backup folder
BACKUP_FOLDER="$LOCAL_MOUNTPOINT"/"$BACKUP_FOLDER"

# attempt  to create backup directory if it doesn't exit
if [ ! -d "$BACKUP_FOLDER" ]; then
	mkdir "$BACKUP_FOLDER"
	if [ $? -ne 0 ]; then
		echo "Could not create backup directory"
		return 1
	fi
fi
rsync -avr --delete --files-from="$FILE_LIST" $BASEDIR $BACKUP_FOLDER
ret=$?

return $ret
}

lock(){
truecrypt --text --non-interactive -d $TC_VOLUME
fusermount -u "$LOCAL_SSH_MOUNTPOINT"
}


