Import-Module RemoteDesktop

Set-Location c:\cfn

$json = aws ssm get-parameter --name 'AD-JoinDomain-Variables' --output text --query 'Parameter.Value' | ConvertFrom-Json 
$domain = $json.domain
$SegIP = $json.segIP
$user = $json.user
$passwd = $json.passwd
$WinClientName = $json.winClientName
$WinClientIP = $json.winClientIP
$WkgName = $json.wkgName
$AdIP = $json.AdIP
$AdPort = $json.AdPort
$AdHostname = $json.AdHostname
$bolDomain = (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain
$LogSource = "JoinDomain"

function CallADCommand ($ip, $port, $cmd) {
    $tcpConnection = New-Object System.Net.Sockets.TcpClient($ip, $port)
    $tcpStream = $tcpConnection.GetStream()
    $writer = New-Object System.IO.StreamWriter($tcpStream)
    $writer.AutoFlush = $true

    # Call the RDS Configuration
    $writer.WriteLine($cmd)
    $writer.Close()
}

#Create EventLog
New-EventLog -LogName Application -Source $LogSource

$joinCred = New-Object pscredential -ArgumentList ([pscustomobject]@{
    UserName = $user
    Password = (ConvertTo-SecureString -String $passwd -AsPlainText -Force)[0]
})

$currhostname = $env:COMPUTERNAME

[array] $cmdOutput = netsh interface ip show address | findstr "IP Address"
Foreach ($line in $cmdOutput) {
    $ip = ($line.Split(":")[1]).Trim()
    if ($ip.contains($SegIP)) {
        Write-Host $ip 
        Write-Host $WinClientIP

        if ($ip -eq $WinClientIP) {
            Write-Host "Equivalente"
            if ($bolDomain -eq "True") {
                Write-EventLog -LogName Application -Source $LogSource -EntryType Information -EventId 1 -Message "Unjoining domain, and recovering the machine hostname"
                Remove-Computer -UnjoinDomainCredential $joinCred -WorkgroupName $WkgName -PassThru -Verbose

                shutdown /r /t 5

            } else {
                Write-EventLog -LogName Application -Source $LogSource -EntryType Information -EventId 1 -Message "No need to unjoin domain"
                if ($currhostname -ne $WinClientName) {
                    Write-EventLog -LogName Application -Source $LogSource -EntryType Information -EventId 1 -Message "Renaming host"
                    Rename-Computer -NewName $WinClientName

                    shutdown /r /t 5

                }
            }
        } else {
            Write-Host "Diferente"

            # Check if STATUSFILE exists
            $res = Test-Path STATUSFILE

            if ($res -like "False") {
                New-Item -Path . -Name "STATUSFILE" -ItemType "file" -Value "STEP-01"
            }
                
            $newhostname = $ip.replace('.', '-')
            $res = Get-Content -Path .\STATUSFILE -TotalCount 1
            CallADCommand $AdIP $ADPort $res

            if ($res -like "STEP-01") {
                Remove-Item "STATUSFILE" -Force
                New-Item -Path . -Name "STATUSFILE" -ItemType "file" -Value "STEP-02"

                Write-Host "Changing name from $currhostname to $newhostname and joining the Domain $domain"
                Write-EventLog -LogName Application -Source $LogSource -EntryType Information -EventId 1 -Message "Changing name from $currhostname to $newhostname and joining the Domain $domain"
                Add-Computer -DomainName $domain -Credential $joinCred -NewName $newhostname

                shutdown /r /t 5

            } elseif ($res -like "STEP-02") {

                if ($newhostname -ne $currhostname) {
                    Write-Host "Rename PC from $currhostname to $newhostname"
                    Write-EventLog -LogName Application -Source $LogSource -EntryType Information -EventId 1 -Message "No need to join domain"
                    Rename-Computer -DomainCredential $joinCred -NewName $newhostname

                    shutdown /r /t 5

                } else {

                    Remove-Item "STATUSFILE" -Force
                    New-Item -Path . -Name "STATUSFILE" -ItemType "file" -Value "STEP-03"

                    # Allow "SAP\SAP Users Group" to RDP to the server
                    net localgroup "Remote Desktop Users" /add "SAP\SAP Users Group"

                    # Change user who will run the Scheduled Task to use SAP\Administrator
                    Set-ScheduledTask -TaskName JoinDomain -User $user -Password $passwd

                    # Install RDS
                    Write-Host "Instalando RDS"
                    Install-WindowsFeature Remote-Desktop-Services
                    Write-EventLog -LogName Application -Source $LogSource -EntryType Information -EventId 1 -Message "Instalando RDS"

                    CallADCommand $AdIP $ADPort "RDS-CONFIG"
                }
                
            } elseif ($res -like "STEP-03") {

                Remove-Item "STATUSFILE" -Force
                New-Item -Path . -Name "STATUSFILE" -ItemType "file" -Value "DONE"

                # Add AD to Server Manager
                Write-Host "Adding $AdHostname to Server Manager"
                Write-EventLog -LogName Application -Source $LogSource -EntryType Information -EventId 1 -Message "Adding $AdHostname to Server Manager"
                Start-Process Powershell.exe -Credential $joinCred -ArgumentList "-Command & .\AddServerToManager.ps1 $AdHostname"

                # Restart the computer
                shutdown /r /t 30

            } elseif ($res -like "DONE") {

                # Start HealthCheck Service
                Write-Host "JoinDomain finished, starting HealthCheck script"
                Write-EventLog -LogName Application -Source $LogSource -EntryType Information -EventId 1 -Message "JoinDomain finished, starting HealthCheck script"
                Start-Process Powershell.exe -Credential $joinCred -ArgumentList "-Command & 'C:\Program Files\Python\Python39\python.exe' c:\cfn\ServerHealthCheck.py"

                CallADCommand $AdIP $ADPort "JoinDomain FINISHED"

            }
        }
    }
}

