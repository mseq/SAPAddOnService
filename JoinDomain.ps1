Import-Module RemoteDesktop

cd c:\cfn

$json = aws ssm get-parameter --name 'AD-JoinDomain-Variables' --output text --query 'Parameter.Value' | ConvertFrom-Json 
$domain = $json.domain
$SegIP = $json.segIP
$user = $json.user
$passwd = $json.passwd
$WinClientName = $json.winClientName
$WinClientIP = $json.winClientIP
$WkgName = $json.wkgName
$AdIP = $json.AdIP
$AdHostname = $json.AdHostname
$bolDomain = (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain
$LogSource = "JoinDomain"

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
                Remove-Computer -UnjoinDomainCredential $joinCred -WorkgroupName $WkgName -PassThru -Verbose -Restart -Force
            } else {
                Write-EventLog -LogName Application -Source $LogSource -EntryType Information -EventId 1 -Message "No need to unjoin domain"
                if ($currhostname -ne $WinClientName) {
                    Write-EventLog -LogName Application -Source $LogSource -EntryType Information -EventId 1 -Message "Renaming host"
                    Rename-Computer -NewName $WinClientName -Restart -Force
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

            if ($res -like "STEP-01") {

                Remove-Item "STATUSFILE" -Force
                New-Item -Path . -Name "STATUSFILE" -ItemType "file" -Value "STEP-02"

                Write-Host "Changing name from $currhostname to $newhostname and joining the Domain $domain"
                Write-EventLog -LogName Application -Source $LogSource -EntryType Information -EventId 1 -Message "Changing name from $currhostname to $newhostname and joining the Domain $domain"
                Add-Computer -DomainName $domain -Credential $joinCred -NewName $newhostname -Restart -Force

            } elseif ($res -like "STEP-02") {

                if ($newhostname -ne $currhostname) {
                    Write-Host "Rename PC from $currhostname to $newhostname"
                    Write-EventLog -LogName Application -Source $LogSource -EntryType Information -EventId 1 -Message "No need to join domain"
                    Rename-Computer -DomainCredential $joinCred -NewName $newhostname -Restart -Force
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

                    # Prepare TCP Connection to AD
                    # $AdIP = "127.0.0.1"
                    $tcpConnection = New-Object System.Net.Sockets.TcpClient($AdIP, 4489)
                    $tcpStream = $tcpConnection.GetStream()
                    $writer = New-Object System.IO.StreamWriter($tcpStream)
                    $writer.AutoFlush = $true

                    # Call the RDS Configuration
                    $writer.WriteLine("RDS-CONFIG")
                    $writer.Close()
                }
                
            } elseif ($res -like "STEP-03") {

                Remove-Item "STATUSFILE" -Force
                New-Item -Path . -Name "STATUSFILE" -ItemType "file" -Value "DONE"

                # Add AD to Server Manager
                Write-Host "Adding $AdHostname to Server Manager"
                Start-Process Powershell.exe -Credential $joinCred -ArgumentList "-Command .\AddServerToManager.ps1 $AdHostname"

                # Restart the computer
                Restart-Computer

            } elseif ($res -like "DONE") {

                # Start HealthCheck Service
                Start-Process Powershell.exe -Credential $joinCred -ArgumentList "-Command & 'C:\Program Files\Python\Python39\python.exe' -m pip install boto3; & 'C:\Program Files\Python\Python39\python.exe' -m pip install ec2-metadata; & 'C:\Program Files\Python\Python39\python.exe' c:\cfn\ServerHealthCheck.py"

            }
        }
    }
}
