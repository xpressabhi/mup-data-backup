#!/bin/bash
#
# Meteor Database Management Script
#
# Author : Yanick Rochon <yanick.rochon@gmail.com>
# Last Modified : 2017-12-26
#
SERVER_USER={user name}
SERVER_ADDR={host name}
APP_NAME={app name}

SSH_PATH=$SERVER_USER@$SERVER_ADDR

backup() {
  BACKUP_PATH=$1 || "."
  BACKUP_FILE="mongodump_$(date +%Y-%m-%d_%H-%M).gz"
  TEMP_ARCHIVE_DOCKER="/root/mongodump.gz"
  TEMP_ARCHIVE="~/$BACKUP_FILE"

  printf "Backup database to $BACKUP_PATH/$BACKUP_FILE..."
  mkdir -p $BACKUP_PATH > /dev/null
  ssh -o LogLevel=QUIET -t $SSH_PATH "sudo docker exec -it mongodb mongodump --archive=$TEMP_ARCHIVE_DOCKER --gzip --quiet && sudo docker cp mongodb:$TEMP_ARCHIVE_DOCKER $TEMP_ARCHIVE" > /dev/null
  scp $SSH_PATH:$TEMP_ARCHIVE $BACKUP_PATH > /dev/null
  ssh -o LogLevel=QUIET -t $SSH_PATH "rm -f $TEMP_ARCHIVE" > /dev/null
  printf " Done!\n"
}


restore() {
  BACKUP_PATH=$1
  BACKUP_FILE=$(basename $1)
  TEMP_ARCHIVE="~/$BACKUP_FILE"
  TEMP_ARCHIVE_DOCKER="/root/mongodump.gz"

  # TODO : test if $1 is an existing file

  printf "Restoring database from $BACKUP_FILE..."
  scp $BACKUP_PATH $SSH_PATH:$TEMP_ARCHIVE > /dev/null
  ssh -o LogLevel=QUIET -t $SSH_PATH "sudo docker cp $TEMP_ARCHIVE mongodb:$TEMP_ARCHIVE_DOCKER && sudo docker exec -it mongodb mongorestore --drop --archive=$TEMP_ARCHIVE_DOCKER --gzip --quiet && rm -f $TEMP_ARCHIVE" > /dev/null
  printf " Done!\n"
}


console() {
  printf "Opening DB management console...\n"
  ssh -o LogLevel=QUIET -t $SSH_PATH "sudo docker exec -it mongodb mongo $APP_NAME"
}


showHelp() {
  printf "usage: managedb.sh [command]\n"
  printf "\n"
  printf "Commands:\n"
  printf "   backup [path]    backup the server into a local directory.\n"
  printf "                    The archive will be created inside the specified\n"
  printf "                    directory, with the name mongodump_{date}.gz\n"
  printf "   restore [path]   restore a local backup archive to the server.\n"
  printf "                    The archive should be a .gz file\n"
  printf "   console          open the mongo console.\n"
  printf "\n"
}


case $1 in
  backup)
    backup $2
	;;
  restore)
    restore $2
  ;;
  console)
    console
  ;;
  *)
    showHelp
  ;;
esac
