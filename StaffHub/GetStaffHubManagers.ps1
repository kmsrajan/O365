Function ConnectToStaffHub
{
    #install StaffHub module
    #InstallInstall-Module -Name MicrosoftStaffHub  

    #Capture global administrator credentials
    $cred=Get-Credential

    try{

        #connect to StaffHub
        Connect-StaffHub -Credentials $cred
        MsgLog -Msg "Connected to StaffHub successfully" -Cat "1"


    }
    Catch{
    
        MsgLog -Msg "StaffHub connection failed"  -Cat "3"
        MsgLog -Msg $_.Exception.Message -Cat "3"
    }
}

function MsgLog($Msg,$Cat)
{
    # set the new color based on category
    if($Cat -eq "1"){
        $foreColor="Green"
        $Msg= "Success : " + $Msg
    }

    if($Cat -eq "2")
    {
        $foreColor="Yellow"
         $Msg= "Warning : " + $Msg
    }
    if($Cat -eq "3"){
        $foreColor="Red"
         $Msg= "Error : " + $Msg
    }

    
    # output
    Write-Host $msg -ForegroundColor $foreColor

}

Function GetStaffHubManagers($csvPath)
{
try{
    #Get all staffhub teams for tenant
    $teamsColl=Get-StaffHubTeamsForTenant

    	
    $hubColl = New-Object System.Collections.ArrayList

    for($a=0; $a -lt $teamsColl.Id.Count; $a++){
        
        $members=Get-StaffHubMember -TeamId $teamsColl.Id[$a] `
        | where IsManager -EQ "True" `
        | select Email, State, DisplayName
        
        $temp = New-Object System.Object
        $temp | Add-Member -MemberType NoteProperty -Name "TeamName" -Value $teamsColl.Name[$a]
        $emails=""
        $DispNames=""

        foreach($mem in $members){
            $emails =$emails+$mem.Email+";"
            $DispNames =$DispNames+$mem.DisplayName+";"
        }
        
        
        $temp | Add-Member -MemberType NoteProperty -Name "Email" -Value $emails
        $temp | Add-Member -MemberType NoteProperty -Name "DisplayName" -Value $DispNames

        $hubColl.Add($temp) | Out-Null


    }
    $hubColl | Export-Csv -Path $csvPath

    MsgLog -Msg "StaffHub information exported" -Cat "1"

    }
    catch{
        MsgLog -Msg "Error : Extract failed" -Cat "3"
        MsgLog -Msg $_.Exception.Message -Cat "3"
    }
} 

ConnectToStaffHub
GetStaffHubManagers -csvPath "C:\KMSlab\StaffHub\Export-Csv new.csv" 
