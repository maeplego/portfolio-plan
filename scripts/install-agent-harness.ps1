# Install portable Cursor agent harness (rules + skills).
# Usage (from project/):
#   .\scripts\install-agent-harness.ps1 -TargetPath 'C:\dev\other-app' -SeedTemplates
#   .\scripts\install-agent-harness.ps1 -Personal
#   .\scripts\install-agent-harness.ps1 -TargetPath . -Personal

[CmdletBinding()]
param(
    [string] $TargetPath = "",
    [switch] $Personal,
    [switch] $SeedTemplates,
    [switch] $WhatIf
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path $PSScriptRoot -Parent
$HarnessRoot = Join-Path $ProjectRoot "agent-harness"
$ManifestPath = Join-Path $HarnessRoot "manifest.json"

if (-not (Test-Path $ManifestPath)) {
    throw "manifest not found: $ManifestPath"
}
if (-not $Personal -and [string]::IsNullOrWhiteSpace($TargetPath)) {
    throw "Specify -TargetPath and/or -Personal"
}

$manifest = Get-Content $ManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json

function Copy-HarnessFile {
    param(
        [Parameter(Mandatory = $true)][string] $Source,
        [Parameter(Mandatory = $true)][string] $Destination
    )
    if (-not (Test-Path $Source)) {
        throw "missing source: $Source"
    }
    $destDir = Split-Path $Destination -Parent
    if ($WhatIf) {
        Write-Host "WhatIf: $Source -> $Destination"
        return
    }
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    Copy-Item -Path $Source -Destination $Destination -Force
    Write-Host "wrote $Destination"
}

function Install-ToProject {
    param([string] $Root)

    $rootFull = [System.IO.Path]::GetFullPath($Root)
    if (-not (Test-Path $rootFull)) {
        throw "target does not exist: $rootFull"
    }

    foreach ($rule in $manifest.rules) {
        $src = Join-Path (Join-Path $HarnessRoot "rules") $rule
        $dst = Join-Path (Join-Path (Join-Path $rootFull ".cursor") "rules") $rule
        Copy-HarnessFile -Source $src -Destination $dst
    }

    foreach ($skill in $manifest.skills) {
        $src = Join-Path (Join-Path (Join-Path $HarnessRoot "skills") $skill) "SKILL.md"
        $dst = Join-Path (Join-Path (Join-Path (Join-Path $rootFull ".cursor") "skills") $skill) "SKILL.md"
        Copy-HarnessFile -Source $src -Destination $dst
    }

    if ($SeedTemplates) {
        $agentsDst = Join-Path $rootFull "AGENTS.md"
        if (-not (Test-Path $agentsDst)) {
            Copy-HarnessFile -Source (Join-Path (Join-Path $HarnessRoot "templates") "AGENTS.md") -Destination $agentsDst
        } else {
            Write-Host "skip existing AGENTS.md"
        }

        $currentDst = Join-Path (Join-Path $rootFull "chat-context") "CURRENT.md"
        if (-not (Test-Path $currentDst)) {
            Copy-HarnessFile -Source (Join-Path (Join-Path $HarnessRoot "templates") "CURRENT.md") -Destination $currentDst
        } else {
            Write-Host "skip existing chat-context/CURRENT.md"
        }

        $gi = Join-Path $rootFull ".gitignore"
        $snippet = Get-Content (Join-Path (Join-Path $HarnessRoot "templates") "gitignore-snippet.txt") -Raw -Encoding UTF8
        if (-not (Test-Path $gi)) {
            if (-not $WhatIf) {
                [System.IO.File]::WriteAllText($gi, $snippet.TrimEnd() + [Environment]::NewLine)
            }
            Write-Host "wrote $gi"
        } elseif ((Get-Content $gi -Raw) -notmatch 'chat-context') {
            if (-not $WhatIf) {
                Add-Content -Path $gi -Value ([Environment]::NewLine + $snippet.TrimEnd() + [Environment]::NewLine)
            }
            Write-Host "appended chat-context ignore to $gi"
        } else {
            Write-Host "skip .gitignore (chat-context already present)"
        }
    }

    Write-Host "project harness installed -> $rootFull"
}

function Install-PersonalSkills {
    $homeSkills = Join-Path $env:USERPROFILE ".cursor\skills"
    foreach ($skill in $manifest.skills) {
        $src = Join-Path (Join-Path (Join-Path $HarnessRoot "skills") $skill) "SKILL.md"
        $dst = Join-Path (Join-Path $homeSkills $skill) "SKILL.md"
        Copy-HarnessFile -Source $src -Destination $dst
    }
    Write-Host "personal skills installed -> $homeSkills"
}

if ($TargetPath) {
    $resolved = if ([System.IO.Path]::IsPathRooted($TargetPath)) {
        $TargetPath
    } else {
        Join-Path (Get-Location) $TargetPath
    }
    # Allow -TargetPath . from project/
    Install-ToProject -Root $resolved
}

if ($Personal) {
    Install-PersonalSkills
}

Write-Host "done (harness v$($manifest.version))"
