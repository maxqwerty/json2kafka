# json2kafka
Simple tool to automate some routine Kafka scripts.

Created to:
- set ```--bootstrap-server``` only once
- replicate same topics in test enviroment
- easy repeate settings for multiple topics
- easy to edit any setting

Designed to use basic BASH commands to be usable on most systems.

# Usage

```json2kafka.sh <file.json> [</path/to/kafka/bin>]```

Default path to kafka scripts is ```/kafka/bin/```

See ```example.json``` for examples.

## Available commands:
- create topic with defined partitions, replacas and configs;
- modify topic config;
- remove topic config;
- delete topic.

# Description

Uses ```jq``` to parse input JSON-file.

Runs commands in the the defined order:
- create topics
- modify topics config
- remove topics config (reset to default in most cases)
- delete topics

To run in the other order - just use multiple files (may be changed and improved in the future).
