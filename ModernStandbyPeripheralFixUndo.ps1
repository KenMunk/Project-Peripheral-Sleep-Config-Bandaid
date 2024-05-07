$RawDeviceList = Get-PnpDevice | 
    where {$_.FriendlyName -Match "(Wi-Fi)|(Ethernet)|(Hub)"} | 
    where {$_.FriendlyName -notmatch "Virtual"} | 
    where {$_.Class -notmatch "Software"};

$PowerControlledDevices = Get-CimInstance -ClassName MSPower_DeviceEnable -namespace root\wmi;

$TargetDevices = @();

#Write-Host "Raw devices";

#Checking what the outputs are
foreach($rawdevice in $RawDeviceList){
    $rawInstanceID =  $rawdevice.InstanceID.Trim();
    #Write-Host $rawInstanceID;
    $rawInstanceID = $rawInstanceID.replace("\","\\");
    foreach($PowerDevice in $PowerControlledDevices){
        if($PowerDevice.InstanceName -match $rawInstanceID){
            #Write-Host $PowerDevice;
            $TargetDevices += $PowerDevice;
        }
    }
}

#Write-Host "Target Devices"

$InCompliance = $true;
foreach($Target in $TargetDevices){
    #Write-Host $Target;
    #Write-Host "Enable Status:"$Target.Enable;
    if($Target.Enable -eq $False){
        #Write-Host "Enable Status:"$Target.Enable "for" $Target;
        $InCompliance = $false;
        Set-CimInstance -InputObject $Target -Property @{Enable=$True} -PassThru;
    }
}