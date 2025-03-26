$ResourceGroupName = "machineconfig-demo-rg"
$StorageContainerName = "machine-configurations"
$BlobName = "SetTimeZoneCST.zip"
$PolicyDisplayName = "Set Time Zone to Central Standard Time on Windows VMs"
$PolicyDescription = "Set Time Zone to Central Standard Time on Windows VMs using Machine Configuration"
# Update with your own resource ID value
$UserManagedIdentityResourceId = ""

if (-not $UserManagedIdentityResourceId) {
    Write-Error "UserManagedIdentityResourceId variable is not set. Please update the script with your own resource ID value."
    exit
}
else {
    $StorageAccountName = (Get-AzStorageAccount -ResourceGroupName $ResourceGroupName).StorageAccountName
    $StorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName).Value[0]
    $StorageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
    $Blob = Get-AzStorageBlob -Container $StorageContainerName -Blob $BlobName -Context $StorageContext
    $ContentUri = $Blob.ICloudBlob.Uri.AbsoluteUri

    $Policy_Guid = New-Guid

    $PolicyConfig = @{
        PolicyId                  = $Policy_Guid
        ContentUri                = $ContentUri
        DisplayName               = $PolicyDisplayName
        Description               = $PolicyDescription
        Path                      = "./policies/deployIfNotExists"
        Platform                  = "Windows"
        PolicyVersion             = "1.0.0"
        Mode                      = "ApplyAndAutoCorrect"
        LocalContentPath          = $BlobName      # Required parameter for managed identity
        ManagedIdentityResourceId = $UserManagedIdentityResourceId
    }

    New-GuestConfigurationPolicy @PolicyConfig -ExcludeArcMachines
    $PolicyDefiniton = New-AzPolicyDefinition -Name $PolicyDisplayName -Policy "./policies/deployIfNotExists/SetTimeZoneCST_DeployIfNotExists.json"
    $ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName
    $PolicyAssignment = New-AzPolicyAssignment -Name $PolicyDisplayName -PolicyDefinition $PolicyDefiniton -Scope $ResourceGroup.ResourceId -IdentityType SystemAssigned -Location $ResourceGroup.Location
    New-AzRoleAssignment -ObjectId $PolicyAssignment.IdentityPrincipalId -RoleDefinitionName "Guest Configuration Resource Contributor" -Scope $ResourceGroup.ResourceId
}