# Minecraft
A compilation of minecraft-related things.
Currently, this contains TWO DISTINCT USE-CASES.

===============================================================================================
Use Case 1: Running the server manually and using a window manager (tmux) to manage the server.
===============================================================================================
Use Case 2: Running the server through a container service.
===============================================================================================


===============================================================================================
--Scripts--
===============================================================================================
This repository contains two scripts, both of which are dependant on the [settings.cfg] file being populated properly. 
The first script, "setup-mc-server.sh", sets up the files required for a minecraft forge server.
The second script, "launch-mc-server.sh", launches the server using these files. It does so in a tmux session, called "minecraftServer".
===============================================================================================


===============================================================================================
--Settings.cfg--
===============================================================================================
This file should a few fields; some before runtime, and some after.
Before runtime, it should include...
	minecraft_release (The version of minecraft you wish to run the server on).
	forge_release (A choice between 'recommended' or 'latest' for the forge version).
	eula (a true/false for accepting the minecraft EULA).
	jvmargs (a space-delineated list of jvm arguments).   
===============================================================================================


===============================================================================================
How to use:
===============================================================================================
  1. Have a minecraft-compatible version of Java installed (preferably Java 8).
  2. Have Tmux installed.
  3. Place this repository in the directory you wish to have your minecraft server in. Make sure you have permissions within that directory that allow you to
      make and edit files within it.
  3. Specify your minecraft version within "settings.cfg".
  4. Specify any JVM arguments within the same file (RAM, buffer sizes, various runtime-related technical things).
  5. Run "setup-mc-server.sh".
  6. Add any supplementary files to the "minecraft-server" directory that was created. This includes addons, modpack files, etc. 
  7. Run "launch-mc-server.sh".
  8. Enjoy! If you encounter any issues, bring them to my attention and I will see what I can do to resolve that issue. If you can solve it in a reasonable way on your own, just submit a pull request.      
===============================================================================================


===============================================================================================
-----Use Case 2 (Container) -----
This use-case utilizes the scripts above and the settings.cfg file to stand up a minecraft server.
===============================================================================================
How to use:
	Step 0 (Pre-Reqs): 
		- Podman or Docker pull the container image from...
			(docker.io/nickmonk/minecraft-server:centos)
		- Ensure that you have Java 8 (1.8.0_292) installed on your system.
	Then...

	1. Create an empty directory on the host you wish to run the container on.
	2. Git clone this repository into the aforementioned empty directory.
	3. Create a subdirectory here, called 'minecraft-server'. This is the root of the minecraft server file hierarchy.
	4. Place 'settings.cfg' into 'minecraft-server', and populate the fields [minecraft-release, forge-release, and eula].
	5. Place any mods you wish to have inside of [minecraft-server/mods/]. Alternatively, you can place a pre-populated minecraft server file hierarchy here.
	6. Run 'podman-compose up' or 'docker-compose up' within the parent directory. Enjoy!
===============================================================================================
If any problems become clear on use-cases outside of my own, or you solve some egregious issues,
feel free to contact me or submit a pull request.
===============================================================================================
