[CmdletBinding()]
param(
	[string]$DestinationPath = $env:PLUGIN_ROOT
)

$ErrorActionPreference = 'Stop'

# VS Code hooks expect UTF-8 JSON output.
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[Console]::InputEncoding = $utf8NoBom
[Console]::OutputEncoding = $utf8NoBom
$OutputEncoding = $utf8NoBom

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

$outdatedScript = Join-Path $PSScriptRoot 'outdated.ps1'
$updateScript = Join-Path $PSScriptRoot 'update-version.ps1'

function Invoke-ChildScript {
	param(
		[Parameter(Mandatory=$true)]
		[string]$ScriptPath,

		[string]$DestinationPath = ''
	)

	$previousScriptPath = $env:CIM_CHILD_SCRIPT
	$previousDestinationPath = $env:CIM_CHILD_DESTINATION

	try {
		$env:CIM_CHILD_SCRIPT = $ScriptPath
		$env:CIM_CHILD_DESTINATION = $DestinationPath

		$command = @'
$script = Get-Content -LiteralPath $env:CIM_CHILD_SCRIPT -Raw
$block = [scriptblock]::Create($script)
if ([string]::IsNullOrWhiteSpace($env:CIM_CHILD_DESTINATION)) {
    & $block
} else {
    & $block -DestinationPath $env:CIM_CHILD_DESTINATION
}
exit $LASTEXITCODE
'@

		& powershell.exe -NoProfile -ExecutionPolicy Bypass -Command $command
	} finally {
		$env:CIM_CHILD_SCRIPT = $previousScriptPath
		$env:CIM_CHILD_DESTINATION = $previousDestinationPath
	}
}

$checkOutput = Invoke-ChildScript -ScriptPath $outdatedScript
$checkExitCode = $LASTEXITCODE

if ($checkExitCode -eq 99) {
	$previousErrorActionPreference = $ErrorActionPreference
	$ErrorActionPreference = 'Continue'
	$updateOutput = Invoke-ChildScript -ScriptPath $updateScript -DestinationPath $DestinationPath 2>&1
	$updateExitCode = $LASTEXITCODE
	$ErrorActionPreference = $previousErrorActionPreference

	if ($updateExitCode -eq 0) {
		$noticeTitle = "$(ConvertTo-UnicodeString @(0x26A0, 0xFE0F)) cim-skills $(ConvertTo-UnicodeString @(0x5DF2, 0x81EA, 0x52A8, 0x66F4, 0x65B0, 0x81F3, 0x6700, 0x65B0, 0x7248, 0x672C, 0xFF0C, 0x8BF7, 0x91CD, 0x542F, 0x8FDB, 0x7A0B, 0x4EE5, 0x4F7F, 0x7528, 0x3002))"
		$additionalContext = "IMPORTANT:
        1. Start the reply with the following notice:

		$noticeTitle

        2. Only include this notice in the first assistant response of the session.
        Do not repeat it afterwards."
	} else {
		$additionalContext = "cim-skills update failed with exit code $updateExitCode"
	}

	@{
		hookSpecificOutput = @{
			hookEventName = 'SessionStart'
			additionalContext = $additionalContext
		}
	} |
	ConvertTo-Json -Compress

	exit $updateExitCode
}

if ($checkOutput) {
	$checkOutput
}

exit $checkExitCode