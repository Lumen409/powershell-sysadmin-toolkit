
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