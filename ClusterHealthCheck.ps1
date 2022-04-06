<#	
	.NOTES
	===========================================================================
	 Created on:   	03-04-2022 02:28
	 Created by:   	Wintel
	 Organization: 	
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		Checks Cluster Health and sends html report to email
#>


param
(
	[parameter(Mandatory = $true)]
	[String]$ClusterName
)

$body = ""
$html = ""

#Clear errors if any
$Error.Clear()

#Get Cluster Name
$Cluster = try { Get-Cluster -ErrorAction Stop }
catch { $_.Exception.Message }
$body = ($Cluster | Select-Object Name, Domain | ConvertTo-Html -Fragment)


#Get-ClusterNode
$ClusterNodes = try { Get-ClusterNode -ErrorAction Stop }
catch { }
$body += ($ClusterNodes | Select-Object Id, Name, State | ConvertTo-Html -Fragment)

#PhysicalDisk
$PhysicalDisks = try { Get-PhysicalDisk -ErrorAction Stop | Where-Object { $_.DeviceId -match "\w{4}" -or !($_.DeviceId) } }
catch { }
$body += ($PhysicalDisks | Select-Object DeviceId, UniqueId, Manufacturer, Model, SerialNumber, CannotPoolReason, Size, Usage, OperationalStatus, HealthStatus | ConvertTo-Html -Fragment)

#VirtualDisks
$VirtualDisks = try { Get-VirtualDisk -ErrorAction Stop }
catch { }
$body += ($VirtualDisks | Select-Object FriendlyName, OperationalStatus, HealthStatus, Size, FootprintOnPool | ConvertTo-Html -Fragment)

$html  = @'
<!DOCTYPE html>
<html>

<head>
  <title>
'@
$html += "Cluster Health Check Report - " + $Cluster.Name
$html += @'
</title>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <style>
    body { font-family: Arial, sans-serif; }
    .navbar { padding-top: 15px;padding-bottom: 15px;border: 1;border-radius: 0.5;margin-bottom: 0;font-size: 12px;letter-spacing: 5px;background-color: black;}
	.heading { color: blanchedalmond;font-size: large;text-align: center;}
	.container { border: 1px solid black;margin: 20px;padding: 20px;}
	table { width: 80%;border-collapse: collapse;margin-left: auto;margin-right: auto;}
	table,td,th { border: 1px solid #ddd;text-align: left;margin-top: 1em;}
	th,td { padding: 15px; }
	tr:hover { background-color: #f5f5f5; }
	th { background-color: black;color: white; }
	.label { color: white;padding: 5px; }
	.success { background-color: #4CAF50;border-radius: 0.5em; }
	.warning { background-color: #ff9800;border-radius: 0.5em; }
	.danger { background-color: #f44336;border-radius: 0.5em; }
	.tooltip .tooltiptext { visibility: hidden;width: 120px;background-color: black;color: #fff;text-align: center;border-radius: 6px;padding: 5px 0;position: absolute;z-index: 1;}
	.tooltip:hover .tooltiptext { visibility: visible;}
	.footer { position: fixed;left: 0;bottom: 0;width: 100%;background-color: black;color: white;text-align: center;}
	.graph .labels.x-labels { text-anchor: middle; }
	.graph .labels.y-labels { text-anchor: end; }
	.graph { height: 500px;width: 800px; }
	.graph .grid { stroke: #ccc;stroke-dasharray: 0;stroke-width: 1; }
	.labels { font-size: 13px; }
	.label-title { font-weight: bold;font-size: 12px;fill: black; }
	.label-title-x { writing-mode: vertical-lr;text-orientation: upright; }
	div.perfgraph { width: 80%;margin-left: auto;margin-right: auto; }
  </style>
</head>

<body>
  <nav class="navbar heading"><strong>Cluster Health Check Report - 
'@
$html += $Cluster.Name
$html += @'

</strong></nav>
  <table>
    <tr>
      <th colspan="2">Cluster Nodes</th>
    </tr>
    <tr>
      <td>
'@
$html += '<table><tr><td>Id</td><td>Name</td><td>State</td></tr>'
foreach ($ClusterNode in $ClusterNodes)
{
	$html += '<tr><td>' + $ClusterNode.Id + '</td><td>' + $ClusterNode.Name + '</td><td>' 
	if ($ClusterNode.State -eq "Up")
	{
		$html += '<span class="label success">Up</span>'
	}
	else
	{
		$html += '<span class="label danger">' + $ClusterNode.State + '</span>'
	}
	$html += '</td></tr>'
	
}
$html += '</table>'

#$html += $ClusterNodes | Select-Object Id, Name, State | ConvertTo-Html -Fragment
$html += @'
	</td>
      <td>
		  <div class="perfgraph">
		    <svg height="200" width="200" viewBox="0 0 20 20">
		      <circle r="10" cx="10" cy="10" fill="Green" />
		      <circle r="5" cx="10" cy="10" fill="transparent" stroke="red" stroke-width="10"
		        stroke-dasharray="calc(25 * 31.4 / 100) 31.4" transform="rotate(-90) translate(-20)" />
		    </svg>
		  </div>
	  </td>
    </tr>
  </table>

  <br><br>
	<table>
'@

#Physical Disks
$html += '<tr><th>DeviceId</th><th>UniqueId </th><th>Manufacturer </th><th>Model </th><th>SerialNumber </th><th>CannotPoolReason </th><th>Size </th><th>Usage </th><th>OperationalStatus </th><th>HealthStatus </th></tr>'
foreach ($PhysicalDisk in $PhysicalDisks)
{
	$html += '<tr><td>' + $PhysicalDisk.DeviceId + '</td><td>' + $PhysicalDisk.UniqueId + '</td><td>' + $PhysicalDisk.Manufacturer + '</td><td>' + $PhysicalDisk.Model + '</td><td>' + $PhysicalDisk.SerialNumber + '</td><td>' + $PhysicalDisk.CannotPoolReason + '</td><td>' + [Math]::Round($PhysicalDisk.Size/1GB) + ' GB</td><td>' + $PhysicalDisk.Usage + '</td><td>'
	if ($PhysicalDisk.OperationalStatus -ne "OK") { $html += '<span class="label danger">' + $PhysicalDisk.OperationalStatus + '</span>' }
	else { $html += '<span class="label success">' + $PhysicalDisk.OperationalStatus + '</span>' }
	$html += '</td><td>' + $PhysicalDisk.HealthStatus + '</td><tr>'
	
}

$html += @'

	</table>
<br><br>

<table>
'@

#Virtual Disks
$html += '<tr><th>FriendlyName</th><th>OperationalStatus</th><th>HealthStatus</th><th>Size</th><th>FootprintOnPool</th></tr>'
foreach ($VirtualDisk in $VirtualDisks)
{
	$html += '<tr><td>' + $VirtualDisk.FriendlyName + '</td><td>' + $VirtualDisk.OperationalStatus + '</td><td>' + $VirtualDisk.HealthStatus + '</td><td>' + [Math]::Round($VirtualDisk.Size/1GB) + ' GB</td><td>' + [Math]::Round($VirtualDisk.FootprintOnPool/1GB) + '</td></tr>'
}

$html += @'

</table>

<br><br><br><br>


  <div class="footer">
    <p>Report generated at 
'@
Get-Date -Format "yyyy-MM-dd HH-mm-ss"
$html += @'
	</p>
  </div>
</body>

</html>

'@

$username = "admin@winadmin.org"
$password = "creMa6u7!"
[SecureString]$secureString = $password | ConvertTo-SecureString -AsPlainText -Force
[PSCredential]$secureCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureString

$html | Out-File HealthCheckReport.html
$body | Out-File body.txt
Write-Host $body

Send-MailMessage -From "admin@winadmin.org" -To "admin@winadmin.org" -Subject ("Hyper-V CLuster Health Check Report - " + $ClusterName) -Body $($body) -SmtpServer mail.winadmin.org -BodyAsHtml -UseSsl -Credential $secureCredentials -Attachments HealthCheckReport.html
# Create the message
Remove-Item HealthCheckReport.html -Force