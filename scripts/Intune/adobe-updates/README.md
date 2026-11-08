# adobe-updates

Detects if AdobeRUM is on the device. Runs RUM (Remote Update Manager) on the device if present.

## What it does
When you deploy Adobe products you need to create a package from the Adobe admin console, when the product gets packaged it will add another program called "AdobeRUM.exe"
The detection script detects all known location AdobeRUM could be and (if found) runs the remediation script.
The remediation script runs the updater tool (if not updated) and logs the process in "C:\ProgramData\AdobeRUM".

## Requirements
- PowerShell version
- Required modules or permissions
- Tested on (for example, Windows 11 23H2, Intune)

## Usage
Short example of how to run it.

## Notes and caveats
- If AdobeRUM is not found on the device, it will return with "No Issue" because the script can't run an exe that isn't there.
- Adobe updates can take a LONG time, so I have a timer of 45 minutes to ensure everything updated, you can adjust that time if you want.
  I labeled it and noted it's in milliseconds.
- Both scripts are detailed in the ps1's, just open with notepad to view all the documentation

