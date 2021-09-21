$json = aws ssm get-parameter --name 'AD-JoinDomain-Variables' --output text --query 'Parameter.Value' | ConvertFrom-Json 
$user = $json.user
$passwd = $json.passwd
$WkgName = $json.wkgName

$rand = -join ((65..90) + (97..122) | Get-Random -Count 5 | ForEach-Object {[char]$_})
$CompName = "WinClient-"+$rand

$joinCred = New-Object pscredential -ArgumentList ([pscustomobject]@{
    UserName = $user
    Password = (ConvertTo-SecureString -String $passwd -AsPlainText -Force)[0]
})

Remove-Computer -UnjoinDomainCredential $joinCred -WorkgroupName $WkgName -PassThru -Verbose -Restart -Force

Rename-Computer -NewName $CompName -Restart -Force