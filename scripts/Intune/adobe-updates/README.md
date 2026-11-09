# Adobe Updates (Intune Remediation)

Keeps Adobe apps patched on managed Windows devices by running Adobe's Remote Update Manager (RUM) through an Intune Remediation.

## Overview

**Problem:** Adobe products deployed from an Adobe Admin Console package need a way to stay up to date across many devices without a technician touching each one.

**Approach:** A detection script finds Adobe's Remote Update Manager (`RemoteUpdateManager.exe`) in its known install locations and asks it whether updates are pending. If any are, Intune runs the remediation script, which installs them with RUM, waits up to 45 minutes, and logs everything for troubleshooting.

**Result:** Adobe updates install silently in the background on every assigned device, with no remote session needed. Devices without RUM are skipped and report "no issue," and a local log shows what happened on each run.

<!-- Optional: add a measurable result here, e.g. "Replaced manual patching on N devices". Keep it free of org-identifying details. -->

## Files

| File | Purpose |
|------|---------|
| `Detect-AdobeRUM.ps1` | Detection script. Exits `1` when updates are pending, which triggers remediation. |
| `Remediate-RunRUM.ps1` | Remediation script. Runs RUM, enforces a timeout, and logs the output. |

Both scripts are heavily commented. Open them in any text editor to read the full documentation.

## Requirements

- Windows devices managed by Microsoft Intune, with a license that includes Remediations
- Adobe products packaged from the Adobe Admin Console with Remote Update Manager included, so `RemoteUpdateManager.exe` is installed under `Common Files\Adobe\OOBE_Enterprise\RemoteUpdateManager`
- Runs as SYSTEM in 64-bit PowerShell
- No additional PowerShell modules
- Tested on: `<Windows 11 23H2, 24H2, 25H2>`

## Usage

1. In Intune, go to **Devices > Scripts and remediations** and choose **Create custom script**.
2. Give it a name, then open **Settings**.
3. Upload the detection script and the remediation script, and set:
   - Run this script using the logged-on credentials: **No**
   - Enforce script signature check: **No**
   - Run script in 64-bit PowerShell: **Yes**
4. Assign the Intune group you want the scripts to run on.

## How it behaves

| Situation | Detection | Remediation |
|-----------|-----------|-------------|
| RUM not installed | Exit `0` ("RUM not found"), nothing to do | Not run |
| RUM installed, no updates pending | Exit `0` | Not run |
| RUM installed, updates pending | Exit `1` | Runs `--action=install` |
| RUM finishes with return code 0 | n/a | Exit `0` (success) |
| RUM reports failure or partial failure | n/a | Exit `1` |
| RUM exceeds the timeout | n/a | Process tree is stopped, exit `1` |

## Configuration

- **Timeout:** the remediation script waits for `WaitForExit(2700000)`, which is 45 minutes in milliseconds. Adobe updates can take a long time, so adjust this value if you need more or less.
- **Log location:** `$logDir = "C:\ProgramData\AdobeRUM"`. Change the path, or remove the logging lines if you don't want logs.

## Logs

The remediation script writes to `C:\ProgramData\AdobeRUM` on each device:

- `rum.log` - timestamped run log
- `rum_stdout.log` and `rum_stderr.log` - raw output from RUM

## Notes and caveats

- If RUM isn't found on a device, detection returns "no issue," because the scripts can't run an executable that isn't there.
- The known install paths are listed in both scripts and must stay identical, otherwise detection and remediation can disagree about whether RUM exists.
- Detection parses RUM's text output, so a future Adobe change to that wording could require updating the match.
- If an Adobe app is open during the update, RUM can report a failure, and the next scheduled run will try again.


