Import-Module ActiveDirectory

Set-Location c:\cfn

$json = aws ssm get-parameter --name 'AD-JoinDomain-Variables' --output text --query 'Parameter.Value' | ConvertFrom-Json 
$SegIP = $json.segIP
$user = $json.user
$passwd = $json.passwd
$LogSource = "ClearADComputers"

# Create EventLog
New-EventLog -LogName Application -Source $LogSource
Write-Host "Starting ClearADComputers Script"
Write-EventLog -LogName Application -Source $LogSource -EntryType Information -EventId 1 -Message "Starting ClearADComputers Script"

$joinCred = New-Object pscredential -ArgumentList ([pscustomobject]@{
    UserName = $user
    Password = (ConvertTo-SecureString -String $passwd -AsPlainText -Force)[0]
})

$filter = "$($SegIP.replace('.', '-'))*"

while ($true) {
    Write-Host "Looping AD Joined Computers"
    Write-EventLog -LogName Application -Source $LogSource -EntryType Information -EventId 2 -Message "Looping AD Joined Computers"

    $Computers = Get-ADComputer -Credential $joinCred -Filter "Name -like '$filter'"

    Foreach ($Computer in $Computers) {
        $ip = ([string]$($computer.Name)).Replace('-','.')
        $bol = Test-Connection $ip -Count 10 -Delay 3 -Quiet
        Write-Host "Testing connection to $($ip): $($bol)"
        if ($bol -like "False") {
            Write-Host "Removing $($Computer.Name) from AD"
            Write-EventLog -LogName Application -Source $LogSource -EntryType Information -EventId 3 -Message "Removing $($Computer.Name) from AD"
            Remove-ADComputer -Identity "$($Computer.Name)" -Confirm:$false
        } else {
            Write-Host "Keeping $($Computer.Name) from AD"
            Write-EventLog -LogName Application -Source $LogSource -EntryType Information -EventId 3 -Message "Keeping $($Computer.Name) on AD"
        }
    }

    Write-Host "Sleeping the loop"
    Write-EventLog -LogName Application -Source $LogSource -EntryType Information -EventId 2 -Message "Sleeping the loop"
    Start-Sleep -Seconds 900
}