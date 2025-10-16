
$workDir = $PSScriptRoot

if (-not ($env:VCPKG_ROOT)) {
    $env:VCPKG_ROOT = $env:VCPKG_INSTALLATION_ROOT
}
if (-not (Test-Path "$env:VCPKG_ROOT\vcpkg.exe")) {
    Write-Error "No vcpkg.exe"
    exit 1
}

if (-not (Test-Path '.\libs\mpv\lib\mpv.lib')) {
    $mpvUrl = 'https://github.com/ikas-mc/wiliwili-uwp-poc/releases/download/0.4/x64-uwp-mpv.zip'
    & curl.exe -L -o '.\x64-uwp-mpv.zip' $mpvUrl
    Expand-Archive '.\x64-uwp-mpv.zip' -DestinationPath '.\libs\mpv\' -Force
}

if (-not (Test-Path '.\libs\mpv\lib\mpv.lib')) {
    Write-Error "Failed to install x64-uwp-mpv.zip"
    exit 1
}

if (-not (Test-Path "./borealis")) {
    & git clone --depth 1 -b winrt-dev https://github.com/ikas-mc/borealis
}

if (-not (Test-Path "./switchfin")) {
    & git clone --depth 1 -b uwp-dev https://github.com/ikas-mc/switchfin-uwp
}

Set-Location $workDir

& cmake --preset=uwp-release

& msbuild build\switchfin-uwp.vcxproj /m /p:configuration="release" /p:platform="x64" /p:AppxBundlePlatforms="x64" /p:UapAppxPackageBuildMode="SideloadOnly" /p:PackageOptionalProjectsInIdeBuilds=False
