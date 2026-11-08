# Detect-AdobeRUM.ps1
# ------------------------------------------------------------
# This script checks whether Adobe/RUM apps are on this device need updates.
#   - If Adobe's updater tool (RUM) isn't installed, there's
#     nothing to do so we report "no issue."
#   - If it IS installed, we check for updates
#     If it lists any pending updates, we report "issue found"
#     so Intune runs the remediation script next.
# ------------------------------------------------------------

# Known install locations for RemoteUpdateManager.exe (32-bit and 64-bit).
# This list must stay identical to the one in the remediation script —
# otherwise detection will say "not found" on a device where remediation
# would actually find and run it.

$paths = @(
    "C:\Program Files (x86)\Common Files\Adobe\OOBE_Enterprise\RemoteUpdateManager\RemoteUpdateManager.exe",
    "C:\Program Files\Common Files\Adobe\OOBE_Enterprise\RemoteUpdateManager\RemoteUpdateManager.exe"
)
$rum = $paths | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $rum) {
    Write-Output "RUM not found"
    exit 0	# Don't trigger remediation if Adobe isn't installed
}

# Run RUM in "check" mode
$result = & $rum --action=list 2>&1
$resultText = $result -join "`n"
Write-Output $resultText

# Positive match: does the "applicable updates" section actually list anything?
if ($resultText -match "Following Updates are applicable on the system\s*:\s*\r?\n\s*\(") {
    Write-Output "Updates pending -> triggering remediation"
    exit 1	# Updates available → trigger remediation
} else {
    Write-Output "No pending updates found"
    exit 0	# No issues
}