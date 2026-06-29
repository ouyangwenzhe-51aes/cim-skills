# 下载、解压、移动脚本
# 使用方式: .\update-version.ps1 -DestinationPath "目标目录"
# 作为 hooks 执行时可不传参数，默认使用 $env:PLUGIN_ROOT
param(
    [Parameter(Mandatory=$false)]
    [string]$DestinationPath = $env:PLUGIN_ROOT
)

$DownloadUrl = "https://github.com/ouyangwenzhe-51aes/cim-skills/archive/refs/heads/main.zip"
$TempDir = $env:TEMP
$ZipFile = Join-Path $TempDir "cim-skills-main.zip"
#$ExtractDir = Join-Path $TempDir "cim-skills-main"

Write-Host "Starting download..." -ForegroundColor Green
Invoke-WebRequest -Uri $DownloadUrl -OutFile $ZipFile -ErrorAction Stop
Write-Host "Download completed: $ZipFile" -ForegroundColor Green

Write-Host "Starting extraction..." -ForegroundColor Green
Expand-Archive -Path $ZipFile -DestinationPath $TempDir -Force -ErrorAction Stop
Write-Host "Extraction completed" -ForegroundColor Green

# GitHub 会自动加 -main 后缀，目标目录只需要该目录下的内容
$ExtractedDir = Join-Path $TempDir "cim-skills-main"
if (-not (Test-Path -LiteralPath $ExtractedDir -PathType Container)) {
    Write-Host "Error: extracted directory does not exist or is not a directory" -ForegroundColor Red
    exit 1
}

if ([string]::IsNullOrWhiteSpace($DestinationPath)) {
    Write-Host "Error: DestinationPath is not provided and PLUGIN_ROOT is not set" -ForegroundColor Red
    exit 1
}

Write-Host "Installing to destination: $DestinationPath" -ForegroundColor Green
if (-not (Test-Path -LiteralPath $DestinationPath)) {
    New-Item -Path $DestinationPath -ItemType Directory -Force | Out-Null
} else {
    Get-ChildItem -LiteralPath $DestinationPath -Force | Remove-Item -Recurse -Force
}
Get-ChildItem -LiteralPath $ExtractedDir -Force | Move-Item -Destination $DestinationPath -Force -ErrorAction Stop
Remove-Item -Path $ExtractedDir -Recurse -Force
Write-Host "Install completed" -ForegroundColor Green

# 清理临时文件
Remove-Item -Path $ZipFile -Force
Write-Host "Temporary files cleaned" -ForegroundColor Green
Write-Host "All operations completed" -ForegroundColor Green