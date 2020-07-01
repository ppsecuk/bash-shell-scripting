#!/bin/bash
# update.sh: Updating Kafka Connect BigQuery.
# Written by Pavel Psecuk.

DIR="/Users/`whoami`/Documents/kafka-update/"
SUB_DIR="kafka-update-`date +"%F-%H-%M-%S"`"
SRC_DIR=$DIR$SUB_DIR/kafka-connect-bigquery
TOTAL_STEPS=4

echo "Starting the script."

###############################################################################

echo "[STEP 1/$TOTAL_STEPS] - Started"

# Checks if directory already exists and creates it if needed
if [ -d "$DIR" ]; then
  echo "Directory '${DIR}' already exists, skipping..."
  cd ${DIR}
  mkdir ${SUB_DIR} && cd $_
  echo "Successfully created directory '`pwd`'"
else
  echo "Directory '${DIR}' doesn't exist, creating..."
  mkdir ${DIR} && cd ${DIR}
  mkdir ${SUB_DIR} && cd $_
  echo "Successfully created directory '`pwd`'"
fi

echo "[STEP 1/$TOTAL_STEPS] - Completed"

###############################################################################

echo "[STEP 2/$TOTAL_STEPS] - Started"

# Clones kafka connect bigquery repo from BWT Bitbucket
git clone git@bitbucket.org:breakwatertechnology/kafka-connect-bigquery.git && cd kafka-connect-bigquery

# Adds new remote "upstream" considered as source
git remote add upstream https://github.com/wepay/kafka-connect-bigquery

# Adds new remote "origin" considered as destination
git remote add origin https://bitbucket.org/breakwatertechnology/kafka-connect-bigquery

# Makes sure we are using master branch
git checkout master

# Pulls missing files from source (upstream) to local repo
git pull upstream master

echo "[STEP 2/$TOTAL_STEPS] - Completed"

###############################################################################

echo "[STEP 3/$TOTAL_STEPS] - Started"

# Implementing variables for old and new version numbers
OLD_VERSION=`cd $SRC_DIR && awk '/kcbq-confluent-/ {print}' Dockerfile | sed 's/^.*kcbq-confluent-\([0-9.]*\).*$/\1/'`
LATEST_VERSION=`cd $SRC_DIR && awk '/version/ {print}' gradle.properties | sed 's/^.*version=\([0-9.]*\).*$/\1/'`

# Replaces old version with latest version in Dockerfile. It also backups old file.
sed -i '.bak' "s/$OLD_VERSION/$LATEST_VERSION./g" Dockerfile
echo "Successfully replaced old version $OLD_VERSION with new version $LATEST_VERSION in Dockerfile."

echo "[STEP 3/$TOTAL_STEPS] - Completed"

###############################################################################

echo "[STEP 4/$TOTAL_STEPS] - Started"

# Adding all modified files to git
git add .

# Commits changes
git commit -m "Updating Kafka Connect BigQuery to version $LATEST_VERSION"

# Pushes changes to BWT Bitbucket
git push origin
echo "Successfully pushed all modified files to BWT Bitbucket."

echo "[STEP 4/$TOTAL_STEPS] - Completed"

###############################################################################

echo "Script successfully executed. Exiting..."
exit 0
