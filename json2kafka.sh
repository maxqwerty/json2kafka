#!/bin/bash -e

# Kafka topic manipulation via json-script

# USAGE:
# ./kafka-json.sh <JSON_PATH> [<KAFKA_BIN_PATH>](default: '/kafka/bin/')

# commands - yellow; errors - red
Yellow='\033[0;33m'
Red='\033[0;31m'
NoColor='\033[0m'


function parse_create() {
  count=`jq '.create | length' $script`

  for ((i=0; i<$count; i++)); do
    name=`jq -r '.create['$i'].name' $script`
    partitions=`jq -c '.create['$i'].partitions // 1' $script`
    perlicas=`jq -c '.create['$i'].perlicas // 1' $script`
    config=`jq -c '.create['$i'].configs' $script`
    if [ "$config" != "null" ]; then
      configs_count=`echo  $config | jq '. | keys | length'`
      config_string=""
      for ((j=0; j<$configs_count; j++)); do
	key=`echo  $config | jq -r '. | keys['$j']'`
	value=`echo  $config | jq -r ".\"$key\""`
	config_string="${config_string} --config $key=$value"
      done
      command="$kafka_path/kafka-topics.sh --bootstrap-server $server --create --topic $name --partitions $partitions --replication-factor $perlicas $config_string"
      echo -e "${Yellow}$command${NoColor}\n"
      eval $command
      echo
    else
      command="$kafka_path/kafka-topics.sh --bootstrap-server $server --create --topic $name --partitions $partitions --replication-factor $perlicas"
      echo -e "${Yellow}$command${NoColor}\n"
      eval $command
      echo
    fi
  done
}

function parse_edit_config() {
  count=`jq '.edit_config | length' $script`

  for ((i=0; i<$count; i++)); do
    name=`jq -r '.edit_config['$i'].name' $script`
    config=`jq -c '.edit_config['$i'].configs' $script`
    if [ "$config" != "null" ]; then
      configs_count=`echo  $config | jq '. | keys | length'`
      for ((j=0; j<$configs_count; j++)); do
	key=`echo  $config | jq -r '. | keys['$j']'`
	value=`echo  $config | jq -r ".\"$key\""`
	config_string="--add-config $key=$value"
      command="$kafka_path/kafka-configs.sh --bootstrap-server $server --alter --entity-type topics --entity-name $name --alter $config_string"
      echo -e "${Yellow}$command${NoColor}\n"
      eval $command
      done
    else
      echo -e "${Red}Topic $name has no config to add/change${NoColor}\n"
    fi
  done
}

function parse_remove_config() {
  count=`jq '.remove_config | length' $script`

  for ((i=0; i<$count; i++)); do
    name=`jq -r '.remove_config['$i'].name' $script`
    config=`jq -c '.remove_config['$i'].configs' $script`
    if [ "$config" != "null" ]; then
      configs_count=`echo  $config | jq '. | length'`
      for ((j=0; j<$configs_count; j++)); do
	conig_name=`echo  $config | jq -r '.['$j']'`
	config_string="--delete-config $conig_name"
      command="$kafka_path/kafka-configs.sh --bootstrap-server $server --alter --entity-type topics --entity-name $name --alter $config_string"
      echo -e "${Yellow}$command${NoColor} \n"
      eval $command
      done
    else
      echo "${Red}Topic $name has no config to remove${NoColor}\n"
    fi
  done
}

function parse_delete() {
  server=`jq -r '.server' $script`
  count=`jq '.delete | length' $script`

  for ((i=0; i<$count; i++)); do
    name=`jq -r '.delete['$i']' $script`
    command="$kafka_path/kafka-topics.sh --bootstrap-server $server --delete --topic $name"
    echo -e "${Yellow}$command${NoColor}\n"
    eval $command
  done
}


script=$1
if [ -n "$2" ]; then
  kafka_path="$2"
else
  kafka_path="/kafka/bin/"
fi
server=`jq -r '.server' $script`

parse_create
parse_edit_config
parse_remove_config
parse_delete
