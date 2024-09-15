#!/bin/bash

# SET TIMEZONE
TZ="${TZ:=UTC}"
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# SCRIPT TO GENERATE CRON
SCHEDULE_FILE="schedule.yml"

output=$(yq ".output" $SCHEDULE_FILE)
jobs=$(yq -o=j -I=0 '.jobs[]' $SCHEDULE_FILE)

function _service_id() {
  docker ps -q -f name=$1 | head -n1
}

cat <(crontab -l) <(echo "============= BEGIN AUTOMATIC TASKS GENERATED =============") | crontab -

while IFS=\= read job; do
  name=$(echo "$job" | yq '.name')
  every=$(echo "$job" | yq '.every' | sed "s/_/ /g")
  command=$(echo "$job" | yq '.command')
  services=$(echo "$job" | yq -o=j -I=0 '.services[]')
  

  for service in $services; do
    log_path="$output/$(echo $service | sed "s/\"//g").log"
    cat <(crontab -l) <(echo "$every docker exec \$(docker ps -q -f name=$service | head -n1) $command >> $log_path 2>&1") | crontab -
  done
done <<EOF
  $jobs
EOF

cat <(crontab -l) <(echo "============= END AUTOMATIC TASKS GENERATED =============") | crontab -

exec "${@}"
