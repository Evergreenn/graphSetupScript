#!/bin/bash

NORMAL="\\033[0;39m"
RED="\\033[1;31m"
BLUE="\\033[1;34m"

CONTAINER_ID=$2 

log() {
  echo -e "${BLUE} > ${NORMAL} $1"
}

error() {
  echo ""
  echo -e "$RED >>> ERROR - $NORMAL $1"
}

stopContainer(){

log "Stopping container: "

docker stop $CONTAINER_ID
[ $? != 0 ] && error "Cannot stop the container" && exit 100
}

startContainer(){

log "starting container: "

docker start $CONTAINER_ID
log "waiting the container"
i=0

while (( i++ < 10 )); do
	
	echo -n "."
	sleep 1
done

echo -e "\r"

[ $? != 0 ] && error "Cannot stop the container" && exit 100
}

build(){

stopContainer

log "deleting existing neo4j db"

rm -rf $HOME/neo4j3.3.1/data/databases/graph.db

startContainer

cd $HOME/Documents

find * -maxdepth 0 -name "*.csv" -print0 | xargs -0 -I {} docker cp {} $CONTAINER_ID:/var/lib/neo4j/import/ 

cd $HOME/PhpstormProjects/untitled/

docker cp Import.cypher $CONTAINER_ID:/var/lib/neo4j/import

dockerexec


[ $? != 0 ] && error "build failed" && exit 100
}

dockerexec(){

log "Build the database"
docker exec $CONTAINER_ID /bin/sh -c "cat import/Import.cypher | cypher-shell -u neo4j -proot --format verbose"

echo $?
wait
}

$*
exit
