[CmdletBinding()]
param(
	[string]$DestinationPath = $env:PLUGIN_ROOT
)

$ErrorActionPreference = 'Stop'

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
		$additionalContext = 'cim-skills updated successfully'
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