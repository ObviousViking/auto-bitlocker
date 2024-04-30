#=====================================================================================
# Gets the drive letter and checks for admin rights. If admin rights needed it
# stores the drive letter, recalls the script as admin then loads in the drive letter
#=====================================================================================

# Checks for Admin rights and if not present flags the script to be recalled
param([switch]$Elevated)
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

# Gets drive letter from the right click menu
[string]$driveletter = $args[2] 
$driveletter = $driveletter.trim("'"," ",":","\") 

# Based on test above. If not run with admin rights, drive letter stored in file and script recalled with admin rights
if ((Test-Admin) -eq $false)  {
    if ($elevated) {
        # tried to elevate, did not work, aborting
        $driveletter | Out-File -FilePath 'C:\USEFUL_TOOLS\Auto-Bitlocker\Files\_ExternalVariables\SystemDefined\driverletter.txt'
        sleep 1
    } else {
        $driveletter | Out-File -FilePath 'C:\USEFUL_TOOLS\Auto-Bitlocker\Files\_ExternalVariables\SystemDefined\driverletter.txt'
        sleep 1
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}
# Clears the powershell window to remove any warning messages about elevation
clear-host

# Loads drive letter from external variable file
$driveletter = Get-Content -Path 'C:\USEFUL_TOOLS\Auto-Bitlocker\Files\_ExternalVariables\SystemDefined\driverletter.txt'
# Gets the label for the USB in order to check if licence dongle
$label = Get-Volume $driveletter | select -ExpandProperty FileSystemLabel

# Sets script location so it knows where to look for files
$scriptpath= $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
Set-Location -Path "$dir"

#===================================================================
# Displays script header with title/info/version
#===================================================================

Write-Host @("
╔═══════════════════════════════════════════════════════════════════════════════════════════════╗
║                                                                                               ║
║                                        AutoBitlocker                                          ║
║                                          Version 1.2                                          ║
║                                    Last Update: 05/09/2022                                    ║
║                                                                                               ║
║                                Script to Auto-Bitlocker Drives                                ║
║                                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════════════════════╝

")

#===================================================================
# Checks is script run against C or D drive
#===================================================================
if($driveletter -eq "C" -or $driveletter -eq "D")
{
    Write-Host "Script selected to run on C or D drive.`nThis action is not allowed, please review selected target.`n`n"
}
Elseif($label -eq "IEFV4" -or $label -eq "OXYGEN")
{
    Write-Host "Script selected to run on what appears to be a license dongle.`nThis action is not allowed, please review selected target.`n`n"
}
Else # The runs the rest of the script
{
#===================================================================
# Gets current system time
#===================================================================


# Gets start time of script - used for progress bar
$startTime = (Get-Date)


#========================== 
# Setting USB name
#========================== 


# Volume label(name) for the USB stick
$thisVolumeLabel = "Repository"


#======================================================================
# Functions to generate Random Password and convert to usable password
#======================================================================


# Gets random characters from the submitted string below
function Get-RandomCharacters($length, $characters) {
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
    $private:ofs=""
    return [String]$characters[$random]
}

# Scrambles the output of the above returned string of charaters
function Scramble-String([string]$inputString){     
    $characterArray = $inputString.ToCharArray()   
    $scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length     
    $outputString = -join $scrambledStringArray
    return $outputString 
}

# Sets a random password length each time between (and including) min/max
$length = Get-Random -Minimum 14 -Maximum 19
# Passes the charters string to the Get-RandomCharacters function
$password = Get-RandomCharacters -length $length -characters 'abcdefghijkmnopqrstuvwxyzABCDEFGHIJKLMNPQRSTUVWXYZ234567890!#$%*@'
# Passes the returned random characters to the Scramble-String function
$password = Scramble-String $password
# Converts the scrambled string into a secure string to be used as a password
$pass = ConvertTo-SecureString $password -AsPlainText -Force


#========================== 
# Start USB encryption
#========================== 


# Formats the drive(quick) and assigns the file system and volume name
Write-Host "Formatting $driveletter..."
Format-Volume -DriveLetter $driveletter -FileSystem NTFS -NewFileSystemLabel $thisVolumeLabel -Force

#============================================================== 
# Starts encrypting the drive. Enables bitlocker and assigns 
# both password and recovery key protectors. Saves the 
# recovery key file to the users desktop.
#==============================================================

Write-Host "Bitlocking $driveletter...`n"
Enable-BitLocker -MountPoint $driveletter -EncryptionMethod XtsAes256 -Password $pass -PasswordProtector -UsedSpaceOnly #Remove/Add the # symbol before -UsedSpaceOnly to only encrypt only
Add-BitLockerKeyProtector -MountPoint $driveletter -RecoveryPasswordProtector
(Get-BitLockerVolume -MountPoint $driveletter).KeyProtector > $env:USERPROFILE\Desktop\BitLockerRecoveryKey.txt

# Displays a progress bar for the encryption task with an increasing timer
$progress = 0 # used in Write-Progress calls below
while ((Get-BitLockerVolume -MountPoint $driveletter).EncryptionPercentage -lt 100){
	$progress = (Get-BitLockerVolume -MountPoint $driveletter).EncryptionPercentage
	$now = (Get-Date)
	$duration = (New-TimeSpan -Start $startTime -end $now).TotalMinutes.ToString("#.#")
	Write-Progress -Activity "Encrypting" -Status "Drive $driveletter Duration $duration minutes" -PercentComplete $progress
	sleep 0.005
}

# Complete the progress bar
Write-Progress -Activity "Encrypting" -Completed

# Make partition inactive for newer versions of Windows
Set-Partition -DriveLetter $driveletter -IsActive $false

# Displays completion message to the user
Get-BitlockerVolume -MountPoint $driveletter | Format-List
	
# Gets end time of script and displays total time
Write-Host "Script took, $duration Minutes to complete..."

# Displays the password to the user
Write-Host @("
The password for the USB is:

$password                    

") -ForegroundColor Green

# Adds the password too the clipboard for easy pasting
Set-Clipboard -value $password
Write-Host "Password also copied to the clipboard. Please paste it to the correct location."
Write-Host "`nThe recovery key is saved to the desktop should you need it"

# Waits for user to end the script
Read-Host -Prompt "`nScript complete, press ENTER to quit..."

}# Closes the IF loop for checking drive letter


######################################################################################################################################################################################################################################################################################################################################################################################
######################################################################################################################################################################################################################################################################################################################################################################################
######################################################################################################################################################################################################################################################################################################################################################################################
