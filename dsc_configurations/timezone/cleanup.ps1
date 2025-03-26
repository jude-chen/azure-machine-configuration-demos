$PolicyDisplayName = "Set Time Zone to Central Standard Time on Windows VMs"
Remove-AzPolicyDefinition -Name $PolicyDisplayName

Remove-Item .\SetTimeZoneCST.zip -Force
Remove-Item .\SetTimeZoneCST -Recurse -Force
Remove-Item .\policies -Recurse -Force