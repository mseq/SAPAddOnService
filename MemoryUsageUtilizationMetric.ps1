#IP and Port that StatsD listen to
$ipAddress=[System.Net.IPAddress]::Parse("127.0.0.1")
$port=8125
$dt = get-date -Format G
$LogSource = "MemUsageCWMetric"

#Create EventLog

New-EventLog -LogName Application -Source $LogSource

#Your Custom Metric Name
$MetricName="MemoryUtilization"

# Write-Host $ipAddress $port
# Write-Host $MetricName

#Calculate the percentage for the Memory Utilization (Used Percentage)
$ComputerMemory = Get-WmiObject -ComputerName $env:computername -Class win32_operatingsystem -ErrorAction Stop

# Write-Host $env:computername
# Write-Host $ComputerMemory

$MemoryUtilization=[math]::Round(((($ComputerMemory.TotalVisibleMemorySize - $ComputerMemory.FreePhysicalMemory)*100)/ $ComputerMemory.TotalVisibleMemorySize), 2)

# Write-Host $ComputerMemory.TotalVisibleMemorySize
# Write-Host $ComputerMemory.FreePhysicalMemory
# Write-Host $ComputerMemory.TotalVisibleMemorySize

#Formulate the message to send to StatusD 'MetricName:Value|MetricType'
$Message=$MetricName+":"+$MemoryUtilization+"|g"

Write-EventLog -LogName Application -Source $LogSource -EntryType Information -EventId 1 -Message "$($dt):> $Message"


#Create and UDP Connection endpoint and client
$endPoint=New-Object System.Net.IPEndPoint($ipAddress, $port)
$UDPClient=New-Object System.Net.Sockets.UdpClient

# Write-Host $endPoint
# Write-Host $UDPClient

#Encode and send the data to UDP server
$encodedData=[System.Text.Encoding]::ASCII.GetBytes($Message)
$null=$UDPClient.Send($encodedData,$encodedData.length,$endPoint)

#Close UDP connection
$UDPClient.Close()
