# After running this script, expect:
#	- Minecraft EULA created and in working directory, and prompted to accept.
#	- Minecraft Forge Downloaded and Installed in working directory.

MINECRAFT_RELEASE=""
FORGE_RELEASE=""
FORGE_PAGE="https://files.minecraftforge.net/net/minecraftforge/forge/index_"
LOGFILE="$(pwd)/script_log.txt"
SETTINGS_FILE="$(pwd)/settings.cfg"
FORGE_INSTALLER=""

# Logging functions
function debug() {
	if [ -n "$DEBUG" ]; then
		echo "$(date +'%F-%T %z') DEBUG: $*" | tee -a "${LOGFILE}" 2>&1
	fi
}

function info() {
	echo "$(date +'%F-%T %z') INFO: $*" | tee -a "${LOGFILE}"
}

function warning() {
	echo "$(date +'%F-%T %z') WARNING: $*" | tee -a "${LOGFILE}" 2>&1
}

function error() {
	echo "$(date +'%F-%T %z') ERROR: $*" | tee -a "${LOGFILE}" 2>&1
}
	
function get_setting() {
	setting="$(grep "^${1}=" "${SETTINGS_FILE}" | head -n 1 | cut -d= -f2)"
	echo "$setting"
}


# Find the recommended or latest forge versions for a given minecraft instance
function get_forge_version() {
	case "$1" in
	latest)
		version="latest"
		;;
	recommended)
		version="recommended"
		;;
	*)
		error "Only options to find forge version are latest and recommended"
		exit 1
		;;
	esac
	forge_version="$(curl -s "${FORGE_PAGE}${MINECRAFT_RELEASE}.html" | grep -A 1 "fa promo-$version" | tail -n 1 | cut -d- -f2 | egrep -o '[0-9.]+')"
	if [ -z "$forge_version" ]; then
		error "Unable to retrieve forge version, it must be specified in the config"
		exit 2
	fi
	echo "$forge_version"
}


# This function makes a server directory, in which this script operates.
function make_script_directories() {
	if ! [ -e "minecraft-server" ]; then
		mkdir minecraft-server
	fi
	if ! [ -e "minecraft-server/used-forge-files" ]; then
		mkdir minecraft-server/used-forge-files
	fi
	
	# Logging
	info "+++Begin Log+++"
	info "Checking/Making Directories [minecraft-server, minecraft-server/used-forge-files]"
}


# This function checks for the 'eula.txt' file. If it does not find it,
# it will fetch it from mojang's documentation. Then it will prompt the user
# to accept the EULA.
function make_eula() {
	cd minecraft-server
	
	if ! [ -e "eula.txt" ]; then
		touch eula.txt
		
		# Logging
		info "Created [eula.txt]"
	fi

	if ! (grep -q 'eula=true' eula.txt); then
		
		eula_state="get_setting eula"
		if ! ($eula_state); then
			error "You have not accepted the Minecraft Server EULA. Please read it and ensure 'eula=true' exists in 'settings.cfg'."
		else
			echo "eula=true" > eula.txt
			info "You have accepted the Minecraft Server EULA."
		fi

#		read -p "Minecraft EULA: (https://account.mojang.com/documents/minecraft_eula). Do you accept the EULA? [y/n]: " eula_answer
#		if (echo $eula_answer | grep -i -q 'y'); then
#			echo "eula=true" > eula.txt
#			info "You have accepted the minecraft EULA."
#		else
#			echo "eula=false" > eula.txt
#			info "You have not accepted the minecraft EULA. You will be unable to launch the server until you do so."
#		fi
	fi

	if ! (grep -q 'Minecraft EULA: (https://account.mojang.com/documents/minecraft_eula)' eula.txt); then
		echo "Minecraft EULA: (https://account.mojang.com/documents/minecraft_eula)" >> eula.txt
	fi

	cd -
}

function get_mc_release() {

	# Pull MC Release from settings files.	
	MINECRAFT_RELEASE="$(get_setting minecraft_release)"
	if [ -z "$MINECRAFT_RELEASE" ]; then
		error "No minecraft server version selected.  Set minecraft_release in $SETTINGS_FILE and retry"
		exit 1
	fi
	
	if echo "$MINECRAFT_RELEASE" | grep -q '^1\.[789]\.'; then
		RELEASE="Pre 1.10"
	else
		RELEASE="Post 1.10"	
	fi
}

# This function checks the minecraft version, then goes and retrieves the Minecraft Forge installer for that version.
# I forgo the option to check for a java 8 installation, and instead this script will assume a proper version of Java 8 is installed.
function get_forge() {

	# get the latest and recommended forge releases
	FORGE_INSTALLER="get_setting forge_installer"
	FORGE_RELEASE="$(get_forge_version $(get_setting forge_release))"
	if [ -z "$FORGE_RELEASE" ]; then
		error "You must specify 'forge_release' as 'latest / recommended' in 'settings.cfg'."
	fi
		#PS3="Which forge version should be used?:"
		#latest="$(get_forge_version latest)"
		#recommended="$(get_forge_version recommended)"
		#select forge in $latest $recommended; do
		#	info "forge version selected: $forge"
		#	FORGE_RELEASE="$forge"
		#	break
		#done
	#fi
	
	if [ "$RELEASE" = "Pre 1.10" ]; then
		append_to_url="-$MINECRAFT_RELEASE"
	else
		append_to_url=""
	fi

	forge_to_use="${MINECRAFT_RELEASE}-${FORGE_RELEASE}${append_to_url}"
	if ! [ -e "forge-${forge_to_use}-installer.jar" ]; then
		info "Downloading Forge version $FORGE_RELEASE for $MINECRAFT_RELEASE"
		if curl -OL "https://maven.minecraftforge.net/net/minecraftforge/forge/${forge_to_use}/forge-${forge_to_use}-installer.jar"; then
			info "Forge Downloaded"
			FORGE_INSTALLER="forge-${forge_to_use}-installer.jar"
			echo "forge_installer=$(FORGE_INSTALLER)" >> settings.cfg
		else
			error "Forge was unable to download, check curl error and re-run"
			exit 3
		fi
	fi
}

function install_server() {		
	cd minecraft-server
	
	# This line uses the forge installer. 
	if java -jar ../$FORGE_INSTALLER --installServer; then
		info "Server Installed"
	else
		error "Java install failed. Cannot Continue."
		exit 4
	fi

	# This line moves ForgeInstallerLogs to the 'used' directory.
	mv ./forge*installer*.log used-forge-files/

	# This moves the 'used' forge installers away, to remove clutter.
	mv ../*forge*installer* used-forge-files/	
	
	# Logging
	info "Forge was installed. Installed Server for indicated Minecraft and Forge Releases"

	cd -
}

# This function checks for server files that are neccessary, but aren't 'eula.txt'. It will create+populate them if they do not exist.
function make_server_files() { 
	cd minecraft-server
	
	# Checks for a 'server.properties' file.
	if ! [ -e "server.properties" ]; then
		{
			echo "view-distance=8"
			echo "allow-flight=true"
			echo "level-type=default"
			echo "snooper-enabled=false"
			echo "max-tick-time=90000"
			echo "motd='I am very cool'"
		}>>server.properties

		# Logging
		info "Created 'server.properties' and populated with defaults."
	fi

	cd -
}



# This is the 'driver code'. It looks for various conditions, and runs the above functions depending on the state.

make_script_directories

make_eula
make_server_files
get_mc_release

if ! [ -e "settings.cfg" ]; then
	error "No 'settings.cfg' file found, cannot continue."
else
	if [ "$RELEASE" = "Pre 1.10" ]; then
		if ! ( ls "minecraft-server" | (grep -q "forge.*universal.*.jar")); then
			if ! [ -e "*forge*installer*.jar" ]; then
				get_forge
			fi
			install_server
		fi
	elif [ "$RELEASE" = "Post 1.10" ]; then
		if ! ( ls "minecraft-server" | (grep -q "forge.*.jar")); then
			if ! [ -e "*forge*installer*.jar" ]; then
				get_forge
			fi
			install_server
		fi
	fi
fi

if ! [ "$1" == "container" ]; then
	echo "-------------------------------------------------"
	echo "------ The server was set up successfully! ------"
	echo "------ Next steps:                         ------"
	echo "------   1. Place ALL modpack files within ------"
	echo "------       'minecraft-server' directory  ------"
	echo "------                                     ------"
	echo "------   2. Run script 'launch-mc-server'  ------"
	echo "-------------------------------------------------"

else
	cd minecraft-server
	SERVER_JAR=$(ls | grep "forge.*universal.*")
	echo "running java command : java $(get_setting jvmargs) -jar $SERVER_JAR nogui"

	java $(get_setting jvmargs) -jar $SERVER_JAR nogui
fi
