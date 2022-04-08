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
	[String]$htmlfile
)

$body = ""
$html = ""

#Clear errors if any
$Error.Clear()

#Get Cluster Name
$Cluster = try { Get-Cluster -ErrorAction Stop }
catch { $_.Exception.Message }
$body += ($Cluster | Select-Object Name, Domain | ConvertTo-Html -Fragment)


#Get-ClusterNode
$ClusterNodes = try { Get-ClusterNode -ErrorAction Stop }
catch { }
$body += '<br><br>' + ($ClusterNodes | Select-Object Id, Name, State | ConvertTo-Html -Fragment)
$ClusterNodes_html = '<table><tr><td>Id</td><td>Name</td><td>State</td></tr>'

foreach ($ClusterNode in $ClusterNodes)
{
	$ClusterNodes_html += '<tr><td>' + $ClusterNode.Id + '</td><td>' + $ClusterNode.Name + '</td><td>' 
	if ($ClusterNode.State -eq "Up")
	{
		$ClusterNodes_html += '<span class="label success">Up</span>'
	}
	else
	{
		$ClusterNodes_html += '<span class="label danger">' + $ClusterNode.State + '</span>'
	}
	$ClusterNodes_html += '</td></tr>'
	
}
$ClusterNodes_html += '</table><br><br>'

foreach ($ClusterNode in $ClusterNodes)
{
	if ($ClusterNode.State -eq "Up")
	{
		$ClusterNodes_image_html += '<?xml version="1.0" encoding="utf-8"?>
		<svg viewBox="0 0 490 490" xmlns="http://www.w3.org/2000/svg">
		  <path d="m445,460h-24.998v-445c0-8.284-6.716-15-15-15h-320.002c-8.284,0-15,6.716-15,15v445h-25c-8.284,0-15,6.716-15,15s6.716,15 15,15h400c8.284,0 15-6.716 15-15s-6.716-15-15-15zm-54.998,0h-290.002v-430h290.002v430zm-245-160h199.998c8.284,0 15-6.716 15-15v-210c0-8.284-6.716-15-15-15h-199.998c-8.284,0-15,6.716-15,15v210c0,8.284 6.716,15 15,15zm15-210h169.998v40h-169.998v-40zm0,70h169.998v40h-169.998v-40zm0,70h169.998v40h-169.998v-40zm84.998,107.497c-24.813,0-44.999,20.188-44.999,45.004 0,24.813 20.188,45.001 45.001,45.001 24.813,0 44.999-20.188 44.999-45.004-5.68434e-14-24.813-20.188-45.001-45.001-45.001zm0,60.005c-8.271,0-14.999-6.729-14.999-15.004 0-8.271 6.729-15.001 14.999-15.001h0.002c8.271,0 14.999,6.729 14.999,15.004-5.68434e-14,8.271-6.73,15.001-15.001,15.001z" style="fill: rgb(0, 255, 0);"/>
		</svg>'
	}
	else
	{
		$ClusterNodes_image_html += '<?xml version="1.0" encoding="utf-8"?>
		<svg viewBox="0 0 490 490" xmlns="http://www.w3.org/2000/svg">
		  <path d="m445,460h-24.998v-445c0-8.284-6.716-15-15-15h-320.002c-8.284,0-15,6.716-15,15v445h-25c-8.284,0-15,6.716-15,15s6.716,15 15,15h400c8.284,0 15-6.716 15-15s-6.716-15-15-15zm-54.998,0h-290.002v-430h290.002v430zm-245-160h199.998c8.284,0 15-6.716 15-15v-210c0-8.284-6.716-15-15-15h-199.998c-8.284,0-15,6.716-15,15v210c0,8.284 6.716,15 15,15zm15-210h169.998v40h-169.998v-40zm0,70h169.998v40h-169.998v-40zm0,70h169.998v40h-169.998v-40zm84.998,107.497c-24.813,0-44.999,20.188-44.999,45.004 0,24.813 20.188,45.001 45.001,45.001 24.813,0 44.999-20.188 44.999-45.004-5.68434e-14-24.813-20.188-45.001-45.001-45.001zm0,60.005c-8.271,0-14.999-6.729-14.999-15.004 0-8.271 6.729-15.001 14.999-15.001h0.002c8.271,0 14.999,6.729 14.999,15.004-5.68434e-14,8.271-6.73,15.001-15.001,15.001z" style="fill: rgb(255, 0, 0);"/>
		</svg>'
	}
	$ClusterNodes_image_html += '&nbsp;&nbsp;'
	
}


#PhysicalDisk
$PhysicalDisks = try { Get-PhysicalDisk -ErrorAction Stop | Where-Object { $_.DeviceId -match "\w{4}" -or !($_.DeviceId) } }
catch { }
$body += '<br><br>' + ($PhysicalDisks | Select-Object DeviceId, UniqueId, Manufacturer, Model, SerialNumber, CannotPoolReason, Size, Usage, OperationalStatus, HealthStatus | ConvertTo-Html -Fragment)

$PhysicalDisks_html += '<table><tr><th>DeviceId</th><th>UniqueId </th><th>Manufacturer </th><th>Model </th><th>SerialNumber </th><th>CannotPoolReason </th><th>Size </th><th>Usage </th><th>OperationalStatus </th><th>HealthStatus </th></tr>'
foreach ($PhysicalDisk in $PhysicalDisks)
{
	$PhysicalDisks_html += '<tr><td>' + $PhysicalDisk.DeviceId + '</td><td>' + $PhysicalDisk.UniqueId + '</td><td>' + $PhysicalDisk.Manufacturer + '</td><td>' + $PhysicalDisk.Model + '</td><td>' + $PhysicalDisk.SerialNumber + '</td><td>' + $PhysicalDisk.CannotPoolReason + '</td><td>' + [Math]::Round($PhysicalDisk.Size/1GB) + ' GB</td><td>' + $PhysicalDisk.Usage + '</td><td>' + $PhysicalDisk.OperationalStatus + '</td><td>'
	if ($PhysicalDisk.HealthStatus -ne "Healthy") { $html += '<span class="label danger">' + $PhysicalDisk.HealthStatus + '</span>' }
	else { $PhysicalDisks_html += '<span class="label success">' + $PhysicalDisk.HealthStatus + '</span>' + '</td><tr>' }	
}

$PhysicalDisks_html += '</table><br><br>'


#VirtualDisks
$VirtualDisks = try { Get-VirtualDisk -ErrorAction Stop }
catch { }
$body += '<br><br>' + ($VirtualDisks | Select-Object FriendlyName, OperationalStatus, HealthStatus, Size, FootprintOnPool | ConvertTo-Html -Fragment)

$VirtualDisks_html = '<table><tr><th>FriendlyName</th><th>OperationalStatus</th><th>HealthStatus</th><th>Size</th><th>FootprintOnPool</th></tr>'
foreach ($VirtualDisk in $VirtualDisks)
{
	$VirtualDisks_html += '<tr><td>' + $VirtualDisk.FriendlyName + '</td><td>' 
	if($VirtualDisk.OperationalStatus -ne "OK")
	{
		$VirtualDisks_html += '<span class="label danger">' + $VirtualDisk.OperationalStatus + '</span>'
	}
	else{
		$VirtualDisks_html += '<span class="label success">' + $VirtualDisk.OperationalStatus + '</span>'
	}
	$VirtualDisks_html +=  '</td><td>' + $VirtualDisk.HealthStatus + '</td><td>' + [Math]::Round($VirtualDisk.Size/1GB) + ' GB</td><td>' + [Math]::Round($VirtualDisk.FootprintOnPool/1GB) + '</td></tr>'
}

$VirtualDisks_html += '</table><br><br>'


#Get-VM details
$VMs = Get-ClusterGroup | Where-Object {$_.GroupType -eq "VirtualMachine"} | Select-Object Name, OwnerNode, State
$body += '<br><br>' + ($VMs | ConvertTo-Html -Fragment)

$VMs_html = '<table><tr><th>Name</th><th>OwnerNode</th><th>State</th></tr>'
foreach($vm in $VMs)
{
	$VMs_html += '<tr><td>' + $vm.Name + '</td><td>' + $vm.OwnerNode + '</td><td>' 
	if($vm.State -eq "Online")
	{
		$VMs_html += '<span class="label success">' + $vm.State + '</span>'
	}
	else {
		$VMs_html += '<span class="label danger">' + $vm.State + '</span>'
	}

	$VMs_html += '</td></tr>'
}
$VMs_html += '</table><br><br>'

#Get disks not in S2D pool
$Disksnotinpool = $PhysicalDisks | Where-Object {$_.CannotPoolReason -ne "In a Pool"}

if($Disksnotinpool)
{
	$body += 'Disks not in S2DPool<br>' + ($Disksnotinpool | Select-Object DeviceId, OperationalStatus, HealthStatus, CannotPoolReason | ConvertTo-Html -Fragment)
	$html += '<span class="label danger">Disks not in S2DPool</span>'
	$html += '<span class="label danger">' + ($Disksnotinpool | Out-String) + '</span>'
}

################Start html file #####################
#####################################################

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
$html += $ClusterNodes_html
$html += @'
	</td>
      <td>
		  <div class="perfgraph">
'@

$html += $ClusterNodes_image_html

$html += @'
		  </div>
	  </td>
    </tr>
  </table>

  <br><br>
'@

#Physical Disks
$html += $PhysicalDisks_html

#Virtual Disks
$html += $VirtualDisks_html

#Virtual machines
$html += $VMs_html

$html += @'
<br><br><br><br>
  <div class="footer">
    <p>Report generated at 
'@
$html += (Get-Date -Format "yyyy-MM-dd HH:mm:ss").ToString() + " " + (Get-TimeZone).Id.ToString()
$html += @'
	</p>
  </div>
</body>

</html>
'@

#$username = "admin@winadmin.org"
#$password = "creMa6u7!"
#[SecureString]$secureString = $password | ConvertTo-SecureString -AsPlainText -Force
#[PSCredential]$secureCredentials = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureString

$html | Out-File $htmlfile
$body | Out-File body.txt
Write-Host $body

#Send-MailMessage -From "admin@winadmin.org" -To "admin@winadmin.org" -Subject ("Hyper-V CLuster Health Check Report - " + $ClusterName) -Body $($body) -SmtpServer mail.winadmin.org -BodyAsHtml -UseSsl -Credential $secureCredentials -Attachments HealthCheckReport.html
# Create the message
#Remove-Item HealthCheckReport.html -Force
#Remove-Item body.txt