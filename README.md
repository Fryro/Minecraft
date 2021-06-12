# Minecraft
A compilation of minecraft-related things I've created.

This repository contains a script and a settings.cfg file. 

--Script--
The script will log it's actions to [./logs/script_log.txt]. It will only log things it has performed, so only the first run should log much of anything.

--Settings.cfg--
This file should contain only the line "Minecraft Version= 1.7.10" or "Minecraft Version= 1.12.2". I may decide to add more support in the future,
  be that for other options or versions. The script will add another line to this as a 'state check'; whether or not Forge is currently installed. This is
  horrible and a better solution will be implemented.
  
  
How to use:
  1. Have a minecraft-compatible version of Java installed (preferably Java 8).
  2. Place this script in the directory you wish to have your minecraft server in. Make sure you have permissions within that directory that allow you to
      make and edit files within it.
  3. Specify your minecraft version within "settings.cfg".
  4. Run the script.
  5. If needed, close the server, add modpack files to the subdirectory 'minecraft_server', and run again.
  6. Enjoy! If you encounter any issues, bring them to my attention and I will see what I can do to resolve that issue. If you can solve it in a reasonable way 
      on your own, just submit a pull request.
      
Eventually, this script will be updated, and required to be placed into ~/bin. This will also require you to place it wihin your ~/.bashrc. Stay tuned!
