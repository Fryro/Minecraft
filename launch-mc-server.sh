#!/bin/bash

SETTINGS_FILE="../settings.cfg"

function get_setting() {
	setting="$(grep "^${1}=" "${SETTINGS_FILE}" | head -n 1 | cut -d= -f2-)"
	echo "$setting"
}

function java_line() {
	java $(get_setting jvmargs) -jar "minecraft_server.*.jar nogui" 
}

cd minecraft_server

# tmux new-session -d -s "minecraftServer" 'java -jar minecraft_server.1.12.2.jar nogui'
# tmux new-session -d -s "minecraftServer" java_line
#java -jar $(ls | grep "minecraft_server.*.") nogui
SERVER_JAR=$(ls | grep "forge.*universal.*")
tmux new-session -d -s "minecraftServer" "java $(get_setting jvmargs) -jar $SERVER_JAR nogui"
cd -
