[CmdletBinding()]
param(
	[string]$DestinationPath = $env:PLUGIN_ROOT
)

$ErrorActionPreference = 'Stop'

$outdatedScript = Join-Path $PSScriptRoot 'outdated.ps1'
$updateScript = Join-Path $PSScriptRoot 'update-version.ps1'

$checkOutput = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $outdatedScript
$checkExitCode = $LASTEXITCODE

if ($checkExitCode -eq 99) {
	$updateOutput = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $updateScript -DestinationPath $DestinationPath 2>&1
	$updateExitCode = $LASTEXITCODE

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