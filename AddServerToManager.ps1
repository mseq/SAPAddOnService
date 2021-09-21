Import-Module RemoteDesktop

# Define DateTime Constant for BKP Names
$dt = Get-Date -format "yyyyMMddHHmm"
$servername = $args[0]

Write-Host $servername
if ($Null -ne $servername) {
    # Write-Host "Recebi o argumento ok"
    # Step 1: Close Server Manager
    get-process ServerManager | stop-process –force

    # Step 2: Set path to existing ServerList.xml file
    $file = get-item $env:USERPROFILE\AppData\Roaming\Microsoft\Windows\ServerManager\ServerList.xml

    # Step 3: Backup ServerList.xml
    copy-item –path $file –destination $file-bkp-$dt –force

    # Step 4: Get content from ServerList.xml in XML format
    [xml]$xml = Get-Content $file
    # @($xml.ServerList.ServerInfo)[0]

    # Step 5: Clone an existing managed server element to a new XML element
    $newserver = @($xml.ServerList.ServerInfo)[0].clone()

    # Step 6: Update the new cloned element with new server information
    $newserver.name = $servername 
    $newserver.lastUpdateTime = “0001-01-01T00:00:00” 
    $newserver.status = “2”

    # $newserver

    # Step 7: Append the new cloned element inside the ServerList node
    $xml.ServerList.AppendChild($newserver)

    # Step 8: Save the updated XML elements to ServerList.xml
    $xml.Save($file.FullName)
    
    # Step 9: Re-launch Server Manager to see the results
    start-process –filepath $env:SystemRoot\System32\ServerManager.exe –WindowStyle Maximized

    # Step 10: Set the LicenseServer
    Set-RDLicenseConfiguration -LicenseServer $servername -Mode PerUser -Force

} else {
    Write-Host "Sem argumento"
}

# Start-Sleep 300