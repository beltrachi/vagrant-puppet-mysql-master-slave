#!/bin/bash
# To make the slave follow the master correctly, you have to tell
# the slave where to read (LOG_FILE) and from which point(POSITION).
# This is what this script does.
#
# This script has to be runned from the phisical host and after vagrant up.
DB=$1

if [ -z "$DB" ]; then
  echo "Parameter database name required: $0 database_name"
  exit 1;
fi

# Configuration
MASTER_HOST="192.168.30.100"
MASTER_CONN=" -u root -h $MASTER_HOST "
SLAVE_CONN=" -u root -h 192.168.30.101 "
MYSQL='mysql'

# Drop the database on both sides
SQL=" DROP DATABASE $DB "
$MYSQL $MASTER_CONN -e "$SQL"
$MYSQL $SLAVE_CONN -e "$SQL"

# Create database on both sides
SQL=" CREATE DATABASE $DB "
$MYSQL $MASTER_CONN -e "$SQL"
$MYSQL $SLAVE_CONN -e "$SQL"

# Init Master
SQL="SHOW MASTER STATUS"
DATA=$($MYSQL $MASTER_CONN -N -B -e "$SQL")
MASTER_LOG_FILE=$(echo "$DATA" | cut -f1)
POSITION=$(echo "$DATA" | cut -f2)
echo "FILE is $MASTER_LOG_FILE -- position is $POSITION"

# Init slave
SQL="STOP SLAVE; CHANGE MASTER TO MASTER_HOST='$MASTER_HOST',MASTER_USER='repl', MASTER_PASSWORD='repl', MASTER_LOG_FILE='$MASTER_LOG_FILE', MASTER_LOG_POS=  $POSITION;"
$MYSQL $SLAVE_CONN -e "$SQL"
SQL="START SLAVE;"
$MYSQL $SLAVE_CONN -e "$SQL"

echo "============ SLAVE STATUS ============"
SQL="SHOW SLAVE STATUS;"
$MYSQL $SLAVE_CONN -e "$SQL"
