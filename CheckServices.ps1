# Keep these Stopped
Write-Host "These should not be running"
Get-Service -Name BankPlusApiRest
Get-Service -Name BankPlusConciliacaoAutomaticaDeCartao
Get-Service -Name BankPlusEnvioDeEmail
Get-Service -Name BankPlusEnvioDeTemplateEmail
Get-Service -Name BankPlusGeracaoDeBoleto
Get-Service -Name BankPlusGeracaoDeRemessaDeCobranca
Get-Service -Name BankPlusImportacaoDeRetornoDeCobranca
Get-Service -Name BankPlusImportacaoRetornoConciliacaoCartao
Get-Service -Name BankPlusImpressaoDeBoleto
Get-Service -Name BankPlusProcessamentoDeExtrato
Get-Service -Name BankPlusProcessamentoDeRetornoDeCobranca
Get-Service -Name BankPlusProcessamentoDeRetornoDeDda
Get-Service -Name BankPlusProcessamentoDeRetornoDePagamento
Get-Service -Name BankPlusRegistroDeBoletoOnlinePelaApi
Get-Service -Name BankPlusServiceMonitor

# B1IF Servvices
Write-Host "These must be running on main machine"
Get-Service -Name SAPB1iDIProxy
Get-Service -Name SAPB1iDIProxy_Monitor
Get-Service -Name SAPB1iEventSender
Get-Service -Name Tomcat8

# These should be running
Write-Host "These must be running on main machine"
Get-Service -Name IntegrationBankApiRest
Get-Service -Name IntegrationBankEnvioDeEmail
Get-Service -Name IntegrationBankEnvioDeTemplateEmail
Get-Service -Name IntegrationBankGeracaoDeBoleto
Get-Service -Name IntegrationBankGeracaoDeRemessaDeCobranca
Get-Service -Name IntegrationBankImportacaoDeRetornoDeCobranca
Get-Service -Name IntegrationBankImportacaoRetornoConciliacaoCartao
Get-Service -Name IntegrationBankImpressaoDeBoleto
Get-Service -Name IntegrationBankServiceMonitor
Get-Service -Name IntegrationBankProcessamentoDeExtrato
Get-Service -Name IntegrationBankProcessamentoDeRetornoDeCobranca
Get-Service -Name IntegrationBankProcessamentoDeRetornoDeDda
Get-Service -Name IntegrationBankProcessamentoDeRetornoDePagamento
Get-Service -Name IntegrationBankRegistroDeBoletoOnlinePelaApi
Get-Service -Name InvoiceOneSendCancel
Get-Service -Name InvoiceOneSendEventService
Get-Service -Name InvoiceOneSendDisablingService
Get-Service -Name InvoiceOneSendService
Get-Service -Name InvoiceOneImportDocumentNfse
Get-Service -Name InvoiceOneImportDocument
Get-Service -Name InvoiceOneImportDocumentByEmail
Get-Service -Name InvoiceOneMonitorService
Get-Service -Name InvoiceOneReturnCancelService
Get-Service -Name InvoiceOneReturnEventService
Get-Service -Name InvoiceOneReturnDisablingService
Get-Service -Name InvoiceOneReturnService
Get-Service -Name InvoiceOneApiObj
Get-Service -Name InvoiceOneRegularidadeDoParceiroDoSap
Get-Service -Name InvoiceOneRetornoApiObj
Get-Service -Name TaxOneImportEcf
Get-Service -Name InvoiceOneDfeChave
Get-Service -Name InvoiceOneDfeNsu
Get-Service -Name InvoiceOneDfeEvento
Get-Service -Name InvoiceOneDfeIncluirDocSap
Get-Service -Name InvoiceOneRecebimentoApi
Get-Service -Name TaxOneNfseCancelService
Get-Service -Name TaxOneNfseEmailService
Get-Service -Name TaxOneNfseSendLoteServiceWs
Get-Service -Name TaxOneNfseSendService
Get-Service -Name TaxOneNfseMonitorService
Get-Service -Name TaxOneNfseReSendService
Get-Service -Name TaxOneNfseReturnLoteServiceWs
Get-Service -Name TaxOneNfseRetornoTxt
Get-Service -Name TaxOneNfseReturnService


# Set-Service -Name IntegrationBankApiRest -StartupType Manual
# Set-Service -Name IntegrationBankEnvioDeEmail -StartupType Manual
# Set-Service -Name IntegrationBankEnvioDeTemplateEmail -StartupType Manual
# Set-Service -Name IntegrationBankGeracaoDeBoleto -StartupType Manual
# Set-Service -Name IntegrationBankGeracaoDeRemessaDeCobranca -StartupType Manual
# Set-Service -Name IntegrationBankImportacaoDeRetornoDeCobranca -StartupType Manual
# Set-Service -Name IntegrationBankImportacaoRetornoConciliacaoCartao -StartupType Manual
# Set-Service -Name IntegrationBankImpressaoDeBoleto -StartupType Manual
# Set-Service -Name IntegrationBankServiceMonitor -StartupType Manual
# Set-Service -Name IntegrationBankProcessamentoDeExtrato -StartupType Manual
# Set-Service -Name IntegrationBankProcessamentoDeRetornoDeCobranca -StartupType Manual
# Set-Service -Name IntegrationBankProcessamentoDeRetornoDeDda -StartupType Manual
# Set-Service -Name IntegrationBankProcessamentoDeRetornoDePagamento -StartupType Manual
# Set-Service -Name IntegrationBankRegistroDeBoletoOnlinePelaApi -StartupType Manual
# Set-Service -Name InvoiceOneSendCancel -StartupType Manual
# Set-Service -Name InvoiceOneSendEventService -StartupType Manual
# Set-Service -Name InvoiceOneSendDisablingService -StartupType Manual
# Set-Service -Name InvoiceOneSendService -StartupType Manual
# Set-Service -Name InvoiceOneImportDocumentNfse -StartupType Manual
# Set-Service -Name InvoiceOneImportDocument -StartupType Manual
# Set-Service -Name InvoiceOneImportDocumentByEmail -StartupType Manual
# Set-Service -Name InvoiceOneMonitorService -StartupType Manual
# Set-Service -Name InvoiceOneReturnCancelService -StartupType Manual
# Set-Service -Name InvoiceOneReturnEventService -StartupType Manual
# Set-Service -Name InvoiceOneReturnDisablingService -StartupType Manual
# Set-Service -Name InvoiceOneReturnService -StartupType Manual
# Set-Service -Name InvoiceOneApiObj -StartupType Manual
# Set-Service -Name InvoiceOneRegularidadeDoParceiroDoSap -StartupType Manual
# Set-Service -Name InvoiceOneRetornoApiObj -StartupType Manual
# Set-Service -Name TaxOneImportEcf -StartupType Manual
# Set-Service -Name InvoiceOneDfeChave -StartupType Manual
# Set-Service -Name InvoiceOneDfeNsu -StartupType Manual
# Set-Service -Name InvoiceOneDfeEvento -StartupType Manual
# Set-Service -Name InvoiceOneDfeIncluirDocSap -StartupType Manual
# Set-Service -Name InvoiceOneRecebimentoApi -StartupType Manual
# Set-Service -Name TaxOneNfseCancelService -StartupType Manual
# Set-Service -Name TaxOneNfseEmailService -StartupType Manual
# Set-Service -Name TaxOneNfseSendLoteServiceWs -StartupType Manual
# Set-Service -Name TaxOneNfseSendService -StartupType Manual
# Set-Service -Name TaxOneNfseMonitorService -StartupType Manual
# Set-Service -Name TaxOneNfseReSendService -StartupType Manual
# Set-Service -Name TaxOneNfseReturnLoteServiceWs -StartupType Manual
# Set-Service -Name TaxOneNfseRetornoTxt -StartupType Manual
# Set-Service -Name TaxOneNfseReturnService -StartupType Manual
