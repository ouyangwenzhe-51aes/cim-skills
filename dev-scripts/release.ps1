[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^\d+\.\d+\.\d+$')]
    [string]$Version,

    [string]$ValidUntil = (Get-Date).AddMonths(6).ToString('yyyy-MM-dd'),

    [switch]$Tag,
    [switch]$Push
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
Set-Location $RepoRoot
$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)

function Read-JsonFile($Path) {
    return [System.IO.File]::ReadAllText((Resolve-Path $Path), [System.Text.Encoding]::UTF8) | ConvertFrom-Json
}

function Write-JsonFile($Path, $Object) {
    [System.IO.File]::WriteAllText((Resolve-Path $Path), ($Object | ConvertTo-Json -Depth 20), $Utf8NoBom)
}

function Set-JsonVersion($Path) {
    $json = Read-JsonFile $Path
    $json.version = $Version
    Write-JsonFile $Path $json
}

function Set-MarketplaceVersion($Path) {
    $json = Read-JsonFile $Path
    foreach ($plugin in $json.plugins) {
        if ($plugin.name -eq 'cimapi-skills') {
            if (-not ($plugin.PSObject.Properties.Name -contains 'version')) {
                $plugin | Add-Member -NotePropertyName version -NotePropertyValue $Version
            } else {
                $plugin.version = $Version
            }
        }
    }
    Write-JsonFile $Path $json
}

function Set-ApmVersions($Path) {
    $resolved = Resolve-Path $Path
    $text = [System.IO.File]::ReadAllText($resolved, [System.Text.Encoding]::UTF8)

    $topLevelPattern = '(?m)^version:\s*\S+\s*$'
    if ($text -notmatch $topLevelPattern) {
        throw "Top-level version not found in $Path"
    }
    $text = [regex]::Replace($text, $topLevelPattern, "version: $Version", 1)

    $packagePattern = '(?ms)^(\s*-\s*name:\s*cimapi-skills\s*\r?\n(?:\s+.*\r?\n)*?\s*version:)\s*\S+\s*$'
    if ($text -notmatch $packagePattern) {
        throw "Marketplace package version not found in $Path"
    }
    $text = [regex]::Replace($text, $packagePattern, "`$1 $Version", 1)

    [System.IO.File]::WriteAllText($resolved, $text, $Utf8NoBom)
}

function Set-SkillVersion($Path) {
    $text = [System.IO.File]::ReadAllText((Resolve-Path $Path), [System.Text.Encoding]::UTF8)

    if ($text -notmatch '(?m)^version:\s*') {
        $text = $text -replace '(?m)^(metadata:\s*)$', "version: `"$Version`"`nvalid_until: `"$ValidUntil`"`n`$1"
    } else {
        $text = $text -replace '(?m)^version:\s*.*$', "version: `"$Version`""
        if ($text -notmatch '(?m)^valid_until:\s*') {
            $text = $text -replace '(?m)^(metadata:\s*)$', "valid_until: `"$ValidUntil`"`n`$1"
        } else {
            $text = $text -replace '(?m)^valid_until:\s*.*$', "valid_until: `"$ValidUntil`""
        }
    }

    $text = $text -replace '(?m)^(\s*)version:\s*\d+\.\d+\.\d+\s*$', "`$1version: $Version"
    [System.IO.File]::WriteAllText((Resolve-Path $Path), $text, $Utf8NoBom)
}

Set-JsonVersion 'plugin.json'
Set-JsonVersion '.claude-plugin/plugin.json'
Set-JsonVersion '.cursor-plugin/plugin.json'
Set-MarketplaceVersion '.claude-plugin/marketplace.json'
Set-MarketplaceVersion '.cursor-plugin/marketplace.json'
Set-ApmVersions 'apm.yml'

Get-ChildItem 'skills' -Recurse -Filter 'SKILL.md' | ForEach-Object {
    Set-SkillVersion $_.FullName
}

Get-Content 'plugin.json' -Raw | ConvertFrom-Json | Out-Null
Get-Content '.claude-plugin/plugin.json' -Raw | ConvertFrom-Json | Out-Null
Get-Content '.claude-plugin/marketplace.json' -Raw | ConvertFrom-Json | Out-Null
Get-Content '.cursor-plugin/plugin.json' -Raw | ConvertFrom-Json | Out-Null
Get-Content '.cursor-plugin/marketplace.json' -Raw | ConvertFrom-Json | Out-Null

if ($Tag) {
    $tagName = "v$Version"
    $existingTag = @(git tag -l $tagName 2>$null)
    if ($existingTag.Count -gt 0) {
        throw "Tag $tagName already exists. Delete it intentionally before recreating."
    }
    git tag $tagName
    if ($Push) {
        git push origin HEAD
        git push origin $tagName
    }
}

Write-Host "Release files updated for version $Version (valid_until: $ValidUntil)."
Write-Host 'Next steps:'
Write-Host '  1. Update CHANGELOG.md with human-readable release notes.'
Write-Host "  2. Commit changes, then tag and push: git tag v$Version; git push origin HEAD; git push origin v$Version"
