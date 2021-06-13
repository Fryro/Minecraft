# After running this script, expect:
#	- Minecraft EULA created and in working directory, and prompted to accept.
#	- Minecraft Forge Downloaded and Installed in working directory.

MINECRAFT_RELEASE=""
FORGE_RELEASE=""
FORGE_PAGE="https://files.minecraftforge.net/net/minecraftforge/forge/index_"
LOGFILE="script_log.txt"
SETTINGS_FILE="settings.cfg"
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
	if ! [ -e "minecraft_server" ]; then
		mkdir minecraft_server
	fi
	if ! [ -e minecraft_server/"installers" ]; then
		mkdir minecraft_server/installers
	fi
	
	# Logging
	info "+++Begin Log+++"
	info "Checking/Making Directories [minecraft_server, logs, minecraft_server/installers]"
}


# This function checks for the 'eula.txt' file. If it does not find it,
# it will fetch it from mojang's documentation. Then it will prompt the user
# to accept the EULA.
function make_eula() {
	if ! [ -e "eula.txt" ]; then
		touch eula.txt
		
		# Logging
		info "Created [eula.txt]"
	fi

	if ! (grep -q 'eula=true' eula.txt); then
		read -p "Minecraft EULA: (https://account.mojang.com/documents/minecraft_eula). Do you accept the EULA? [y/n]: " eula_answer
		if (echo $eula_answer | grep -i -q 'y'); then
			echo "eula=true" > eula.txt
			info "You have accepted the minecraft EULA."
		else
			echo "eula=false" > eula.txt
			info "You have not accepted the minecraft EULA. You will be unable to launch the server until you do so."
		fi
	fi

	if ! (grep -q 'Minecraft EULA: (https://account.mojang.com/documents/minecraft_eula)' eula.txt); then
		echo "Minecraft EULA: (https://account.mojang.com/documents/minecraft_eula)" >> eula.txt
	fi
}

# This function checks the minecraft version, then goes and retrieves the Minecraft Forge installer for that version.
# I forgo the option to check for a java 8 installation, and instead this script will assume a proper version of Java 8 is installed.
function get_forge() {
	MINECRAFT_RELEASE="$(get_setting minecraft_release)"
	if [ -z "$MINECRAFT_RELEASE" ]; then
		error "No minecraft server version selected.  Set minecraft_release in $SETTINGS_FILE and retry"
		exit 1
	fi

	# get the latest and recommended forge releases
	FORGE_RELEASE="$(get_setting forge_release)"
	if [ -z "$FORGE_RELEASE" ]; then
		PS3="Which forge version should be used?:"
		latest="$(get_forge_version latest)"
		recommended="$(get_forge_version recommended)"
		select forge in $latest $recommended; do
			info "forge version selected: $forge"
			FORGE_RELEASE="$forge"
			break
		done
	fi

	if echo "$MINECRAFT_RELEASE" | grep -q '^1\.[789]\.'; then
		append_to_url="-$MINECRAFT_RELEASE"
	else
		append_to_url=""
	fi

	forge_to_use="${MINECRAFT_RELEASE}-${FORGE_RELEASE}${append_to_url}"
	if ! [ -e "forge-${forge_to_use}-installer.jar" ]; then
		info "Downloading Forge version $FORGE_RELEASE for $MINECRAFT_RELEASE"
		if curl -OL "https://maven.minecraftforge.net/net/minecraftforge/forge/${forge_to_use}/forge-${forge_to_use}-installer.jar"; then
			info "Forge Downloaded"
			FORGE_INSTALLER="forge-${forge_to_user}-installer.jar"
		else
			error "Forge was unable to download, check curl error and re-run"
			exit 3
		fi
	fi
}

function install_server() {
	if ! (grep -q "forge installed" ../settings.cfg); then
		
		# This line uses the forge installer. 
		java -jar $forge_file --installServer
		echo "forge installed" >> ../settings.cfg
	
		# This line moves ForgeInstallerLogs to the Logs directory. The installer is left such that the program will not install forge again.
		mv forge*installer*log* ../logs
	
		# This moves the 'used' forge installers away, to remove clutter.
		mv forge*installer* installers/	

		# Logging
		echo "Forge was not installed. Installed Forge Server for indicated Minecraft Version" >> ../logs/script_log.txt
	fi
}

# This function checks for server files that are neccessary, but aren't 'eula.txt'. It will create+populate them if they do not exist.
function make_server_files() { 

	# Checks for a 'server.properties' file.
	if ! [ -e server.properties ]; then
		{
			echo "view-distance=8"
			echo "allow-flight=true"
			echo "level-type=default"
			echo "snooper-enabled=false"
			echo "max-tick-time=90000"
			echo "motd='I am very cool'"
		}>>server.properties

		# Logging
		echo "Created 'server.properties' and populated with defaults." >> ../logs/script_log.txt
	fi	
}



# This is the 'driver code'. It runs all the above functions, in the order they are defined.
make_script_directories
make_eula
get_forge
#install_server
#make_server_files
