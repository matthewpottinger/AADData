
Function Set-AADAuth {
    <#
    .SYNOPSIS
    This function is used to authenticate with the Azure AD interface
    .DESCRIPTION
    The function authenticate with the Azure AD Interface with the tenant name
    .EXAMPLE
    Set-AADAuth
    Authenticates you with the Azure AD interface
    .NOTES
    NAME: Set-AADAuth
    #>
    
    [cmdletbinding()]
    
    param
    (
        #[Parameter(Mandatory=$true)]
        #$User
    )
    
    Write-Host "Checking for AzureAD module..."
    
        $AadModule = Get-Module -Name "AzureADPreview" -ListAvailable
    
        if ($AadModule -eq $null) {
            write-host
            write-host "AzureADPreview Powershell module not installed..." -f Red
            write-host "Attempting module install now" -f Red
            Install-Module -Name AzureADPreview -AllowClobber -Force
            #write-host "Install by running 'Install-Module AzureAD' or 'Install-Module AzureADPreview' from an elevated PowerShell prompt" -f Yellow
            #write-host "Script can't continue..." -f Red
            write-host
            #exit
        }
        Import-Module -Name "AzureADPreview" ###EFCOMMENT### Important to import the correct module if both are installed
        Connect-AzureAD
    
    }
    
####################################################
###EFCOMMENT### Script needs this to stand alone    
   Set-AADAuth
    
####################################################
    
    

$svcprincipal = Get-AzureADServicePrincipal -All $true | ? { $_.DisplayName -eq "Microsoft Graph" }
 
### Microsoft Graph
$reqGraph = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess"
$reqGraph.ResourceAppId = $svcprincipal.AppId

$delPermission1 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "e4c9e354-4dc5-45b8-9e7c-e1393b0b1a20","Scope" #AuditLog.Read.All
$delPermission2 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "a154be20-db9c-4678-8ab7-66f6cc099a59","Scope" #User.Read.All



$reqGraph.ResourceAccess = $delPermission1,$delPermission2


$AppReg = get-AzureADApplication -filter "DisplayName eq 'AAD Data PowerShell Tool'"

    if ($AppReg -eq $null)
        { 
            New-AzureADApplication -DisplayName "AAD Data PowerShell Tool" -PublicClient $true -ReplyUrls urn:ietf:wg:oauth:2.0:oob -RequiredResourceAccess $reqGraph
            Write-Host "Waiting for App Regitrationcls to be created (45 secs)" -ForegroundColor Yellow
            Start-Sleep -s 45
            

        }
    else 
        {
            Write-Host "AAD Data PowerShell Tool Tool already configured" -ForegroundColor Yellow
            Write-Host "App Registration ID is " $AppReg.appid -ForegroundColor Green

        }



