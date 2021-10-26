# Get the List of IPs on ASG Fleet
$ips = @()
$flagSmallerIp = $FALSE
$flagFleetMachine = $FALSE
$LogSource = "ManageAddOnService"

# Create EventLog
New-EventLog -LogName Application -Source $LogSource
Write-Host "Starting $LogSource Script"
Write-EventLog -LogName Application -Source $LogSource -EntryType Information -EventId 1 -Message "Starting $LogSource Script"

$TargetGroupArn = aws elbv2 describe-target-groups --output text --query "TargetGroups[*].TargetGroupArn" | findstr WinClientELB
if ($null -ne $TargetGroupArn) {
    [array] $targets = aws elbv2 describe-target-health --target-group-arn $TargetGroupArn --output text --query "TargetHealthDescriptions[*].[Target.Id, TargetHealth.State]" | findstr healthy
    Foreach ($line in $targets) {
        $details = -split $line
        $ip = aws ec2 describe-instances --output text --query 'Reservations[*].Instances[*].[NetworkInterfaces[*].PrivateIpAddress]' --instance-ids $details[0]
        $ips += $ip
    }

    $SmallerIp="255.255.255.255"
    Foreach ($ip in $ips) {
        if ([int]$ip.Split(".")[3] -le [int]$SmallerIp.Split(".")[3]) {
            $SmallerIp = $ip
        }
    }

    [array] $cmdOutput = netsh interface ip show address | findstr "IP Address"
    Foreach ($line in $cmdOutput) {
        if ($line.Contains($SmallerIp)) {
            $flagSmallerIp = $TRUE
        }
    }

    Foreach ($line in $cmdOutput) {
        Foreach ($ip in $ips) {
            if ($line.Contains($ip)) {
                $flagFleetMachine = $TRUE
            }
            # Write-Host "Linha: $line"
            # Write-Host "IP: $ip"
        }
    }

}

if ($flagFleetMachine) {
    Write-Host "This host belongs to the AutoScalingGroup"
    Write-EventLog -LogName Application -Source $LogSource -EntryType Information -EventId 2 -Message "This host belongs to the AutoScalingGroup"

    # # Checks for the time to environment shutdown and change InstanceProtection
    # $json = aws ssm get-parameter --name 'Environment-Schedule' --output text --query 'Parameter.Value' | ConvertFrom-Json 
    # $wday = [Int] (Get-Date).DayOfWeek
    # if ($wday -eq 0) {
    #     $wday = 6
    # } else {
    #     $wday = $wday - 1
    # }
    # $time = [string](Get-Date).Hour + ":" + [string](Get-Date).Minute

    # if ($json.weekdays[$wday].'stop-environment' -eq $time) {
    #     Write-Host "Set TERMINATION PROTECTION OFF to instance $($instanceId), due to Environment Shutdown"
    #     Write-EventLog -LogName Application -Source $LogSource -EntryType Information -EventId 4 -Message "Set TERMINATION PROTECTION ON to instance $($instanceId), due to Environment Shutdown"

    #     aws autoscaling set-instance-protection --instance-ids $instanceId --auto-scaling-group-name $asg --no-protected-from-scale-in
    #     shutdown /s
    # }

    Start-Service -Name AmazonCloudWatchAgent

    if ($flagSmallerIp) {
        Write-Host "Turning On the AddOn Services"
        Write-EventLog -LogName Application -Source $LogSource -EntryType Information -EventId 3 -Message "Turning On the AddOn Services"
    
        Start-Service -Name IntegrationBankApiRest
        Start-Service -Name IntegrationBankEnvioDeEmail
        Start-Service -Name IntegrationBankEnvioDeTemplateEmail
        Start-Service -Name IntegrationBankGeracaoDeBoleto
        Start-Service -Name IntegrationBankGeracaoDeRemessaDeCobranca
        Start-Service -Name IntegrationBankImportacaoDeRetornoDeCobranca
        Start-Service -Name IntegrationBankImportacaoRetornoConciliacaoCartao
        Start-Service -Name IntegrationBankImpressaoDeBoleto
        Start-Service -Name IntegrationBankServiceMonitor
        Start-Service -Name IntegrationBankProcessamentoDeExtrato
        Start-Service -Name IntegrationBankProcessamentoDeRetornoDeCobranca
        Start-Service -Name IntegrationBankProcessamentoDeRetornoDeDda
        Start-Service -Name IntegrationBankProcessamentoDeRetornoDePagamento
        Start-Service -Name IntegrationBankRegistroDeBoletoOnlinePelaApi
        Start-Service -Name InvoiceOneSendCancel
        Start-Service -Name InvoiceOneSendEventService
        Start-Service -Name InvoiceOneSendDisablingService
        Start-Service -Name InvoiceOneSendService
        Start-Service -Name InvoiceOneImportDocumentNfse
        Start-Service -Name InvoiceOneImportDocument
        Start-Service -Name InvoiceOneImportDocumentByEmail
        Start-Service -Name InvoiceOneMonitorService
        Start-Service -Name InvoiceOneReturnCancelService
        Start-Service -Name InvoiceOneReturnEventService
        Start-Service -Name InvoiceOneReturnDisablingService
        Start-Service -Name InvoiceOneReturnService
        Start-Service -Name InvoiceOneApiObj
        Start-Service -Name InvoiceOneRegularidadeDoParceiroDoSap
        Start-Service -Name InvoiceOneRetornoApiObj
        Start-Service -Name TaxOneImportEcf
        Start-Service -Name InvoiceOneDfeChave
        Start-Service -Name InvoiceOneDfeNsu
        Start-Service -Name InvoiceOneDfeEvento
        Start-Service -Name InvoiceOneDfeIncluirDocSap
        Start-Service -Name InvoiceOneRecebimentoApi
        Start-Service -Name TaxOneNfseCancelService
        Start-Service -Name TaxOneNfseEmailService
        Start-Service -Name TaxOneNfseSendLoteServiceWs
        Start-Service -Name TaxOneNfseSendService
        Start-Service -Name TaxOneNfseMonitorService
        Start-Service -Name TaxOneNfseReSendService
        Start-Service -Name TaxOneNfseReturnLoteServiceWs
        Start-Service -Name TaxOneNfseRetornoTxt
        Start-Service -Name TaxOneNfseReturnService

    } else {
        Write-Host "Turning Off the AddOn Services"
        Write-EventLog -LogName Application -Source $LogSource -EntryType Information -EventId 3 -Message "Turning Off the AddOn Services"

        Stop-Service -Name IntegrationBankApiRest
        Stop-Service -Name IntegrationBankEnvioDeEmail
        Stop-Service -Name IntegrationBankEnvioDeTemplateEmail
        Stop-Service -Name IntegrationBankGeracaoDeBoleto
        Stop-Service -Name IntegrationBankGeracaoDeRemessaDeCobranca
        Stop-Service -Name IntegrationBankImportacaoDeRetornoDeCobranca
        Stop-Service -Name IntegrationBankImportacaoRetornoConciliacaoCartao
        Stop-Service -Name IntegrationBankImpressaoDeBoleto
        Stop-Service -Name IntegrationBankServiceMonitor
        Stop-Service -Name IntegrationBankProcessamentoDeExtrato
        Stop-Service -Name IntegrationBankProcessamentoDeRetornoDeCobranca
        Stop-Service -Name IntegrationBankProcessamentoDeRetornoDeDda
        Stop-Service -Name IntegrationBankProcessamentoDeRetornoDePagamento
        Stop-Service -Name IntegrationBankRegistroDeBoletoOnlinePelaApi
        Stop-Service -Name InvoiceOneSendCancel
        Stop-Service -Name InvoiceOneSendEventService
        Stop-Service -Name InvoiceOneSendDisablingService
        Stop-Service -Name InvoiceOneSendService
        Stop-Service -Name InvoiceOneImportDocumentNfse
        Stop-Service -Name InvoiceOneImportDocument
        Stop-Service -Name InvoiceOneImportDocumentByEmail
        Stop-Service -Name InvoiceOneMonitorService
        Stop-Service -Name InvoiceOneReturnCancelService
        Stop-Service -Name InvoiceOneReturnEventService
        Stop-Service -Name InvoiceOneReturnDisablingService
        Stop-Service -Name InvoiceOneReturnService
        Stop-Service -Name InvoiceOneApiObj
        Stop-Service -Name InvoiceOneRegularidadeDoParceiroDoSap
        Stop-Service -Name InvoiceOneRetornoApiObj
        Stop-Service -Name TaxOneImportEcf
        Stop-Service -Name InvoiceOneDfeChave
        Stop-Service -Name InvoiceOneDfeNsu
        Stop-Service -Name InvoiceOneDfeEvento
        Stop-Service -Name InvoiceOneDfeIncluirDocSap
        Stop-Service -Name InvoiceOneRecebimentoApi
        Stop-Service -Name TaxOneNfseCancelService
        Stop-Service -Name TaxOneNfseEmailService
        Stop-Service -Name TaxOneNfseSendLoteServiceWs
        Stop-Service -Name TaxOneNfseSendService
        Stop-Service -Name TaxOneNfseMonitorService
        Stop-Service -Name TaxOneNfseReSendService
        Stop-Service -Name TaxOneNfseReturnLoteServiceWs
        Stop-Service -Name TaxOneNfseRetornoTxt
        Stop-Service -Name TaxOneNfseReturnService

    }

    # Handle TERMINATION PROTECTION
    $cmdEng = (query user | Select-String -Pattern 'Active' -AllMatches).Length
    $cmdPt = (query user | Select-String -Pattern 'Ativo' -AllMatches).Length

    $res = [int]$cmdEng + [int]$cmdPt
    $token = Invoke-RestMethod -Headers @{"X-aws-ec2-metadata-token-ttl-seconds" = "21600"} -Method PUT –Uri http://169.254.169.254/latest/api/token
    $instanceId = Invoke-RestMethod -Headers @{"X-aws-ec2-metadata-token" = $token} -Method GET -Uri http://169.254.169.254/latest/meta-data/instance-id
    $asg = aws autoscaling describe-auto-scaling-groups --output text --query 'AutoScalingGroups[*].AutoScalingGroupName'

    if ($res -ge 1) {
        Write-Host "Set TERMINATION PROTECTION ON to instance $($instanceId)"
        Write-EventLog -LogName Application -Source $LogSource -EntryType Information -EventId 4 -Message "Set TERMINATION PROTECTION ON to instance $($instanceId)"

        aws autoscaling set-instance-protection --instance-ids $instanceId --auto-scaling-group-name $asg --protected-from-scale-in
    } else {
        Write-Host "Set TERMINATION PROTECTION OFF to instance $($instanceId)"
        Write-EventLog -LogName Application -Source $LogSource -EntryType Information -EventId 4 -Message "Set TERMINATION PROTECTION ON to instance $($instanceId)"

        aws autoscaling set-instance-protection --instance-ids $instanceId --auto-scaling-group-name $asg --no-protected-from-scale-in
    }
    
} else {
    # Write-Host "Não faz parte do pool"
}