# --- CONFIGURATION ---
# If auto-detection fails, set these paths manually.
$ManualMSBuildPath = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
$ManualFlutterPath = "C:\flutter\bin\flutter.bat"
$env:PATH = "$env:PATH;C:\flutter\bin"
# ---------------------

function Get-MSBuildPath {
    if ($ManualMSBuildPath -and (Test-Path $ManualMSBuildPath)) { return $ManualMSBuildPath }
    
    $vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
    if (Test-Path $vswhere) {
        $path = & $vswhere -latest -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe
        if ($path) { return $path }
    }
    return $null
}

function Get-FlutterPath {
    if ($ManualFlutterPath -and (Test-Path $ManualFlutterPath)) { return $ManualFlutterPath }
    
    if (Get-Command "flutter" -ErrorAction SilentlyContinue) {
        return "flutter"
    }
    return $null
}

Write-Host "Checking environment..." -ForegroundColor Cyan

# 1. Check MSBuild
$msbuild = Get-MSBuildPath
if (-not $msbuild) {
    Write-Error "MSBuild not found. Please install Visual Studio 2022 with C++ workload."
}
Write-Host "Found MSBuild at: $msbuild" -ForegroundColor Green

# 2. Check Flutter
$flutter = Get-FlutterPath
if (-not $flutter) {
    Write-Warning "Flutter not found in PATH. Checking 'src' folder..."
    # Try looking in d:\rustdesk_src\flutter if it exists, although we can't access outside workspace strictly, 
    # but we are running in d:\rustdesk_src\rustdesk.
    # Maybe the user has it in a standard place.
    Write-Error "Flutter not found. Please ensure 'flutter' is in your PATH."
}
Write-Host "Found Flutter." -ForegroundColor Green

# 3. Check Nuget
$nuget = ".\nuget.exe"
if (-not (Test-Path $nuget)) {
    Write-Host "Nuget not found. Downloading..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile $nuget
}
Write-Host "Nuget ready." -ForegroundColor Green

# 4. Build RustDesk Core & Flutter Bundle
Write-Host "Building RustDesk (Flutter + Core)..." -ForegroundColor Cyan

# Ensure VCPKG_ROOT is set so hwcodec compiles correctly
if (-not $env:VCPKG_ROOT) {
    if (Test-Path "C:\vcpkg") {
        $env:VCPKG_ROOT = "C:\vcpkg"
    }
}
Write-Host "VCPKG_ROOT is set to: $env:VCPKG_ROOT"

# python build.py --portable --hwcodec --flutter --vram --skip-portable-pack
# Note: Ensure python is python 3
python build.py --portable --hwcodec --flutter --vram --skip-portable-pack
if ($LASTEXITCODE -ne 0) { throw "Build failed." }

# 5. Prepare Resources
Write-Host "Preparing Resources..." -ForegroundColor Cyan
$buildDir = "flutter\build\windows\x64\runner\Release"
if (-not (Test-Path $buildDir)) {
    throw "Build directory not found: $buildDir"
}

# 6. Build MSI
Write-Host "Building MSI..." -ForegroundColor Cyan
Push-Location "res\msi"
try {
    # Preprocess
    python preprocess.py --arp -d ..\..\rustdesk
    if ($LASTEXITCODE -ne 0) { throw "MSI Preprocess failed." }

    # Restore Nuget
    & "..\..\nuget.exe" restore msi.sln
    if ($LASTEXITCODE -ne 0) { throw "Nuget restore failed." }

    # Build Solution
    & $msbuild msi.sln /p:Configuration=Release /p:Platform=x64 /p:TargetVersion=Windows10
    if ($LASTEXITCODE -ne 0) { throw "MSI Build failed." }
    
    Write-Host "MSI Build Successful!" -ForegroundColor Green
    $msiPath = "Package\bin\x64\Release\en-us\Package.msi"
    Write-Host "MSI available at: $(Convert-Path $msiPath)" -ForegroundColor Green
}
finally {
    Pop-Location
}
