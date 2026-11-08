# adobe-updates

Detects if AdobeRUM is on the device. Runs RUM (Remote Update Manager) if present.

## What it does
Before you deploy Adobe products you need to create a package from the Adobe admin console, when the product gets packaged it will add another program called "AdobeRUM.exe"
The detection script detects all known location AdobeRUM could be and (if found) runs the remediation script.
The remediation script runs the updater tool (if not updated) and logs the process in "C:\ProgramData\AdobeRUM".

## Requirements
- Intune application manager or higher
- Tested on Windows 11 23H2, 24H2, 25H2, Intune

## Usage
1. Go to Intune -> Devices -> "Scripts and Remediations" -> "Create custom script"
2. After assigning a name go to "settings"
3. import the detection script and remediation script
   - Run this script using the logged-on credentials - No
   - Enforce script signature check - No
   - Run script in 64-bit PowerShell - Yes
4. assign the Intune group you want to run the scripts on

## Notes and caveats
- If AdobeRUM is not found on the device, it will return with "No Issue" because the script can't run an exe that isn't there.
- Adobe updates can take a LONG time, so I have a timer of 45 minutes to ensure everything updated, you can adjust that time if you want.
  I labeled it and noted it's in milliseconds.
- Both ps1's are heavily notated, just open with notepad to view all the documentation
- $logDir  = "C:\ProgramData\AdobeRUM" ... you can change this path for logs, or you can just remove it.

