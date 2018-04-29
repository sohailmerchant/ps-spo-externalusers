Param(
    [Parameter(Mandatory = $False)]
    [string]$AdminUrl = "https://sharepointinguk-admin.sharepoint.com/",
	
    [Parameter(Mandatory = $False)]
    [string]$siteurl = "*"
)

$cred = Get-AutomationPSCredential -Name 'SharePointingUKAdmin'
Connect-SPOService -Url $AdminUrl $cred

if ($siteurl -eq "*") {
    $SiteCollections = Get-SPOSite -Limit All
}
else {
    $SiteCollections = Get-SPOSite -Identity $siteurl

}
$ExternalUsers.Clear()
foreach ($site in $SiteCollections) {
    [array]$ExternalUsers += Get-SPOUser -Limit All -Site $site.Url `
        | Where-Object {$_.LoginName -like "*urn:spo:guest*" -or $_.LoginName -like "*#ext#*"} `
        | Select-Object DisplayName, LoginName, @{Name = "Url" ; Expression = { $site.Url }
    }

}

Write-Output ( $ExternalUsers | ConvertTo-Json)
