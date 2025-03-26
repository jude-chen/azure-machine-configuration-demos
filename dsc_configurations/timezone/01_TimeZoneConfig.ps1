Configuration SetTimeZoneCST {
    Import-DscResource -ModuleName ComputerManagementDsc -Name TimeZone

    TimeZone 'SetTimeZoneCST' {
        TimeZone         = 'Central Standard Time'
        IsSingleInstance = 'Yes'
    }
}

SetTimeZoneCST