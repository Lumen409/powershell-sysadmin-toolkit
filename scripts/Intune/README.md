# Intune scripts

A list of powershell detection/remediation scripts that have been tested and verified.
Each folder will have the detection script and remediation script.

## What it does
When setup properly (correct logs) you can go to your script and checkout the overview health of your scripts.
You will be able to see Devices with or without issues in the detection slide,
and devices that have/haven't been remediated if the device detected an issue.

## Requirements
- Intune application manager or higher
- Running version of Intune in your environment
- Tested on Windows 11 23H2 and up, Intune and powershell

## Usage
See README in specific script's folder to see how to use them.

## Notes
I use the detection/remediation script page quite a lot in Intune.
Instead of running one-off scripts, you can assign scripts to groups
and have a nice dashboard of the status.
Once you get a hang of outputting the logs correctly it gets easier,
all of my scripts have been tested so you can use the 'Overview'
to check on the status of these scripts.
