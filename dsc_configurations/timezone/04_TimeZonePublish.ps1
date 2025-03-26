$ResourceGroupName = "machineconfig-demo-rg"
$StorageContainerName = "machine-configurations"
$StorageAccountName = (Get-AzStorageAccount -ResourceGroupName $ResourceGroupName).StorageAccountName
$StorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName).Value[0]
$StorageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

$SetParams = @{
    Container = $StorageContainerName
    File      = ".\SetTimeZoneCST.zip"
    Context   = $StorageContext
}
$Blob = Set-AzStorageBlobContent @SetParams

Write-Output $Blob.ICloudBlob.Uri.AbsoluteUri