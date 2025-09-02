#!/usr/bin/env pwsh
# PowerShell build script for Flutter app with pre-configured options

param (
    [string]$buildType = "release",
    [string]$target = "apk",
    [switch]$help = $false
)

# Show help if requested
if ($help) {
    Write-Host "FII Smart App Build Script"
    Write-Host "Usage: ./build_app.ps1 [-buildType <debug|profile|release>] [-target <apk|appbundle|ios|web>] [-help]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -buildType   Build type (default: release)"
    Write-Host "  -target      Build target (default: apk)"
    Write-Host "  -help        Show this help message"
    exit 0
}

# Validate build type
$validBuildTypes = @("debug", "profile", "release")
if (-not ($validBuildTypes -contains $buildType)) {
    Write-Host "Invalid build type: $buildType"
    Write-Host "Valid build types: $($validBuildTypes -join ', ')"
    exit 1
}

# Validate target
$validTargets = @("apk", "appbundle", "ios", "web")
if (-not ($validTargets -contains $target)) {
    Write-Host "Invalid target: $target"
    Write-Host "Valid targets: $($validTargets -join ', ')"
    exit 1
}

# Clear terminal
Clear-Host

# Show build configuration
Write-Host "Building FII Smart App..."
Write-Host "Build Type: $buildType"
Write-Host "Target: $target"
Write-Host ""

# Run flutter clean first to ensure a fresh build
Write-Host "Cleaning previous builds..."
flutter clean

# Run flutter build with the specified options
Write-Host "Building the app..."
flutter build $target --$buildType --no-tree-shake-icons

# Check if build was successful
if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Build successful!" -ForegroundColor Green
    
    # Show the build output path based on target
    if ($target -eq "apk") {
        Write-Host "APK file location: $(Resolve-Path "build\app\outputs\flutter-apk\app-$buildType.apk")"
    } elseif ($target -eq "appbundle") {
        Write-Host "App Bundle location: $(Resolve-Path "build\app\outputs\bundle\${buildType}Bundle\app-$buildType.aab")"
    } elseif ($target -eq "ios") {
        Write-Host "iOS build completed"
    } elseif ($target -eq "web") {
        Write-Host "Web build location: $(Resolve-Path "build\web")"
    }
} else {
    Write-Host ""
    Write-Host "Build failed!" -ForegroundColor Red
}
