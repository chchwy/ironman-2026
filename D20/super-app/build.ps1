# Usage: ./build.ps1 [debug|release]
param(
    [ValidateSet("debug", "release")]
    [string]$Config = "debug"
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

cmake --preset default
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

cmake --build --preset $Config
exit $LASTEXITCODE
