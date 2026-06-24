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

# VS Code hooks expect UTF-8 JSON output.
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[Console]::InputEncoding = $utf8NoBom
[Console]::OutputEncoding = $utf8NoBom
$OutputEncoding = $utf8NoBom

$logFile = Join-Path $env:TEMP 'cimapi-hook.log'

function Write-Log {
    param([string]$Message)

    try {
        Add-Content -Path $logFile `
            -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $Message"
    }
    catch {
    }
}

function ConvertTo-UnicodeString {
    param(
        [Parameter(Mandatory)]
        [int[]]$CodePoints
    )

    $builder = New-Object System.Text.StringBuilder

    foreach ($codePoint in $CodePoints) {
        [void]$builder.Append(
            [System.Char]::ConvertFromUtf32($codePoint)
        )
    }

    return $builder.ToString()
}

if ([string]::IsNullOrWhiteSpace($InstallRoot)) {
    $homeDir =
    if (-not [string]::IsNullOrWhiteSpace($env:USERPROFILE)) {
        $env:USERPROFILE
    }
    else {
        $HOME
    }

    if ([string]::IsNullOrWhiteSpace($homeDir)) {
        throw 'Cannot determine home directory.'
    }

    $InstallRoot = Join-Path $homeDir '.vscode\\agent-plugins\\github.com'
}

function Parse-SemVer {
    param(
        [Parameter(Mandatory)]
        [string]$Version
    )

    $pattern =
    '^(?<major>0|[1-9]\d*)\.(?<minor>0|[1-9]\d*)\.(?<patch>0|[1-9]\d*)(?:-(?<prerelease>[0-9A-Za-z.-]+))?(?:\+[0-9A-Za-z.-]+)?$'

    $match =
    [System.Text.RegularExpressions.Regex]::Match(
        $Version,
        $pattern
    )

    if (-not $match.Success) {
        throw "Invalid semver: $Version"
    }

    [PSCustomObject]@{
        Major      = [int]$match.Groups['major'].Value
        Minor      = [int]$match.Groups['minor'].Value
        Patch      = [int]$match.Groups['patch'].Value
        PreRelease = $match.Groups['prerelease'].Value
    }
}

function Compare-PreRelease {
    param(
        [string]$A,
        [string]$B
    )

    if ([string]::IsNullOrWhiteSpace($A) -and
        [string]::IsNullOrWhiteSpace($B)) {
        return 0
    }

    if ([string]::IsNullOrWhiteSpace($A)) {
        return 1
    }

    if ([string]::IsNullOrWhiteSpace($B)) {
        return -1
    }

    $aParts = $A.Split('.')
    $bParts = $B.Split('.')

    $max = [Math]::Max(
        $aParts.Length,
        $bParts.Length
    )

    for ($i = 0; $i -lt $max; $i++) {

        if ($i -ge $aParts.Length) {
            return -1
        }

        if ($i -ge $bParts.Length) {
            return 1
        }

        $aPart = $aParts[$i]
        $bPart = $bParts[$i]

        $aNumeric = $aPart -match '^\d+$'
        $bNumeric = $bPart -match '^\d+$'

        if ($aNumeric -and $bNumeric) {

            $cmp =
            ([int]$aPart).CompareTo(
                [int]$bPart
            )

            if ($cmp -ne 0) {
                return $cmp
            }

            continue
        }

        if ($aNumeric -and -not $bNumeric) {
            return -1
        }

        if (-not $aNumeric -and $bNumeric) {
            return 1
        }

        $cmp =
        [string]::CompareOrdinal(
            $aPart,
            $bPart
        )

        if ($cmp -ne 0) {
            return $cmp
        }
    }

    return 0
}

function Compare-SemVer {
    param(
        [Parameter(Mandatory)]
        [string]$A,

        [Parameter(Mandatory)]
        [string]$B
    )

    $left = Parse-SemVer $A
    $right = Parse-SemVer $B

    foreach ($field in @(
            'Major',
            'Minor',
            'Patch'
        )) {

        $cmp =
        $left.$field.CompareTo(
            $right.$field
        )

        if ($cmp -ne 0) {
            return $cmp
        }
    }

    return (
        Compare-PreRelease `
            -A $left.PreRelease `
            -B $right.PreRelease
    )
}

function Get-InstalledVersion {
    param(
        [string]$Root,
        [string]$Plugin,
        [string]$OwnerName,
        [string]$RepoName
    )

    if (-not (Test-Path $Root)) {
        return $null
    }

    $matches = @()

    $files =
    Get-ChildItem `
        -Path $Root `
        -Filter 'plugin.json' `
        -Recurse `
        -ErrorAction SilentlyContinue

    foreach ($file in $files) {

        try {

            $json =
            Get-Content `
                $file.FullName `
                -Raw |
            ConvertFrom-Json

            if ($json.name -eq $Plugin -and $json.version) {

                $matches += [PSCustomObject]@{
                    Version = [string]$json.version
                    Source  = $file.FullName
                }
            }
        }
        catch {
        }
    }

    if ($matches.Count -eq 0) {
        return $null
    }

    $preferred =
    $matches |
    Where-Object {
        $_.Source -like "*\$OwnerName\$RepoName\plugin.json"
    } |
    Select-Object -First 1

    if ($preferred) {
        return $preferred
    }

    return ($matches | Select-Object -First 1)
}

try {

    $remoteUrl =
    "https://raw.githubusercontent.com/$Owner/$Repo/$Branch/$MarketplacePath"

    $installed =
    Get-InstalledVersion `
        -Root $InstallRoot `
        -Plugin $PluginName `
        -OwnerName $Owner `
        -RepoName $Repo

    if (-not $installed) {
        throw "Cannot find installed plugin '$PluginName'"
    }

    $marketplace =
    Invoke-RestMethod `
        -Uri $remoteUrl `
        -Method Get `
        -TimeoutSec 20

    $latest =
    $marketplace.plugins |
    Where-Object {
        $_.name -eq $PluginName
    } |
    Select-Object -First 1

    if (-not $latest) {
        throw "Plugin '$PluginName' not found in marketplace"
    }

    $localVersion = [string]$installed.Version
    $latestVersion = [string]$latest.version

    $cmp =
    Compare-SemVer `
        -A $localVersion `
        -B $latestVersion

    Write-Log "local=$localVersion latest=$latestVersion compare=$cmp"

    if ($cmp -lt 0) {

        $noticeTitle = "$(ConvertTo-UnicodeString @(0x26A0, 0xFE0F)) cim-skills $(ConvertTo-UnicodeString @(0x6709, 0x65B0, 0x7248, 0x672C, 0x53EF, 0x7528))"
        $currentVersionLabel = ConvertTo-UnicodeString @(0x5F53, 0x524D, 0x7248, 0x672C)
        $latestVersionLabel = ConvertTo-UnicodeString @(0x6700, 0x65B0, 0x7248, 0x672C)
        $updatePrompt = ConvertTo-UnicodeString @(0x8BF7, 0x66F4, 0x65B0, 0x81F3)

        $message = @"
        IMPORTANT:

        The installed cim-skills plugin is outdated.

        For the first response in this session:

        1. Start the reply with the following notice:

    $noticeTitle

    ${currentVersionLabel}: $localVersion
    ${latestVersionLabel}: $latestVersion

    $updatePrompt cimapi-skills v$latestVersion

        2. Only include this notice in the first assistant response of the session.
        Do not repeat it afterwards."
"@

        @{
            hookSpecificOutput = @{
                hookEventName = "SessionStart"
                additionalContext = $message
            }
        } |
        ConvertTo-Json -Compress

        exit 0
    }

    @{
        hookSpecificOutput = @{
            hookEventName = "SessionStart"
            additionalContext = ""
        }
    } |
    ConvertTo-Json -Compress

    exit 0
}
catch {

    Write-Log $_.Exception.ToString()

    @{
        hookSpecificOutput = @{
            hookEventName = "SessionStart"
            additionalContext = ""
        }
    } |
    ConvertTo-Json -Compress

    exit 0
}