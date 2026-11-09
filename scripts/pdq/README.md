# PDQ

Collection of PDQ scripts that have helped collect information, triage and actively troubleshoot/remediate problems.

## Requirements
- PDQConnectAgent - 5.15.57 deployed on devices
- FullLanguageMode on (if running WDAC on managed Windows devices) since it leverages device scans
- Elevated PDQ rights (member or higher if default or RBAC aren't being used)
- Tested on Windows 11 25H2, 24H4, 23H2

## Usage
These powershell scripts have been tested and confirmed to be ran inside PDQ. The usage varies depending on deployments, packages, scans, etc. But I will specify how to run each depending on the type.

## Notes
