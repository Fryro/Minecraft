# Minecraft
A compilation of minecraft-related things.

This repository contains two scripts and a settings.cfg file. 

--Scripts--
The first script, "setup-mc-server.sh", sets up the files required for a minecraft forge server.

The second script, "launch-mc-server.sh", launches the server using these files. It does so in a tmux session, called "minecraftServer".

--Settings.cfg--
This file should contain two lines; one for the minecraft release, and another for the JVM arguments. I may decide to add more support in the future,
  be that for other options or versions. 
  
How to use:
  1. Have a minecraft-compatible version of Java installed (preferably Java 8).
  2. Have Tmux installed.
  3. Place this repository in the directory you wish to have your minecraft server in. Make sure you have permissions within that directory that allow you to
      make and edit files within it.
  3. Specify your minecraft version within "settings.cfg".
  4. Specify any JVM arguments within the same file (RAM, buffer sizes, various runtime-related technical things).
  5. Run "setup-mc-server.sh".
  6. Add any supplementary files to the "minecraft_server" directory that was created. This includes addons, modpack files, etc. 
  7. Run "launch-mc-server.sh".
  8. Enjoy! If you encounter any issues, bring them to my attention and I will see what I can do to resolve that issue. If you can solve it in a reasonable way 
      on your own, just submit a pull request.
      
Eventually, this script will be updated, and required to be placed into ~/bin. This will also require you to place it wihin your ~/.bashrc. Stay tuned!
