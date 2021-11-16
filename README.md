# IP-Game
 A game about IP addresses and servers written in autoIT.

# About the game

 The game is currently in development and it is based off Uplink (a game by Introversion).
 You will play as a server operator who will try and take control of more and more servers by force.
 Along the way you will face a number of challenges based on real world scenarios.

# How the game works (at the moment)

Start off with 1 100 MB/s server. Every server has a security rating that governs how long it takes to crack the admin password. 
Some servers will have firewall protection and this will require an active DDOS attack to bypass. 
Some servers will have SSH certificates that will need to be found on other servers.
Every server cracked will add to the total bandwidth. Bandwidth is used to DDOS.
Money is earned by taking down servers (deleting servers) or by hosting applications. Applications will take bandwidth and will generate money every 60 second of real life time - Note every GUI will need to check GUI_MSG & _updateTick (the money tick counter)
Some servers will have traces that will start when being hacked (updated in real time via the _updateTick function) if the trace is completed before the server is cracked you will be disconnected and if you do not "clear your connection" in seconds minis the hacked servers bandwidth you will lose the game.

# Virus (false positive)

This program is written in a language called AutoIT and compiled with the public compiler. Because of this the program will more likely be marked as a virus because other people in the past have made viruses with the compiler. 
If you do not trust the program, please download the .au3 file and read  and run it for yourself :) 
