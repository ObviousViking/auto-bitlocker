#------------------------------------------------------------------------------------------------
# Displays a looping menu with options for the user.
#------------------------------------------------------------------------------------------------

function Show-Menu {
    param (
        [string]$Title = 'AutoBitlocker Installer'
    )
    Clear-Host
    Write-Host @("
╔═══════════════════════════════════════════════════════════════════════════════════════════════╗
║                                                                                               ║
║                            JJR TOOLS - AutoBitlocker Installer                                ║
║                                       Version 1                                               ║
║                                  Last Update: 30/08/2022                                      ║
║                                                                                               ║
║                          Script to Install/Remove AutoBitlocker                               ║
║                                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════════════════════╣
║                                                                                               ║
║                                  $Title                                      ║
║                                                                                               ║
║                                  Press '1' for INSTALL.                                       ║
║                                                                                               ║
║                                  Press '2' for REMOVE.                                        ║
║                                                                                               ║
║                                  Press 'Q' to QUIT.                                           ║
║                                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════════════════════╝
")
}


#------------------------------------------------------------------------------------------------
# Gets the choice from the user and then performs required actions
#------------------------------------------------------------------------------------------------
$scriptpath= $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
Set-Location -Path "$dir"

do
 {
    Show-Menu
    # Gets option from the user
    $selection = Read-Host "Please make a selection"
    switch ($selection)
    # Option 1
    {'1'{
    "`nYou chose option #1 - AutoBitlocker will now install."
    Start-Sleep -s 2
    Write-Host "`nCreating local folder..."
    Start-Sleep -s 2
    # Creates the script folder in the root of C:
    New-Item -Path "C:\" -Name "_JJR-TOOLS" -ItemType "directory" -force
    Start-Sleep -s 2
    Write-Host "`nLocal folder created."
    Start-Sleep -s 2
    Write-Host "`nCopying required files..."
    Start-Sleep -s 2
    # Copies the script and reg files to the above folder
    Copy-Item -Path .\ -Destination "C:\_JJR-TOOLS\" -Force -Recurse
    Start-Sleep -s 2
    Write-Host "`nFile copy complete."
    Start-Sleep -s 2
    Write-Host "`nAdding registry key..."
    Start-Sleep -s 2
    # Adds the registry key that has been copied. This will enable the right click option to the local machine
    regedit /s 'C:\_JJR-TOOLS\Auto-Bitlocker\Files\Add AutoBitlocker.reg'
    Start-Sleep -s 2
    Write-Host "`nRegistry key added."
    Start-Sleep -s 2
    # Lets user know the script has finished running. Will loop back for them to quit
    Write-Host "`n`nInstall complete."
    Start-Sleep -s 2

    # Option 2
    }'2'{
    "`nYou chose option #2 - AutoBitlocker will now uninstall."
    Start-Sleep -s 2
    Write-Host "`nRemoving registry key..."
    Start-Sleep -s 2
    # Removes the registry key that was copied locally during install. Removes the right click option on the local machine
    regedit /s 'C:\_JJR-TOOLS\Auto-Bitlocker\Files\Remove AutoBitlocker.reg'
    Start-Sleep -s 2
    Write-Host "`nRegistry key removed."
    Start-Sleep -s 2
    Write-Host "`nRemoving Auto-Bitlocker folder..."
    Start-Sleep -s 2
    # Removes the temp folder in root of C: including any remaining files within
    Remove-Item -LiteralPath "C:\_JJR-TOOLS\Auto-Bitlocker" -Force -Recurse
    Start-Sleep -s 2
    # Lets user know the script has finished running. Will loop back for them to quit
    Write-Host "`n`nRemove complete.`n`nYou should no longer see the AutoBitlocker option the context menu of drives."
    Start-Sleep -s 2


    }
   }
    # Waits for the user to press enter before looping back to the menu
    pause
 }
 # If the choice on the menu is 'q' then the script will quit
 until ($selection -eq 'q')



 ### add in some error checks however as yet no errors found to present-maybe reg key checks?
 ### add in config for full or quick bitlocker

