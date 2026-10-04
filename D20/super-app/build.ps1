# Usage: ./build.ps1 [debug|release]
param(
    [ValidateSet("debug", "release")]
    [string]$Config = "debug"
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

if (-not $env:VCPKG_ROOT) {
    Write-Error "VCPKG_ROOT is not set"
}

$OverlayPorts = (Resolve-Path "$PSScriptRoot/../my-ports").Path

cmake -S . -B build `
    "-DCMAKE_TOOLCHAIN_FILE=$env:VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake" `
    "-DVCPKG_OVERLAY_PORTS=$OverlayPorts"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

cmake --build build --config $Config
exit $LASTEXITCODE
