# ワークスペース内の全 Git リポジトリを同じ ref に揃える。
# product-repos.json の folders（project + pf-*）を対象にする。
#
# 用法（project/ で）:
#   .\scripts\checkout-workspace-ref.ps1 -Status
#   .\scripts\checkout-workspace-ref.ps1 -Ref portfolio-snapshot-2026-08-21
#   .\scripts\checkout-workspace-ref.ps1 -Ref master
#   .\scripts\checkout-workspace-ref.ps1 -Ref portfolio-snapshot-2026-08-21 -WorkBranch
#   .\scripts\checkout-workspace-ref.ps1 -Ref portfolio-snapshot-2026-08-21 -Fetch
#
# -WorkBranch: タグを detached のままにせず、at/<Ref> ブランチを作って乗る（作業しやすい）
# -Fetch: 各リポの github（なければ origin）から fetch --tags
# dirty なリポはスキップ（壊さない）。全部成功で exit 0、スキップ/失敗があれば exit 1

[CmdletBinding()]
param(
    [string] $Ref = "",
    [switch] $Status,
    [switch] $WorkBranch,
    [switch] $Fetch,
    [string] $Remote = ""
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path $PSScriptRoot -Parent
$ManifestPath = Join-Path $ProjectRoot "portfolio-plan\product-repos.json"

if (-not $Status -and [string]::IsNullOrWhiteSpace($Ref)) {
    Write-Error "Specify -Ref <tag|branch|sha> or -Status. Example: -Ref portfolio-snapshot-2026-08-21"
}

$manifest = Get-Content $ManifestPath -Raw | ConvertFrom-Json
$rows = @()
$fail = 0

foreach ($entry in $manifest.folders) {
    $rel = $entry.path
    $abs = if ([System.IO.Path]::IsPathRooted($rel)) { $rel } else { Join-Path $ProjectRoot $rel }
    $name = $entry.name

    if (-not (Test-Path (Join-Path $abs ".git"))) {
        $rows += [pscustomobject]@{ Repo = $name; Result = "missing"; Head = "-" }
        $fail++
        continue
    }

    Push-Location $abs
    try {
        if ($Fetch) {
            $r = $Remote
            if (-not $r) {
                $remotes = @(git remote)
                if ($remotes -contains "github") { $r = "github" }
                elseif ($remotes -contains "origin") { $r = "origin" }
            }
            if ($r) {
                git fetch $r --tags --quiet 2>$null | Out-Null
            }
        }

        $dirty = git status --porcelain
        $head = (git rev-parse --abbrev-ref HEAD 2>$null)
        if ($head -eq "HEAD") {
            $head = "detached@$(git rev-parse --short HEAD)"
        }

        if ($Status) {
            $short = git rev-parse --short HEAD
            $rows += [pscustomobject]@{ Repo = $name; Result = $(if ($dirty) { "dirty" } else { "ok" }); Head = "$head $short" }
            if ($dirty) { $fail++ }
            continue
        }

        if ($dirty) {
            $rows += [pscustomobject]@{ Repo = $name; Result = "skip-dirty"; Head = $head }
            $fail++
            continue
        }

        git rev-parse --verify $Ref 2>$null | Out-Null
        if ($LASTEXITCODE -ne 0) {
            $rows += [pscustomobject]@{ Repo = $name; Result = "missing-ref"; Head = $head }
            $fail++
            continue
        }

        if ($WorkBranch) {
            $branchName = "at/$Ref"
            git switch -C $branchName $Ref 2>$null | Out-Null
            if ($LASTEXITCODE -ne 0) {
                git checkout -B $branchName $Ref 2>$null | Out-Null
            }
            if ($LASTEXITCODE -ne 0) {
                $rows += [pscustomobject]@{ Repo = $name; Result = "checkout-fail"; Head = $head }
                $fail++
                continue
            }
            $newHead = $branchName
        }
        else {
            git switch --detach $Ref 2>$null | Out-Null
            if ($LASTEXITCODE -ne 0) {
                git checkout --detach $Ref 2>$null | Out-Null
            }
            if ($LASTEXITCODE -ne 0) {
                # branch name (master etc.)
                git switch $Ref 2>$null | Out-Null
                if ($LASTEXITCODE -ne 0) {
                    git checkout $Ref 2>$null | Out-Null
                }
            }
            if ($LASTEXITCODE -ne 0) {
                $rows += [pscustomobject]@{ Repo = $name; Result = "checkout-fail"; Head = $head }
                $fail++
                continue
            }
            $newHead = (git rev-parse --abbrev-ref HEAD)
            if ($newHead -eq "HEAD") {
                $newHead = "detached@$(git rev-parse --short HEAD)"
            }
        }

        $rows += [pscustomobject]@{ Repo = $name; Result = "ok"; Head = $newHead }
    }
    finally {
        Pop-Location
    }
}

$rows | Format-Table -AutoSize
Write-Host ("{0} repos, failures/skips={1}" -f $rows.Count, $fail)
if (-not $Status -and -not $WorkBranch -and $Ref -notmatch '^(master|main)$') {
    Write-Host "Tip: tags leave detached HEAD. Use -WorkBranch to sit on at/<Ref> instead."
}
exit $(if ($fail -gt 0) { 1 } else { 0 })
