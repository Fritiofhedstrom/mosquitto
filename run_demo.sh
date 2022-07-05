#!/bin/bash
set -e

[ ! -d mosquitto_plugin ] && git clone --depth 1 https://github.com/Fritiofhedstrom/mosquitto_plugin.git && git switch mosquitto_get_retained_test
cp include/mosquitto.h include/mosquitto_broker.h include/mosquitto_plugin.h mosquitto_plugin/
[ !-f "src/mosquitto" ] && make 
export CPATH=$CPATH:$PWD/mosquitto_plugin/
(cd mosquitto_plugin && git pull && cargo build --workspace)
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"$PWD/mosquitto_plugin/target/debug"
[ !-f "src/mosquitto" ] && make 
time xargs -P 2 -I {} sh -c 'eval "$1"' - {} <<'EOF'
src/mosquitto -c mosquitto_plugin/example-acl/mosquitto.conf
(sleep 1 && echo publishing!! && mosquitto_pub -t "bash/test" -m "HEJ/test123" -r -u "pass" -P "ssap" && mosquitto_pub -t "bash/test/two" -m "test123" -r -u "pass" -P "ssap")
EOF
