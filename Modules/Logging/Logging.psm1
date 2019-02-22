function Get-Logtime(){
   <#
        .SYNOPSIS
            Returns the current date and time to include in a logmessage
        .EXAMPLE
            Get-Logtime
        .DESCRIPTION
            Can be used to get the current date and time in a string format to include in a log message and/or file name.       
           
    #>
    return get-date -Format 'yyyy/MM/dd hh:mm:ss'
}

<#
##During DEV, maybe needed later
function Create-LogSource(){
    Param(
    [parameter(Mandatory=$true)]
    [String]$Source
    )

    new-eventlog -LogName Application -Source $Source
}
#>

function Start-LogWriter(){
   <#
        .SYNOPSIS
            Creates a new logfile at the specified location.
        .EXAMPLE
            Start-LogWriter -Location C:\Temp\Scripts\ -Type "DBReport"
        .DESCRIPTION
            The function takes a location and type as parameter.
            It will create a text file at the specified location where the filename contains:
            - The word 'log'
            - The Type parameter defined
            - The current date fetched from the 'get-logtime' function
        
        .PARAMETER Location
            Location where to write the logfile.
            This is a folder -> not a file.

        .PARAMETER Type
            Used in the filename.    
           
    #>
    Param(
    [parameter(Mandatory=$true)]
    [String]$Location,
    [String]$Type
    )
    
    $global:LogOutput
    $LogTime = Get-Logtime
    $LogOutput += ($LogTime + ":  Starting execution")
    $Global:Logfile = ($Location + "" + $Type + "_Log_" + (get-date -format 'dd-MM-yyyy') + ".txt" )
 
    try{
        $LogOutput | out-file $Logfile -Append
    }catch{
        write-host -ForegroundColor Red "Writing Logfile Failed with error: $error" 
      
    }
     

}

function Stop-LogWriter(){
   <#
        .SYNOPSIS
            Writes a last line to the logfile.
        .EXAMPLE
            Stop-LogWriter
        .DESCRIPTION
            When called the function will add a finishing line to the logfile.
            Can be modified.
           
    #>

    $Finishtext = ((Get-Logtime) + ":  Finished Execution of the script.")
    $Finishtext | out-file $Logfile -Append


}

function Write-LogMessage{
   <#
        .SYNOPSIS
            Writes an item to an existing logfile.
        .EXAMPLE
            Write-LogMessage -Severity "Info" -LogMessage "This is an example message"

            This will write the message in 'LogMessage' to the logfile with 'info' severity
        .EXAMPLE
            Write-LogMessage -Severity "Critical" -LogMessage "This is a very critical error, execution will halt."

            This will write a Critical severity entry in the log file and stop execution of the script afterwards.
        .DESCRIPTION
            When called it appends a line to an existing logfile created with 'Start-LogWriter'.
            If the severity 'Critical' is provided the function will write a last entry in the logfile and call the 'Finish-LogWriter' function.

            The line of the log will be build as following:
             - Get the current date + time (get-logtime)
             - The severity
             - The message
        
        .PARAMETER Severity
            Any value can be provided dependning to own flavour.
            Only value 'Critical' will cause the script to exit after the item is appended to the logfile.

        .PARAMETER Message
            Message that needs to be appended in the logfile.  
           
    #>
    Param(
    [parameter(Mandatory=$true)]
    [String]$Severity,
    [string]$LogMessage
    )
    
    $Logoutput = ((get-logtime)+ ":  $Severity :  $Logmessage")

    #Check for critical severity and take action accordingly.
    switch($Severity){
        "Critical" {
            try{
                $Logouput| out-file $Logfile -Append
                Finish-logwriter
                exit
            }catch{
                write-host -ForegroundColor Red "Writing Logfile Failed with error: $($error[0])"       
            }
        }
        default{    
            try{
                $LogOutput | out-file $Logfile -Append
            }catch{
                write-host -ForegroundColor Red "Writing Logfile Failed with error:  $($error[0])"       
            }
        }
    }

}

