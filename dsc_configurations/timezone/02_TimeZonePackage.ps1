$params = @{
    Name          = 'SetTimeZoneCST'
    Configuration = '.\SetTimeZoneCST\localhost.mof'
    Type          = 'AuditandSet'
    Force         = $true
}

New-GuestConfigurationPackage @params