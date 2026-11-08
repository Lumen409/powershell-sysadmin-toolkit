#SYNOPSIS
#    Detects if Windows Telemetry is turned on
#DESCRIPTION
#    Specifically checks the registry path for the Windows Telemetry but looking in the two most common places.
#NOTES
#    Author: Lumen409
#    Tested on: Windows 11, PowerShell 5.1

# Checks both the GPO path and the MDM/Intune path
$paths = @(
    'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection',
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection'
)

$val = $null
foreach ($p in $paths) {
    $v = (Get-ItemProperty -Path $p -Name AllowTelemetry -ErrorAction SilentlyContinue).AllowTelemetry
    if ($null -ne $v) { $val = $v; break }
}

$status = if ($val -eq 1)         { 'Compliant' }
          elseif ($null -eq $val) { 'NotConfigured' }
          else                    { "Value=$val" }

[PSCustomObject]@{
    AllowTelemetryStatus = $status
}
```
