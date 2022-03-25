
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

$delPermission1 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "5f8c59db-677d-491f-a6b8-5f174b11ec1d","Scope" # Group.Read.All (Groups)
$delPermission2 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "572fea84-0151-49b2-9301-11cb16974376","Scope" # Policy.Read.All (CA)
$delPermission3 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "c79f8feb-a9db-4090-85f9-90d820caa0eb","Scope" # Application.Read.All (CA)
$delPermission4 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "ad902697-1014-4ef5-81ef-2b4301988e8c","Scope" # Policy.ReadWrite.ConditionalAccess (CA)
$delPermission5 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "7b3f05d5-f68c-4b8d-8c59-a2ecd12f24af","Scope" # DeviceManagementApps.ReadWrite.All (MAM)
$delPermission6 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "662ed50a-ac44-4eef-ad86-62eed9be2a29","Scope" # DeviceManagementServiceConfig.ReadWrite.All (DER)
$delPermission7 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList "0883f392-0a7a-443d-8c76-16a6d39c7b63","Scope" # DeviceManagementConfiguration.ReadWrite.All


$reqGraph.ResourceAccess = $delPermission1, $delPermission2, $delPermission3, $delPermission4,$delPermission5,$delPermission6,$delPermission7


$CAAppReg = get-AzureADApplication -filter "DisplayName eq 'AAD Data PowerShell Tool'"

    if ($CAAppReg -eq $null)
        { 
            New-AzureADApplication -DisplayName "AAD Data PowerShell Tool" -PublicClient $true -ReplyUrls urn:ietf:wg:oauth:2.0:oob -RequiredResourceAccess $reqGraph
            Write-Host "Waiting for App Regitrationcls to be created (45 secs)" -ForegroundColor Yellow
            Start-Sleep -s 45
            

        }
    else 
        {
            Write-Host "AAD Data PowerShell Tool Tool already configured" -ForegroundColor Yellow
            Write-Host "App Registration ID is " $CAAppReg.appid -ForegroundColor Green

        }



