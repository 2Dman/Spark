# Script name:   	SparkInstall.ps1
# Version:			v1.02.151125
# Created on:    	19/11/2015
# Author:        	Riebbels Willem
# Purpose:       	Install Spark
#					
# On Github:		https://github.com/2Dman/spark/
# On Oper-Init.eu   http://blog.oper-init.eu
# Recent History:       	
#	19/11/15 => First edit
# Copyright:
#	This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published
#	by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program is distributed 
#	in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
#	PARTICULAR PURPOSE. See the GNU General Public License for more details. You should have received a copy of the GNU General Public 
#	License along with this program.  If not, see <http://www.gnu.org/licenses/>.

#Variable
$Architecture = $ENV:PROCESSOR_ARCHITECTURE
$SparkInstallPath = "C:\DRV\Spark\spark_2_7_3_online.exe"
$SparkKerberos = "HKLM\System\CurrentControlSet\Control\Lsa\Kerberos\Parameters"
$SparkInstaller = "2.7.3"
$SparkBackupUserFolder = "C:\Users\$env:username\AppData\Roaming\SparkBackup"
$CurrentJavaVersion32Bit = (Get-ChildItem "C:\Program Files (x86)\Java\jre*\bin\java.exe").VersionInfo.ProductVersion
$SparkInstallerArgumentsList  = "-q -console -dir ""$ProgramsFolder"""
#End Variable


if($CurrentJavaVersion32Bit -ge 7.0.51){

#Kill Spark
stop-Process -name spark

#Start BackupUserChatHistory
if(Test-Path $SparkBackupUserFolder){}else{new-item $SparkBackupUserFolder -type Directory}
Write-Host "Backup user History to $SparkBackupUserFolder"
cp C:\Users\$env:username\AppData\Roaming\SparkBack\user\ $SparkBackupUserFolder

#Spark Uninstall Cleanup
Write-Host "Spark Uninstall Cleanup"
Get-ChildItem -Path "C:\Program Files (x86)\Spark\" -Recurse | Remove-Item -force -recurse
Remove-Item "C:\Program Files (x86)\Spark\" -force

#Spark User uninstall Cleanup
Write-Host "Spark User uninstall Cleanup"
Get-ChildItem -Path "C:\Users\$env:username\AppData\Roaming\Spark\" -Recurse | Remove-Item -force -recurse
Remove-Item "C:\Users\$env:username\AppData\Roaming\Spark\" -force

#Temp Folder cleanup Spark Uses
Write-Host "Temp Folder cleanup Spark Uses"
Get-ChildItem -Path "C:\Users\$env:username\AppData\Local\Temp" -Recurse | Remove-Item -force -recurse
Remove-Item "C:\Users\$env:username\AppData\Local\Temp" -force

if ($Architecture = "AMD64")
{
	$ProgramsFolder = "C:\Program Files (x86)\Spark"
}
else
{
	$ProgramsFolder = "C:\program files\Spark"
}
$SparkExe = "$ProgramsFolder\Spark.exe"
if(Test-Path $SparkExe){
$SparkVersion = ([System.Diagnostics.FileVersionInfo]::GetVersionInfo($SparkExe)).Productversion
}
else
{
$SparkVersion = $null
}

reg add $SparkKerberos /v AllowTGTSessionKey /t REG_DWORD /d 1 /f

if($SparkVersion -lt $SparkInstaller -Or $SparkVersion -eq $null){
Write-host "Installing Spark client..."
start-process -wait -Filepath $SparkInstallPath -ArgumentList $SparkInstallerArgumentsList
}

#Begin Variable Spark properties File
$SparkProperties = "$ProgramsFolder\spark.properties"
# Spark Connection Settings
$hostAndPort = $true
$xmppHost = "genim01.gentgrp.gent.be"
$xmppPort = 5222
$ssoMethod = "dns"
$ssoEnabled = $true
#Login
$server = "genim01.gentgrp.gent.be"
$autoLoginEnabled = $true
$username = "$env:username"
$loginAsInvisibleEnabled = $false
#Contact
$showEmptyGroups = $true
$showOfflineUsers = $true
$offlineGroupVisible = $false
$startHidden = $false
#End Variable Spark Properties File

Remove-item $SparkProperties -force | out-null
New-Item $SparkProperties -type file

Add-Content $SparkProperties -Value "hostAndPort=$hostAndPort"
Add-Content $SparkProperties -Value "xmppHost=$xmppHost"
Add-Content $SparkProperties -Value "xmppPort=$xmppPort"
Add-Content $SparkProperties -Value "ssoMethod=$ssoMethod"
Add-Content $SparkProperties -Value "ssoEnabled=$ssoEnabled"
Add-Content $SparkProperties -Value "server=$server"
Add-Content $SparkProperties -Value "autoLoginEnabled=$autoLoginEnabled"
Add-Content $SparkProperties -Value "showEmptyGroups=$showEmptyGroups"
Add-Content $SparkProperties -Value "showOfflineUsers=$showOfflineUsers"
Add-Content $SparkProperties -Value "offlineGroupVisible=$offlineGroupVisible"
Add-Content $SparkProperties -Value "starthidden=$startHidden"
Add-Content $SparkProperties -Value "loginAsInvisibleEnabled=$loginAsInvisibleEnabled"

#Peronsal Spark Settings
$PersonalSparkSettings = "C:\Users\$username\AppData\Roaming\Spark\spark.properties"
New-Item $PersonalSparkSettings -type file
Remove-item $PersonalSparkSettings -force | out-null

Add-Content $PersonalSparkSettings -Value "username=$username"

#Restore Spark Chat History
cp $SparkBackupUserFolder C:\Users\$env:username\AppData\Roaming\SparkBack\user\ 

#Ignite Settings
Start-process -filepath $sparkexe
Sleep -s 1

#Kill Spark Again
stop-Process -name spark
Sleep -s 2

#Start Spark
Start-process -filepath $sparkexe
}
else
{
Exit 2
}