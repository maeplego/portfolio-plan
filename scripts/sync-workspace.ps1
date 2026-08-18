# portfolio.code-workspace を product-repos.json から再生成する。
# 用法: リポジトリ root (project/) で .\scripts\sync-workspace.ps1

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path $PSScriptRoot -Parent
$ManifestPath = Join-Path $ProjectRoot "portfolio-plan\product-repos.json"
$OutPath = Join-Path $ProjectRoot "portfolio.code-workspace"

$manifest = Get-Content $ManifestPath -Raw | ConvertFrom-Json
$folders = @()

foreach ($entry in $manifest.folders) {
    $rel = $entry.path
    $abs = if ([System.IO.Path]::IsPathRooted($rel)) { $rel } else { Join-Path $ProjectRoot $rel }
    if ($entry.name -ne "workspace" -and -not (Test-Path $abs)) {
        Write-Warning "skip missing repo: $($entry.name) -> $rel"
        continue
    }
    $folders += [ordered]@{
        name = $entry.name
        path = ($rel -replace '\\', '/')
    }
}

$workspace = [ordered]@{
    folders  = $folders
    settings = @{}
}

$json = $workspace | ConvertTo-Json -Depth 4
# VS Code workspace は末尾改行付き 2-space JSON が読みやすい
[System.IO.File]::WriteAllText($OutPath, ($json + [Environment]::NewLine))
Write-Host "wrote $OutPath ($($folders.Count) folders)"
