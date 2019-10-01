#Get Backup folder
$Path = "\\192.168.1.100\Documents\Kodi\SauvegardeKodiConf"

#Date management for logs
$LogsDate = get-date -format "dddd dd/MM/yyyy HH:mm:ss"
function Refresh_Date
{
	$Result = get-date -format "dddd dd/MM/yyyy HH:mm:ss"
	return $Result
}

#Log Actions
$LogsPath = "\\192.168.1.100\Documents\Kodi\SauvegardeKodiConf\script_sauvegarde_Conf_Kodi.log"
$CurrentScriptName = $MyInvocation.MyCommand.Name #Récupération du nom du script en cours

#Start writing logs
add-content $LogsPath "-----------------------------------------------------------------------------------------------"
add-content $LogsPath "$LogsDate - $CurrentScriptName : Script is launched. Backups are present in `"\\192.168.1.100\Documents\Kodi\SauvegardeKodiConf`"."

#Remove all backups older than 20 days
$Daysback = "-20"
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddDays($Daysback)
$ItemsToDelete = Get-ChildItem -dir –Path $Path | Where-Object { $_.LastWriteTime -lt $DatetoDelete }# | Remove-Item -Recurse -Force
foreach($ItemToDelete in $ItemsToDelete)
{
	$LogsDate = Refresh_Date
	add-content $LogsPath "$LogsDate - $CurrentScriptName : Deleting '$ItemToDelete'."		
	Remove-Item $Path\$ItemToDelete -Recurse -Force
}	

#Create new folder, with today's date
$FolderName = Get-Date -Format yyyy-MM-dd
New-Item -Name $FolderName -Path $Path -itemtype directory -Force
#Copy all XML conf files to NAS - step 1: XML files
Copy-Item "C:\Users\gachd\AppData\Local\Packages\XBMCFoundation.Kodi_4n2hpmxwrvr6p\LocalCache\Roaming\Kodi\userdata\*.xml" -Destination $Path\$FolderName -Force
$LogsDate = Refresh_Date
add-content $LogsPath "$LogsDate - $CurrentScriptName : XML files are now copied on NAS."		
#Copy all XML conf files to NAS - step 2: addon_data folder
New-Item -Name addon_data -Path $Path\$FolderName -itemtype directory -Force
Copy-Item "C:\Users\gachd\AppData\Local\Packages\XBMCFoundation.Kodi_4n2hpmxwrvr6p\LocalCache\Roaming\Kodi\userdata\addon_data\*" -Destination $Path\$FolderName\addon_data -Force
$LogsDate = Refresh_Date
add-content $LogsPath "$LogsDate - $CurrentScriptName : addon_date folder is now copied on NAS."		
#Copy all XML conf files to NAS - step 3: addons folder
New-Item -Name addons -Path $Path\$FolderName -itemtype directory -Force
Copy-Item "C:\Users\gachd\AppData\Local\Packages\XBMCFoundation.Kodi_4n2hpmxwrvr6p\LocalCache\Roaming\Kodi\addons\*" -Destination $Path\$FolderName\addons -Force
$LogsDate = Refresh_Date
add-content $LogsPath "$LogsDate - $CurrentScriptName : addons folder is now copied on NAS."

#Last log
add-content $LogsPath "$LogsDate - $CurrentScriptName : Script execution is now finished."	