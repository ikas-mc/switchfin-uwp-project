$workDir = $PSScriptRoot

if (-not ($env:VCPKG_ROOT)) {
    $env:VCPKG_ROOT = $env:VCPKG_INSTALLATION_ROOT
}
if (-not (Test-Path "$env:VCPKG_ROOT\vcpkg.exe")) {
    Write-Error "No vcpkg.exe"
    exit 1
}

if (-not (Test-Path '.\libs\mpv\lib\mpv.lib')) {
    $mpvUrl = 'https://github.com/ikas-mc/wiliwili-uwp-poc/releases/download/0.4/mpv-uwp-x64-luajit.zip'
    & curl.exe -L -o '.\mpv.zip' $mpvUrl
    Expand-Archive '.\mpv.zip' -DestinationPath '.\libs\mpv\' -Force
}
if (-not (Test-Path '.\libs\mpv\lib\mpv.lib')) {
    Write-Error "Failed to install mpv.zip"
    exit 1
}

if (-not (Test-Path "./borealis")) {
    & git clone --depth 1 -b winrt-dev https://github.com/ikas-mc/borealis
}
if (-not (Test-Path "./switchfin")) {
    & git clone --depth 1 -b uwp-dev https://github.com/ikas-mc/switchfin-uwp switchfin
}

Set-Location $workDir

# update build version
if ($env:VERSION_BUILD_NUMBER) {
    $appxManifestPath = Convert-Path ".\switchfin-uwp\package.appxManifest"
    [xml]$manifest = Get-Content -Path $appxManifestPath
    $version = $manifest.Package.Identity.Version
    $versionParts = $version -split '\.'
    if ($versionParts.Length -eq 4) {
        $versionParts[3] = $env:VERSION_BUILD_NUMBER
        $manifest.Package.Identity.Version = $versionParts -join "."
    }
    else {
        Write-Error "Version format error: $version"
        exit 1
    }
    Write-Host "package new version: $($manifest.Package.Identity.Version)"
    $manifest.Save($appxManifestPath)
}

# build
& cmake --preset=uwp-release
& msbuild build\switchfin-uwp.vcxproj /m /p:configuration="release" /p:platform="x64" /p:AppxBundlePlatforms="x64" /p:UapAppxPackageBuildMode="SideloadOnly" /p:PackageOptionalProjectsInIdeBuilds=False
