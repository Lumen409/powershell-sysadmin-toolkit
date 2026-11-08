# Scanners

These are powershell scripts specifically tested and used for PDQ scanners

## Usage
  1. Go to the "scanners" option, create a new scanner and name it with the file type set as "powershell script".
  2.  Copy and paste the script (or import it) in the command field.
  3.  Select a test device to run it on.
  4.  after pdq ran the script successfully make sure to select the variable type appropriately (ie. string (most will be strings btw))

## What it does
scanner-allow-telemetry.ps1 - Checks if Windows Telemetry is actually turned on (since Intune isn't reliable when changing Telemetry types)
scanner-detect-AI-installs.ps1 - Checks multiple locations for AI installation (%user\appdata\local yayy....)

## Notes
PDQ requires variables to be selected so you can assign the information your wanting into outputted data. 
Meaning If I run a powershell script to pull CPU models, 
I need a variable called "CPU models" and identified as a variable type so the information can be pushed on the device.
