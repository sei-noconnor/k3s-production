#!/bin/bash -e
# Change to the current directory
directory="$(dirname "${BASH_SOURCE[0]}")"
cd $directory
source $directory/scripts/utils
import_vars $directory/env
declare -a keys=( \
  TOKEN_SECRET \
  ADMIN_PASS \
  POSTGRES_PASS \
  CRUCIBLE_ADMIN_PASS \
  STACKSTORM_MONGO_PASS \
  STACKSTORM_MONGO_KEY \
  STACKSTORM_RABBITMQ_PASS \
  STACKSTORM_RABBITMQ_COOKIE \
  )
for key in  "${keys[@]}";
do
rando=$(gen_random 24)
  echo "Setting $key"
  sed -i -e "s/$key=.*/$key=$(gen_random 24)/" env
  sleep 1
done 
