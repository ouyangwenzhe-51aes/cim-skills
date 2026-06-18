[CmdletBinding()]
param(
    [string]$PluginName = 'cimapi-skills',
    [string]$Owner = 'ouyangwenzhe-51aes',
    [string]$Repo = 'cim-skills',
    [string]$Branch = 'main',
    [string]$MarketplacePath = '.cursor-plugin/marketplace.json',
    [string]$InstallRoot = ''
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($InstallRoot)) {
    $homeDir = if (-not [string]::IsNullOrWhiteSpace($env:USERPROFILE)) { $env:USERPROFILE } else { $HOME }
    if ([string]::IsNullOrWhiteSpace($homeDir)) {
        Write-Error 'Cannot determine home directory. Pass -InstallRoot explicitly.'
        exit 1
    }
    $InstallRoot = Join-Path $homeDir '.vscode\agent-plugins\github.com'
}

function Parse-SemVer {
    param([Parameter(Mandatory = $true)][string]$Version)

    $pattern = '^(?<major>0|[1-9]\d*)\.(?<minor>0|[1-9]\d*)\.(?<patch>0|[1-9]\d*)(?:-(?<prerelease>[0-9A-Za-z.-]+))?(?:\+[0-9A-Za-z.-]+)?$'
    $match = [System.Text.RegularExpressions.Regex]::Match($Version, $pattern)
    if (-not $match.Success) {
        throw "Invalid semver: $Version"
    }

    [PSCustomObject]@{
        Major = [int]$match.Groups['major'].Value
        Minor = [int]$match.Groups['minor'].Value
        Patch = [int]$match.Groups['patch'].Value
        PreRelease = $match.Groups['prerelease'].Value
    }
}

function Compare-PreRelease {
    param(
        [string]$A,
        [string]$B
    )

    if ([string]::IsNullOrWhiteSpace($A) -and [string]::IsNullOrWhiteSpace($B)) { return 0 }
    if ([string]::IsNullOrWhiteSpace($A)) { return 1 }
    if ([string]::IsNullOrWhiteSpace($B)) { return -1 }

    $aParts = $A.Split('.')
    $bParts = $B.Split('.')
    $max = [Math]::Max($aParts.Length, $bParts.Length)

    for ($i = 0; $i -lt $max; $i++) {
        if ($i -ge $aParts.Length) { return -1 }
        if ($i -ge $bParts.Length) { return 1 }

        $aPart = $aParts[$i]
        $bPart = $bParts[$i]
        $aNumeric = $aPart -match '^\d+$'
        $bNumeric = $bPart -match '^\d+$'

        if ($aNumeric -and $bNumeric) {
            $cmp = ([int]$aPart).CompareTo([int]$bPart)
            if ($cmp -ne 0) { return $cmp }
            continue
        }

        if ($aNumeric -and -not $bNumeric) { return -1 }
        if (-not $aNumeric -and $bNumeric) { return 1 }

        $cmp = [string]::CompareOrdinal($aPart, $bPart)
        if ($cmp -ne 0) { return $cmp }
    }
}

function Compare-SemVer {
    param(
        [Parameter(Mandatory = $true)][string]$A,
        [Parameter(Mandatory = $true)][string]$B
    )

    $left = Parse-SemVer $A
    $right = Parse-SemVer $B

    foreach ($field in @('Major', 'Minor', 'Patch')) {
        $cmp = $left.$field.CompareTo($right.$field)
        if ($cmp -ne 0) { return $cmp }
    }

    Compare-PreRelease -A $left.PreRelease -B $right.PreRelease
}

function Get-InstalledVersion {
    param(
        [string]$Root,
        [string]$Plugin,
        [string]$OwnerName,
        [string]$RepoName
    )

    if (-not (Test-Path -Path $Root)) {
        return $null
    }

    $matches = @()
    $candidates = Get-ChildItem -Path $Root -Filter 'plugin.json' -Recurse -ErrorAction SilentlyContinue
    foreach ($file in $candidates) {
        try {
            $json = Get-Content -Path $file.FullName -Raw | ConvertFrom-Json
            if ($json.name -eq $Plugin -and $json.version) {
                $matches += [PSCustomObject]@{
                    Version = [string]$json.version
                    Source = $file.FullName
                }
            }
        }
        catch {
            continue
        }
    }

    if ($matches.Count -eq 0) {
        return $null
    }

    $preferred = $matches | Where-Object { $_.Source -like "*\\$OwnerName\\$RepoName\\plugin.json" } | Select-Object -First 1
    if ($preferred) {
        return $preferred
    }

    return ($matches | Select-Object -First 1)
}

$remoteUrl = "https://raw.githubusercontent.com/$Owner/$Repo/$Branch/$MarketplacePath"
$installed = Get-InstalledVersion -Root $InstallRoot -Plugin $PluginName -OwnerName $Owner -RepoName $Repo
if (-not $installed) {
    Write-Error "Cannot find local installed plugin version for '$PluginName' under '$InstallRoot'."
    exit 1
}

try {
    $marketplace = Invoke-RestMethod -Uri $remoteUrl -Method Get -TimeoutSec 20
}
catch {
    Write-Error "Failed to fetch marketplace: $remoteUrl`n$($_.Exception.Message)"
    exit 1
}

$latest = $marketplace.plugins | Where-Object { $_.name -eq $PluginName } | Select-Object -First 1
if (-not $latest) {
    Write-Error "Plugin '$PluginName' not found in marketplace: $remoteUrl"
    exit 1
}

$localVersion = [string]$installed.Version
$latestVersion = [string]$latest.version
$cmp = Compare-SemVer -A $localVersion -B $latestVersion

Write-Host "Plugin           : $PluginName"
Write-Host "Installed version: $localVersion"
Write-Host "Installed source : $($installed.Source)"
Write-Host "Marketplace URL  : $remoteUrl"
Write-Host "Latest version   : $latestVersion"

if ($cmp -lt 0) {
    Write-Host ''
    Write-Host "Update available: $localVersion -> $latestVersion"
    Write-Host "Run: apm update $PluginName"
    exit 2
}

if ($cmp -eq 0) {
    Write-Host ''
    Write-Host 'Up to date.'
    exit 0
}

Write-Host ''
Write-Host "Local version ($localVersion) is newer than marketplace ($latestVersion)."
exit 0
