Import-Module ActiveDirectory

Set-Location c:\cfn

$json = aws ssm get-parameter --name 'AD-JoinDomain-Variables' --output text --query 'Parameter.Value' | ConvertFrom-Json 
$SegIP = $json.segIP
$user = $json.user
$passwd = $json.passwd
$LogSource = "ClearADComputers"

# Create EventLog
New-EventLog -LogName Application -Source $LogSource

$joinCred = New-Object pscredential -ArgumentList ([pscustomobject]@{
    UserName = $user
    Password = (ConvertTo-SecureString -String $passwd -AsPlainText -Force)[0]
})

$filter = "$($SegIP.replace('.', '-'))*"

$Computers = Get-ADComputer -Credential $joinCred -Filter "Name -like '$filter'"

Foreach ($Computer in $Computers) {
    Write-Host "Removing $($Computer.Name) from AD"
    Write-EventLog -LogName Application -Source $LogSource -EntryType Information -EventId 1 -Message "Removing $($Computer.Name) from AD"
    Remove-ADComputer -Identity "$($Computer.Name)" -Confirm:$false
}