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
	[String]$htmlfile,
	[String]$mailbody
)

$mail_body = "<style> .success2 { font: italic bold; color: green; } .error2 { font: italic bold; color: red; } </style>"
$html = ""

#Clear errors if any
$Error.Clear()

#Get Cluster Name
$Cluster = try { Get-Cluster -ErrorAction Stop }
catch { $_.Exception.Message }
$mail_body += ($Cluster | Select-Object Name, Domain | ConvertTo-Html -Fragment)

if($Error)
{
	$mail_body += $Error[0].ToString()
}
else 
{
	#Get-ClusterNode
	$Error.Clear()
	$ClusterNodes = try { Get-ClusterNode -ErrorAction Stop }
	catch { }

	if($Error)
	{
		$ClusterNodes_html += $Error[0].ToString()
		$mail_body += $Error[0].ToString()
	}
	else 
	{
		$mail_body += '<br><br>' + ($ClusterNodes | Select-Object Id, Name, State | ConvertTo-Html -Fragment)

		$ClusterNodes_html = '<table><tr><td>Id</td><td>Name</td><td>State</td></tr>'

		foreach ($ClusterNode in $ClusterNodes)
		{
			$ClusterNodes_html += '<tr><td>' + $ClusterNode.Id + '</td><td>' + $ClusterNode.Name + '</td>' 
			if ($ClusterNode.State -eq "Up")
			{
				$ClusterNodes_html += '<td bgcolor="green"><span class="label success">Up</span></td>'
			}
			else
			{
				$ClusterNodes_html += '<td bgcolor="red"><span class="label error">' + $ClusterNode.State + '</span></td>'
			}
			$ClusterNodes_html += '</tr>'
			
		}
		$ClusterNodes_html += '</table><br><br>'

		foreach ($ClusterNode in $ClusterNodes)
		{
			if ($ClusterNode.State -eq "Up")
			{
				$ClusterNodes_image_html += '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" id="body_1" width="51" height="38">
				<g transform="matrix(0.07755102 0 0 0.07755102 6.500001 -0)">
					<path d="M445 460L420.002 460L420.002 15C 420.002 6.7159996 413.286 0 405.002 0L405.002 0L85 0C 76.716 0 70 6.716 70 15L70 15L70 460L45 460C 36.716 460 30 466.716 30 475C 30 483.284 36.716 490 45 490L45 490L445 490C 453.284 490 460 483.284 460 475C 460 466.716 453.284 460 445 460zM390.002 460L100 460L100 30L390.002 30L390.002 460zM145.00201 300L345 300C 353.284 300 360 293.284 360 285L360 285L360 75C 360 66.716 353.284 60 345 60L345 60L145.002 60C 136.718 60 130.002 66.716 130.002 75L130.002 75L130.002 285C 130.002 293.284 136.718 300 145.002 300zM160.00201 90L330 90L330 130L160.002 130L160.002 90zM160.00201 160L330 160L330 200L160.002 200L160.002 160zM160.00201 230L330 230L330 270L160.002 270L160.002 230zM245.00002 337.497C 220.18701 337.497 200.001 357.685 200.001 382.501C 200.001 407.314 220.18901 427.502 245.00201 427.502C 269.815 427.502 290.001 407.31403 290.001 382.49802C 290.001 357.68503 269.81302 337.497 245 337.497zM245.00002 397.502C 236.72902 397.502 230.00102 390.773 230.00102 382.49802C 230.00102 374.22702 236.73003 367.497 245.00002 367.497L245.00002 367.497L245.00201 367.497C 253.27301 367.497 260.001 374.226 260.001 382.501C 260.001 390.772 253.27101 397.502 245 397.502z" stroke="none" fill="#00FF00" fill-rule="nonzero" />
				</g>
				</svg>'
			}
			else
			{
				$ClusterNodes_image_html += '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" id="body_1" width="51" height="38">
				<g transform="matrix(0.07755102 0 0 0.07755102 6.500001 -0)">
					<path d="M445 460L420.002 460L420.002 15C 420.002 6.7159996 413.286 0 405.002 0L405.002 0L85 0C 76.716 0 70 6.716 70 15L70 15L70 460L45 460C 36.716 460 30 466.716 30 475C 30 483.284 36.716 490 45 490L45 490L445 490C 453.284 490 460 483.284 460 475C 460 466.716 453.284 460 445 460zM390.002 460L100 460L100 30L390.002 30L390.002 460zM145.00201 300L345 300C 353.284 300 360 293.284 360 285L360 285L360 75C 360 66.716 353.284 60 345 60L345 60L145.002 60C 136.718 60 130.002 66.716 130.002 75L130.002 75L130.002 285C 130.002 293.284 136.718 300 145.002 300zM160.00201 90L330 90L330 130L160.002 130L160.002 90zM160.00201 160L330 160L330 200L160.002 200L160.002 160zM160.00201 230L330 230L330 270L160.002 270L160.002 230zM245.00002 337.497C 220.18701 337.497 200.001 357.685 200.001 382.501C 200.001 407.314 220.18901 427.502 245.00201 427.502C 269.815 427.502 290.001 407.31403 290.001 382.49802C 290.001 357.68503 269.81302 337.497 245 337.497zM245.00002 397.502C 236.72902 397.502 230.00102 390.773 230.00102 382.49802C 230.00102 374.22702 236.73003 367.497 245.00002 367.497L245.00002 367.497L245.00201 367.497C 253.27301 367.497 260.001 374.226 260.001 382.501C 260.001 390.772 253.27101 397.502 245 397.502z" stroke="none" fill="#FF0000" fill-rule="nonzero" />
				</g>
				</svg>'
			}
			$ClusterNodes_image_html += '&nbsp;&nbsp;'
		}
	}
	

	#PhysicalDisk
	$Error.Clear()
	$PhysicalDisks = try { Get-PhysicalDisk -ErrorAction Stop | Where-Object { $_.DeviceId -match "\w{4}" -or !($_.DeviceId) } }
	catch { }
	if($Error)
	{
		$PhysicalDisks_html += $Error[0].ToString()
		$mail_body += $Error[0].ToString()
	}
	else 
	{
		$mail_body += '<br><br>' + ($PhysicalDisks | Select-Object DeviceId, UniqueId, Manufacturer, Model, SerialNumber, CannotPoolReason, Size, Usage, OperationalStatus, HealthStatus | ConvertTo-Html -Fragment)

		$PhysicalDisks_html += '<table><tr><th>DeviceId</th><th>UniqueId </th><th>Manufacturer </th><th>Model </th><th>SerialNumber </th><th>CannotPoolReason </th><th>Size </th><th>Usage </th><th>OperationalStatus </th><th>HealthStatus </th></tr>'
		foreach ($PhysicalDisk in $PhysicalDisks)
		{
			$PhysicalDisks_html += '<tr><td>' + $PhysicalDisk.DeviceId + '</td><td>' + $PhysicalDisk.UniqueId + '</td><td>' + $PhysicalDisk.Manufacturer + '</td><td>' + $PhysicalDisk.Model + '</td><td>' + $PhysicalDisk.SerialNumber + '</td><td>' + $PhysicalDisk.CannotPoolReason + '</td><td>' + [Math]::Round($PhysicalDisk.Size/1GB) + ' GB</td><td>' + $PhysicalDisk.Usage + '</td><td>' + $PhysicalDisk.OperationalStatus + '</td>'
			if ($PhysicalDisk.HealthStatus -ne "Healthy") { $PhysicalDisks_html += '<td bgcolor="red"><span class="label error">' + $PhysicalDisk.HealthStatus + '</span></td>' }
			else { $PhysicalDisks_html += '<td bgcolor="green"><span class="label success">' + $PhysicalDisk.HealthStatus + '</span></td>' }
			$PhysicalDisks_html += '<tr>'
		}

		$PhysicalDisks_html += '</table><br><br>'
	}
	


	#VirtualDisks
	$Error.Clear()
	$VirtualDisks = try { Get-VirtualDisk -ErrorAction Stop }
	catch { }
	if($Error)
	{
		$VirtualDisks_html = $Error[0].ToString()
		$mail_body += $Error[0].ToString()
	}
	else 
	{
		$mail_body += '<br><br>' + ($VirtualDisks | Select-Object FriendlyName, OperationalStatus, HealthStatus, Size, FootprintOnPool | ConvertTo-Html -Fragment)

		$VirtualDisks_html = '<table><tr><th>FriendlyName</th><th>OperationalStatus</th><th>HealthStatus</th><th>Size</th><th>FootprintOnPool</th></tr>'
		foreach ($VirtualDisk in $VirtualDisks)
		{
			$VirtualDisks_html += '<tr><td>' + $VirtualDisk.FriendlyName + '</td>' 
			if($VirtualDisk.OperationalStatus -ne "OK")
			{
				$VirtualDisks_html += '<td bgcolor="red"><span class="label error">' + $VirtualDisk.OperationalStatus + '</span></td>'
			}
			else{
				$VirtualDisks_html += '<td bgcolor="green"><span class="label success">' + $VirtualDisk.OperationalStatus + '</span></td>'
			}
			$VirtualDisks_html +=  '<td>' + $VirtualDisk.HealthStatus + '</td><td>' + [Math]::Round($VirtualDisk.Size/1GB) + ' GB</td><td>' + [Math]::Round($VirtualDisk.FootprintOnPool/1GB) + '</td></tr>'
		}

		$VirtualDisks_html += '</table><br><br>'
	}
	


	#Get-VM details
	$Error.Clear()
	$VMs = try { Get-ClusterGroup | Where-Object {$_.GroupType -eq "VirtualMachine"} | Select-Object Name, OwnerNode, State } catch {}
	if($Error)
	{
		$VMs_html = $Error[0].ToString()
		$mail_body += $Error[0].ToString()
	}
	else
	{
		$mail_body += '<br><br>' + ($VMs | ConvertTo-Html -Fragment)

		$VMs_html = '<table><tr><th>Name</th><th>OwnerNode</th><th>State</th></tr>'
		foreach($vm in $VMs)
		{
			$VMs_html += '<tr><td>' + $vm.Name + '</td><td>' + $vm.OwnerNode + '</td>' 
			if($vm.State -eq "Online")
			{
				$VMs_html += '<td bgcolor="green"><span class="label success">' + $vm.State + '</span></td>'
			}
			else {
				$VMs_html += '<td bgcolor="red"><span class="label error">' + $vm.State + '</span></td>'
			}

			$VMs_html += '</tr>'
		}
		$VMs_html += '</table><br><br>'
	}
	

	#Get disks not in S2D pool
	$Disksnotinpool = $PhysicalDisks | Where-Object {$_.CannotPoolReason -ne "In a Pool"}

	if($Disksnotinpool)
	{
		$mail_body += 'Disks not in S2DPool<br>' + ($Disksnotinpool | Select-Object DeviceId, OperationalStatus, HealthStatus, CannotPoolReason | ConvertTo-Html -Fragment)
		$html += '<span class="label error">Disks not in S2DPool</span>'
		$html += '<span class="label error">' + ($Disksnotinpool | Out-String) + '</span>'
	}
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
	.error { background-color: #f44336;border-radius: 0.5em; }
	.footer { position: fixed;left: 0;bottom: 0;width: 100%;background-color: black;color: white;text-align: center;}
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

$html | Out-File $htmlfile
#$mail_body | Out-File $mailbody
$html | Out-File $mailbody