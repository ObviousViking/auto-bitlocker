# auto-bitlocker
Script that will quickly auto apply bitlocker to a drive/removable storage



╔═══════════════════════════════════════════════════════════════════════════════════════════════╗
║                                                                                               ║
║                                     AutoBitlocker                                             ║
║                                       Version 1                                               ║
║                                                                                               ║
║                              Script to Auto-Bitlocker Drives                                  ║
║                                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════════════════════╝


*******How to Install*******

Right click the AutoBitlocker-Installer.ps1 and Run with Powershell. 
Follow the menu options, option 1 will install, and all should be good.
There might be a big red error at the top of the Powershell window, this can be ignored. I think its just a warning due to group policy but the install script should run regardless.
If the window appears then immediately disappears. Copy the 'AutoBitlocker' folder to the desktop and run it.


*******How to Uninstall*******

Right click the AutoBitlocker-Installer.ps1 and Run with Powershell. 
Follow the menu options, option 2 will uninstall, and all should be good.
There might be a big red error at the top of the Powershell window, this can be ignored. I think its just a warning due to group policy but the install script should run regardless.
If the window appears then immediately disappears. Copy the 'AutoBitlocker' folder to the desktop and run it as above

*******How to use*******

Once installed you just need to right click the USB drive in Windows and select 'AutoBitlocker' from the context menu.

The script will then perform the following steps;
	- Format to NTFS (Quick)
	- Enable Bitlocker
	- Set Bitlocker to use a password and recvoery key
	- Encrypt the USB Fully. (i.e not just the used space)
	- Save recovery key to user desktop

A progress bar will be displayed and the password used will be displayed at the end of the script in green and placed in your clipboard upon script completion.

*******Password*******

The password is randomly generated using the below char string;

abcdefghijkmnopqrstuvwxyzABCDEFGHIJKLMNPQRSTUVWXYZ234567890!#$%*@

The script will select a number between 14 and 18 each time it is run which will be the length of the password and select that number of random characters from the string.
It will then scramble that string again before converting it to a secure string for use as a password
