<#
.SYNOPSIS
    Detects AI installations
.DESCRIPTION
    Looks for MSIX (store installs), Machine-wide installs (programs/feaures), User-installs (most AI installs occur at the C:\users\appdata\local....annoying I know)
.NOTES
    Author: Lumen409
    Tested on: Windows 11, PowerShell 5.1
#>

$ErrorActionPreference = 'SilentlyContinue'
$findings = New-Object System.Collections.Generic.List[object]

function Add-Finding($Product, $Type, $Evidence, $User, $Path) {
    $findings.Add([pscustomobject]@{
        Product  = [string]$Product
        Type     = [string]$Type
        Evidence = [string]$Evidence
        User     = [string]$User
        Path     = [string]$Path
    })
}

# 1. Store / MSIX packages (any user)
foreach ($pkg in (Get-AppxPackage -AllUsers -ErrorAction SilentlyContinue)) {
    $product = $null
    if     ($pkg.PackageFamilyName -like 'Claude_*')                 { $product = 'Claude'  }
    elseif ($pkg.Name -like 'OpenAI.ChatGPT*' -or $pkg.Name -like '*ChatGPT*') { $product = 'ChatGPT' }
    elseif ($pkg.Name -like '*Gemini*' -and $pkg.Publisher -like '*Google*')   { $product = 'Gemini'  }
    if ($product) {
        Add-Finding $product 'Desktop app (MSIX/Store)' "$($pkg.Name) $($pkg.Version)" '' $pkg.InstallLocation
    }
}

# 2. Machine-wide installs (Add/Remove Programs)
$uninstallKeys = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
)
foreach ($app in (Get-ItemProperty $uninstallKeys -ErrorAction SilentlyContinue)) {
    $n = $app.DisplayName; $p = $app.Publisher
    if (-not $n) { continue }
    $product = $null
    if     ($n -match '^Claude' -or $p -match 'Anthropic')       { $product = 'Claude'   }
    elseif ($n -match 'ChatGPT' -or $p -match '^OpenAI')         { $product = 'ChatGPT'  }
    elseif ($n -match '^Gemini' -and $p -match 'Google')         { $product = 'Gemini'   }
    elseif ($n -match 'OpenClaw')                                { $product = 'OpenClaw' }
    if ($product) { Add-Finding $product 'Installed program' "$n $($app.DisplayVersion)" '' $app.InstallLocation }
}

# 3. Per-user installs, CLIs and leftover config
$checks = @(
    @{ P='Claude';   T='Desktop app (legacy installer)'; R='AppData\Local\AnthropicClaude' },
    @{ P='Claude';   T='Desktop app data (MSIX)';        R='AppData\Local\Packages\Claude_*' },
    @{ P='Claude';   T='Desktop app config';             R='AppData\Roaming\Claude' },
    @{ P='Claude';   T='Claude Code CLI (native)';       R='.local\bin\claude.exe' },
    @{ P='Claude';   T='Claude Code CLI (npm)';          R='AppData\Roaming\npm\claude.cmd' },
    @{ P='Claude';   T='Claude Code settings folder';    R='.claude' },
    @{ P='ChatGPT';  T='Desktop app data (MSIX)';        R='AppData\Local\Packages\OpenAI.ChatGPT*' },
    @{ P='ChatGPT';  T='Codex CLI (npm)';                R='AppData\Roaming\npm\codex.cmd' },
    @{ P='ChatGPT';  T='Codex settings folder';          R='.codex' },
    @{ P='Gemini';   T='Desktop app (per-user install)'; R='AppData\Local\Programs\Gemini*' },
    @{ P='Gemini';   T='Desktop app data';               R='AppData\Local\Gemini*' },
    @{ P='Gemini';   T='Gemini CLI (npm)';               R='AppData\Roaming\npm\gemini.cmd' },
    @{ P='Gemini';   T='Gemini CLI settings folder';     R='.gemini' },
    @{ P='OpenClaw'; T='OpenClaw CLI (npm)';             R='AppData\Roaming\npm\openclaw.cmd' },
    @{ P='OpenClaw'; T='OpenClaw package (npm)';         R='AppData\Roaming\npm\node_modules\openclaw' },
    @{ P='OpenClaw'; T='OpenClaw config/workspace';      R='.openclaw' },
    @{ P='OpenClaw'; T='OpenClaw legacy config';         R='.clawdbot' },
    @{ P='OpenClaw'; T='OpenClaw legacy config';         R='.moltbot' }
)
$skip = 'Public','Default','Default User','All Users'
foreach ($prof in (Get-ChildItem 'C:\Users' -Directory -ErrorAction SilentlyContinue | Where-Object { $skip -notcontains $_.Name })) {
    foreach ($c in $checks) {
        foreach ($h in (Get-Item -Path (Join-Path $prof.FullName $c.R) -Force -ErrorAction SilentlyContinue)) {
            Add-Finding $c.P $c.T 'Path exists' $prof.Name $h.FullName
        }
    }
}

# 4. OpenClaw runtime: gateway listener, scheduled task
foreach ($conn in (Get-NetTCPConnection -LocalPort 18789 -State Listen -ErrorAction SilentlyContinue)) {
    $proc = Get-Process -Id $conn.OwningProcess -ErrorAction SilentlyContinue
    Add-Finding 'OpenClaw' 'Gateway listening on 18789' "Process: $($proc.ProcessName) (PID $($conn.OwningProcess))" '' $proc.Path
}
foreach ($t in (Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object { $_.TaskName -match 'openclaw|clawdbot|moltbot' })) {
    Add-Finding 'OpenClaw' 'Scheduled task' $t.TaskName '' $t.TaskPath
}

# Always return at least one row so PDQ can validate the output and learn the columns.
if ($findings.Count -eq 0) {
    Add-Finding 'None' 'No AI apps found' '' '' ''
}

$findings
