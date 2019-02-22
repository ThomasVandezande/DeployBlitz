import-module GenericFunctions
import-module Logging
Import-Module SQLPS

##Supply the share containing the DBATools template database backup
$DBShare = "\\FQDN\Sharename\DBATools_Template.bak"

#Provide your script location so we can reference the other resources
$ScriptLocation= "C:\ScriptLocation\DeployBlitz\"
#Provide the location for your SQL Credential. If no exported credential is present you will be prompted to enter for future use.
$CredLocation = "C:\CredentialLocation\CredentialSQL.xml"

#ALTERING THIS VARIABLE WILL REQUIRE CHANGES IN THE SQL JOB AS WELL!!
$database = "DBATools"



Start-LogWriter -Location $ScriptLocation -Type "Deployz_Blitz"

write-logmessage -Severity "Info" -LogMessage "Loading Instances to deploy."

$Instances = Get-Csv -CSVLocation ($ScriptLocation+"\Sources\Servers.csv")

write-logmessage -Severity "info" -LogMessage "Instances loaded."

##Needed for future 'redeploy' of solution ##TODO
[string]$Query = Get-Content ($ScriptLocation+"\Sources\CheckDBExistance.sql")

write-logmessage -Severity "info" -LogMessage "Query loaded: $Query"

$cred = Get-Cred -CredLocation $CredLocation

$backupLocation = $DBShare

$GetLocationQuery = @"
select 
    InstanceDefaultDataPath = serverproperty('InstanceDefaultDataPath'),
    InstanceDefaultLogPath = serverproperty('InstanceDefaultLogPath')
"@



foreach($instance in $Instances){
    #Load SQL job creation statement and randomize run-schedule minutes
    $starttime = Get-Random -Minimum 1 -Maximum 59
    $CreateJob = Get-Content ($ScriptLocation+"\Sources\SQLJob.sql" )
    [string]$CreateJobSQL = $CreateJob -replace '@active_start_time=5300, ' ,"@active_start_time=$($Starttime)00, " -replace "@active_end_time=5259,","@active_end_time=$($starttime-1)59,"

    
    $server= $instance.Instance
    Write-LogMessage -Severity "info" -LogMessage "Starting deploy for instance $server"

    $result = Invoke-Sqlcmd2 -ServerInstance $server -Database master -Query $GetLocationQuery -Credential $cred
    $newDFilelocation = $result.InstanceDefaultDataPath+'DBATools.mdf'
    $NewLFileLocation = $result.InstanceDefaultLogPath+'DBATools.ldf'



$sqlRestore = @"

USE [master]

RESTORE DATABASE [$database] 
FROM DISK = N'$backupLocation' 
WITH FILE = 1,  
     MOVE N'DBATools' TO N'$newDFilelocation',  
     MOVE N'DBATools_log' TO N'$NewLFileLocation',  
     NOUNLOAD, REPLACE, STATS = 5
;
"@

    Write-LogMessage -Severity "Info" -LogMessage "Restoring database with command: $sqlRestore"
    #Restore the database and create the job
    Invoke-Sqlcmd2 -ServerInstance $instance.Instance -Query $sqlRestore -Credential $cred -ErrorAction Stop
    Invoke-Sqlcmd2 -ServerInstance $instance.Instance -Query $CreateJobSQL -Credential $cred -Database msdb -ErrorAction Stop
    
    Write-LogMessage -Severity "Info" -LogMessage "Finished Deploy for server $server"

    
}


