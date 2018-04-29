

$AdminUrl = "https://sharepointinguk-admin.sharepoint.com/"
$cred = Get-AutomationPSCredential -Name 'SharePointingUKAdmin'
Connect-SPOService -Url $AdminUrl $cred


$siteurl = 'https://sharepointinguk.sharepoint.com/sites/admin'

$SiteCollections  = Get-SPOSite -Identity $siteurl
$ExternalUsers.Clear()
foreach ($site in $SiteCollections)
{
	[array]$ExternalUsers += Get-SPOUser -Limit All -Site $site.Url `
    | Where-Object {$_.LoginName -like "*urn:spo:guest*" -or $_.LoginName -like "*#ext#*"} `
    | Select-Object DisplayName,AcceptedAs, InvitedBy,LoginName,@{Name = "Url" ; Expression = { $site.Url }
	}

} 

Write-Output ( $ExternalUsers | ConvertTo-Json)
