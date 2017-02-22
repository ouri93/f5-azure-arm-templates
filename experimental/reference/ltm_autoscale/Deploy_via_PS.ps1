﻿## Script parameters being asked for below match to parameters in the azuredeploy.json file, otherwise pointing to the ##
## azuredeploy.parameters.json file for values to use.  Some options below are mandatory, some(such as region) can     ##
## be supplied inline when running this script but if they aren't then the default will be used as specificed below.   ##
## Example Command: .\Deploy_via_PS.ps1 -licenseType PAYG -licensedBandwidth 200m -vmScaleSetCapacity 2 -adminUsername azureuser -adminPassword <value> -dnsLabel <value> -instanceType Standard_D2_v2 -imageName Good -subscriptionId <value> -tenantId <value> -clientId <value> -servicePrincipalSecret <value> -restrictedSrcAddress "*"-resourceGroupName <value> 

param(

  [Parameter(Mandatory=$True)]
  [string]
  $licenseType,

  [string]
  $licensedBandwidth = $(if($licenseType -eq "PAYG") { Read-Host -prompt "licensedBandwidth"}),

  [string]
  $licenseKey1 = $(if($licenseType -eq "BYOL") { Read-Host -prompt "licenseKey1"}),

  [Parameter(Mandatory=$True)]
  [string]
  $vmScaleSetCapacity,

  [Parameter(Mandatory=$True)]
  [string]
  $adminUsername,

  [Parameter(Mandatory=$True)]
  [string]
  $adminPassword,

  [Parameter(Mandatory=$True)]
  [string]
  $dnsLabel,

  [Parameter(Mandatory=$True)]
  [string]
  $instanceType,

  [Parameter(Mandatory=$True)]
  [string]
  $imageName,

  [Parameter(Mandatory=$True)]
  [string]
  $subscriptionId,

  [Parameter(Mandatory=$True)]
  [string]
  $tenantId,

  [Parameter(Mandatory=$True)]
  [string]
  $clientId,

  [Parameter(Mandatory=$True)]
  [string]
  $servicePrincipalSecret,

  [string]
  $restrictedSrcAddress = "*",

  [Parameter(Mandatory=$True)]
  [string]
  $resourceGroupName,

  [string]
  $region = "West US",

  [string]
  $templateFilePath = "azuredeploy.json",

  [string]
  $parametersFilePath = "azuredeploy.parameters.json"
)

Write-Host "Disclaimer: Scripting to Deploy F5 Solution templates into Cloud Environments are provided as examples. They will be treated as best effort for issues that occur, feedback is encouraged." -foregroundcolor green
Start-Sleep -s 3

# Connect to Azure, right now it is only interactive login
try {
    Write-Host "Checking if already logged in!"
    Get-AzureRmSubscription | Out-Null
    Write-Host "Already logged in, continuing..."
    }
    Catch {
    Write-Host "Not logged in, please login..."
    Login-AzureRmAccount
    }

# Create Resource Group for ARM Deployment
New-AzureRmResourceGroup -Name $resourceGroupName -Location "$region"

# Create Arm Deployment
$pwd = ConvertTo-SecureString -String $adminPassword -AsPlainText -Force
$deployment = New-AzureRmResourceGroupDeployment -Name $resourceGroupName -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath -TemplateParameterFile $parametersFilePath -Verbose -vmScaleSetCapacity "$vmScaleSetCapacity" -adminUsername "$adminUsername" -adminPassword $pwd -dnsLabel "$dnsLabel" -instanceType "$instanceType" -imageName "$imageName" -subscriptionId "$subscriptionId" -tenantId "$tenantId" -clientId "$clientId" -servicePrincipalSecret "$servicePrincipalSecret" -restrictedSrcAddress "$restrictedSrcAddress"  -licensedBandwidth "$licensedBandwidth"

# Print Output of Deployment to Console
$deployment