# Get the List of IPs on ASG Fleet
$ips = @()
$flagSmallerIp = $FALSE
$flagFleetMachine = $FALSE

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
    # Write-Host "Faz parte do pool"
    Start-Service -Name AmazonCloudWatchAgent

    if ($flagSmallerIp) {

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
} else {
    # Write-Host "Não faz parte do pool"
}