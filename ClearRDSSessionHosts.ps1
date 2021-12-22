$server = "\\.\pipe\MICROSOFT##WID\tsql\query"
$db = "RDCms"

$sql = " DELETE FROM RDS.RoleRdwa WHERE ServerId = (SELECT ID FROM [RDCms].[rds].[Server] WHERE Upper(Name) like Upper('10-160-1-%.SAP.VALTELLINA.CORP')) "
Invoke-Sqlcmd -ServerInstance $server -Database $db -Query $sql

$sql = " DELETE FROM RDS.SERVER WHERE Upper(Name) like Upper('10-160-1-%.SAP.VALTELLINA.CORP')) "
Invoke-Sqlcmd -ServerInstance $server -Database $db -Query $sql
