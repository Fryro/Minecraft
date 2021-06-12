# After running this script, expect:
#	- Minecraft EULA created and in working directory, and prompted to accept.
#	- Minecraft Forge Downloaded and Installed in working directory.



# This function makes a server directory, in which this script operates.
make_script_directories() {
	if ! [ -e "minecraft_server" ]; then
		mkdir minecraft_server
	fi
	if ! [ -e "logs" ]; then
		mkdir logs
		touch logs/script_log.txt
	fi
	if ! [ -e minecraft_server/"installers" ]; then
		mkdir minecraft_server/installers
	fi
	
	# Logging
	echo "---------------" >> logs/script_log.txt
	echo "+++Begin Log+++" >> logs/script_log.txt
	echo "Checking/Making Directories [minecraft_server, logs, minecraft_server/installers]" >> logs/script_log.txt
}


# This function checks for the 'eula.txt' file. If it does not find it,
# it will fetch it from mojang's documentation. Then it will prompt the user
# to accept the EULA.
make_eula() {
	if ! [ -e "eula.txt" ]; then
		touch eula.txt
		
		# Logging
		echo "Created [eula.txt]" >> ../logs/script_log.txt
	fi

	if ! (grep -q 'eula=true' eula.txt); then
		read -p "Minecraft EULA: (https://account.mojang.com/documents/minecraft_eula). Do you accept the EULA? [y/n]: " eula_answer
		if (echo $eula_answer | grep -i -q 'y'); then
			echo "eula=true" > eula.txt
			echo "You have accepted the minecraft EULA."
		else
			echo "eula=false" > eula.txt
			echo "You have not accepted the minecraft EULA. You will be unable to launch the server until you do so."
		fi
	fi

	if ! (grep -q 'Minecraft EULA: (https://account.mojang.com/documents/minecraft_eula)' eula.txt); then
		echo "Minecraft EULA: (https://account.mojang.com/documents/minecraft_eula)" >> eula.txt
	fi
}

# This function checks the minecraft version, then goes and retrieves the Minecraft Forge installer for that version.
# I forgo the option to check for a java 8 installation, and instead this script will assume a proper version of Java 8 is installed.
get_forge() {
	if ! (grep -q "forge installed" ../settings.cfg); then
		
		# Logging
		echo "Forge not installed for indicated version of minecraft. Getting installer." >> ../logs/script_log.txt

		if (grep -q 'Minecraft Version= 1.7.10' ../settings.cfg); then
			if ! [ -e "forge-1.7.10-10.13.4.1614-1.7.10-installer.jar" ]; then
				echo "----++++ [Downloading Forge for 1.7.10] ++++----"
				wget https://maven.minecraftforge.net/net/minecraftforge/forge/1.7.10-10.13.4.1614-1.7.10/forge-1.7.10-10.13.4.1614-1.7.10-installer.jar
				# Logging
				echo "Forge downloaded for [1.7.10]" >> ../logs/script_log.txt

			fi	
		
			chmod +x "forge-1.7.10-10.13.4.1614-1.7.10-installer.jar"
			forge_file="forge-1.7.10-10.13.4.1614-1.7.10-installer.jar"

		elif (grep -q 'Minecraft Version= 1.12.2' ../settings.cfg); then
			if ! [ -e "forge-1.12.2-14.23.5.2855-installer.jar" ]; then
				echo "----++++ [Downloading Forge for 1.12.2] ++++----"
				wget https://maven.minecraftforge.net/net/minecraftforge/forge/1.12.2-14.23.5.2855/forge-1.12.2-14.23.5.2855-installer.jar
				# Logging
				echo "Forge Downloaded for [1.12.2]" >> ../logs/script_log.txt
			fi

			chmod +x "forge-1.12.2-14.23.5.2855-installer.jar"
			forge_file="forge-1.12.2-14.23.5.2855-installer.jar"

		fi
	fi
}

install_server() {
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
make_server_files() { 

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
cd minecraft_server
make_eula
get_forge
install_server
make_server_files
cd -
echo "All major actions done by this script are logged to [./logs/script_log.txt]"

# Logging
echo "Script has finished." >> logs/script_log.txt
echo "+++ END +++" >> logs/script_log.txt
