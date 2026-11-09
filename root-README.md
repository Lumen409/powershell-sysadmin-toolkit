# powershell-sysadmin-toolkit

PowerShell scripts I've written, tested, and used to manage Windows endpoints in a large environment. They cover Intune, PDQ Connect, and general sysadmin work, and they're shared here so other admins can borrow them, adapt them, and deploy them in their own organizations.

## What's inside (so far)

| Folder | What it contains |
|--------|------------------|
| [`scripts/Intune/adobe-updates`](scripts/Intune/adobe-updates) | Intune Remediation that keeps Adobe apps patched using Adobe's Remote Update Manager |
| [`scripts/pdq/scanners`](scripts/pdq/scanners) | PDQ Connect scanner scripts for Windows telemetry status and AI app detection |

More scripts will be added over time, organized by tool.

## How it's organized

Each script folder has its own README. Start there. A typical README covers:

- **Overview:** the problem, the approach, and the result
- **Requirements:** PowerShell version, permissions, and what it was tested on
- **Usage:** how to deploy or run the scripts
- **Notes:** anything worth knowing before you run it

## Before you run anything

- Read each script first and test it on a single device or a small pilot group before deploying widely.
- Review paths, names, and settings and adjust them for your environment, if needed.
- These scripts are provided as-is, without warranty. You're responsible for testing them in your own environment.

## Feedback

Found a bug or have an improvement? Open an issue.

## License

Released under the MIT License. See [LICENSE](LICENSE).
