Param(
    [Parameter(Mandatory = $False)]
    [string]$AdminUrl = "https://sharepointinguk-admin.sharepoint.com/",
	
    [Parameter(Mandatory = $False)]
    [string]$siteurl = ""
)

$cred = Get-AutomationPSCredential -Name 'SharePointingUKAdmin'
Connect-SPOService -Url $AdminUrl $cred

$UserDetailsObj = @{
    'UserCount' = 0;
    'Details'   = ''
}

$ExternalUsers = New-Object psobject $UserDetailsObj
$FinalObject = New-Object psobject $UserDetailsObj

$SiteCollections = Get-SPOSite -Identity $siteurl


$ExternalUsers.Clear()
foreach ($site in $SiteCollections) {
    [array]$ExternalUsers += Get-SPOUser -Limit All -Site $site.Url `
        | Where-Object {$_.LoginName -like "*urn:spo:guest*" -or $_.LoginName -like "*#ext#*"} `
        | Select-Object  DisplayName, LoginName, @{Name = "Site" ; Expression = {$site.Url}},
    @{Name = "Title" ; Expression = {$site.Title}`
    
    }
    $UserDetailsObj.Details = $ExternalUsers
    $FinalObject.Details = $UserDetailsObj.Details | Where-Object { $_ -ne $null }
    $FinalObject.UserCount = $ExternalUsers.LoginName.Count

       
} 
   
Write-Output ( $FinalObject | ConvertTo-Json)

