# Remediate-RunRUM.ps1
# ------------------------------------------------------------
# This script runs Adobe's updater tool (RUM) to actually install any
# pending Adobe updates on this device. It:
#   1. Finds the updater tool.
#   2. Runs it, waits up to 45 minutes for it to finish, and records
#      everything it prints along the way.
#   3. If it takes too long, it force-stops it (and any helper processes
#      it started) so it doesn't hang forever or block future runs.
#   4. Reads the updater's own "did this work?" message to decide whether
#      to tell Intune this device is now fixed or still has a problem.
# Everything is written to a log file so we can troubleshoot later
# without needing to remote into the device.
# ------------------------------------------------------------

$ErrorActionPreference = "Stop"
$logDir  = "C:\ProgramData\AdobeRUM"
$logFile = Join-Path $logDir "rum.log"
New-Item -Path $logDir -ItemType Directory -Force | Out-Null

# Simple helper: writes a timestamped line to both the log file and the
# Intune output (so it shows up in the Intune remediation report too).
function Log($m) {
    $line = "[$((Get-Date).ToString('s'))] $m"
    Add-Content -Path $logFile -Value $line
    Write-Output $m
}

# Same known install locations as the detection script
function Get-RUMPath {
    $paths = @(
        "C:\Program Files (x86)\Common Files\Adobe\OOBE_Enterprise\RemoteUpdateManager\RemoteUpdateManager.exe",
        "C:\Program Files\Common Files\Adobe\OOBE_Enterprise\RemoteUpdateManager\RemoteUpdateManager.exe"
    )
    return ($paths | Where-Object { Test-Path $_ } | Select-Object -First 1)
}

# STEP 1: full process-tree kill (used later if we time out)
function Stop-ProcessTree($processId) {
    Get-CimInstance Win32_Process -Filter "ParentProcessId=$processId" | ForEach-Object {
        Stop-ProcessTree $_.ProcessId
    }
    Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
}

Log "=== RUM Remediation Start ==="
Log ("Running as: " + (whoami))

$rum = Get-RUMPath
if (-not $rum) {
    Log "ERROR: RUM not found."
    exit 1
}
Log "FOUND RUM at: $rum"

# STEP 2: redirect RUM's own output so we can see where it stalls
$stdOut = Join-Path $logDir "rum_stdout.log"
$stdErr = Join-Path $logDir "rum_stderr.log"

try {
    $p = Start-Process -FilePath $rum -ArgumentList "--action=install" `
         -WindowStyle Hidden -PassThru `
         -RedirectStandardOutput $stdOut -RedirectStandardError $stdErr

    $finished = $p.WaitForExit(2700000)  # 45 min timeout, in milliseconds
    if (-not $finished) {
        Log "ERROR: RUM did not finish within timeout, killing process tree."
        Stop-ProcessTree -processId $p.Id
        Log "--- Partial stdout at time of kill ---"
        Get-Content $stdOut -ErrorAction SilentlyContinue | ForEach-Object { Log $_ }
        exit 1
    }
} catch {
    Log "ERROR launching RUM: $($_.Exception.Message)"
    exit 1
}

# RUM finished on its own — record everything it reported
Log "ExitCode (process): $($p.ExitCode)"
Log "--- RUM stdout ---"
$stdOutContent = Get-Content $stdOut -ErrorAction SilentlyContinue
$stdOutContent | ForEach-Object { Log $_ }
Log "--- RUM stderr ---"
Get-Content $stdErr -ErrorAction SilentlyContinue | ForEach-Object { Log $_ }

# Prefer RUM's own reported Return Code over the process ExitCode,
# since they don't always match.
$rumText = $stdOutContent -join "`n"
$actualCode = $p.ExitCode
if ($rumText -match "exiting with Return Code \((\d+)\)") {
    $actualCode = [int]$matches[1]
    Log "Parsed RUM-reported Return Code: $actualCode"
} else {
    Log "Could not find RUM-reported Return Code in output, falling back to process ExitCode."
}

# Translate RUM's result into what Intune expects:
switch ($actualCode) {
    0 { Log "SUCCESS: RUM reported clean run."; exit 0 }
    1 { Log "WARNING: RUM reported failure (possibly app in use)."; exit 1 }
    2 { Log "PARTIAL: Some updates applied, some failed."; exit 1 }
    default { Log "UNKNOWN exit code $actualCode"; exit 1 }
}
