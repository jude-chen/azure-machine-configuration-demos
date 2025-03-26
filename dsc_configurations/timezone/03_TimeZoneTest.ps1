# Test Get function
Get-GuestConfigurationPackageComplianceStatus .\SetTimeZoneCST.zip -Verbose

# Test Set function
Start-GuestConfigurationPackageRemediation .\SetTimeZoneCST.zip -Verbose
