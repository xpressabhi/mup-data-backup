# MongoDB Data Backup deployed with Mup
These commands run well if meteor app deployed with mup tool. Mup creates docker for mongodb hence taking backup becomes easy with these commands.

# Backup
Take backup of running app data from docker then copy to local folder out of docker.

docker exec -it mongodb mongodump --archive=/root/mongodump.gz --gzip

docker cp mongodb:/root/mongodump.gz mongodump_$(date +%Y-%m-%d_%H-%M-%S).gz

# Copy backup to server
Move data to another server/local machine or a backup location

scp /path/to/dumpfile root@serverip:/path/to/backup


# Delete old data from meteor deployment
Get into mongo console running in docker then drop current database before getting new data.

docker exec -it mongodb mongo appName

db.runCommand( { dropDatabase: 1 } )

# Restore data to meteor docker
docker cp /path/to/dumpfile mongodb:/root/mongodump.gz

docker exec -it mongodb mongorestore --archive=/root/mongodump.gz --gzip

# Drop target database and restore in one line
docker exec -it mongodb mongorestore --drop --archive=/root/mongodump.gz --gzip

Drops only collections present in dump.


