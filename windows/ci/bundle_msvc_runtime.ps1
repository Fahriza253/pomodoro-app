# Copies app-local MSVC CRT DLLs next to the Release exe (see docs/howto/build.md).
param(
  [string]$ReleaseDir = "build\windows\x64\runner\Release"
)

$ErrorActionPreference = "Stop"

$requiredDlls = @(
  "vcruntime140.dll",
  "vcruntime140_1.dll",
  "msvcp140.dll"
)

function Get-VersionSortKey([string]$name) {
  if ($name -match '^v(\d+)$') { return [version]"$($Matches[1]).0" }
  return [version]$name
}

function Find-VisualStudioInstallPath {
  $vswhere = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\Installer\vswhere.exe"
  if (-not (Test-Path $vswhere)) { throw "vswhere not found" }

  $requires = @(
    "Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
    "Microsoft.VisualStudio.Component.VC.Redist.14.Latest"
  )
  $installPath = & $vswhere -latest -products * -requires $requires -property installationPath
  if ($installPath) { return $installPath }

  Write-Warning "VS install without VC.Redist.14.Latest; falling back to VC tools only."
  $installPath = & $vswhere -latest -products * -requires "Microsoft.VisualStudio.Component.VC.Tools.x86.x64" -property installationPath
  if (-not $installPath) { throw "Visual Studio with VC++ tools not found" }
  return $installPath
}

function Find-RedistCrtDirectory([string]$installPath) {
  $msvcRedistRoot = Join-Path $installPath "VC\Redist\MSVC"
  if (-not (Test-Path $msvcRedistRoot)) { return $null }

  # ponytail: VS 2026 runners may list v145 before v143 even when only v143 has x64 CRT.
  foreach ($versionDir in (Get-ChildItem $msvcRedistRoot -Directory | Sort-Object { Get-VersionSortKey $_.Name } -Descending)) {
    $x64 = Join-Path $versionDir.FullName "x64"
    if (-not (Test-Path $x64)) { continue }
    $crtDir = Get-ChildItem $x64 -Directory -Filter "Microsoft.VC*.CRT" |
      Sort-Object Name -Descending |
      Select-Object -First 1
    if ($crtDir) { return $crtDir }
  }
  return $null
}

function Find-ToolsMsvcBinDirectory([string]$installPath) {
  $toolsRoot = Join-Path $installPath "VC\Tools\MSVC"
  if (-not (Test-Path $toolsRoot)) { return $null }

  $candidates = @()
  if ($env:VCToolsVersion) {
    $candidates += Join-Path $toolsRoot "$($env:VCToolsVersion)\bin\Hostx64\x64"
  }
  $candidates += Get-ChildItem $toolsRoot -Directory |
    Sort-Object Name -Descending |
    ForEach-Object { Join-Path $_.FullName "bin\Hostx64\x64" }

  foreach ($binDir in ($candidates | Select-Object -Unique)) {
    if (Test-Path $binDir) { return $binDir }
  }
  return $null
}

function Copy-CrtDlls([string]$sourceDir, [string]$destDir, [switch]$AllDlls) {
  if ($AllDlls) {
    Copy-Item (Join-Path $sourceDir "*.dll") $destDir -Force
    return
  }

  foreach ($dll in $requiredDlls) {
    $source = Join-Path $sourceDir $dll
    if (-not (Test-Path $source)) { throw "Missing required MSVC CRT DLL: $source" }
    Copy-Item $source $destDir -Force
  }

  Get-ChildItem $sourceDir -Filter "*.dll" |
    Where-Object { $_.Name -match '^(msvcp140_|concrt140|vccorlib140)' } |
    ForEach-Object { Copy-Item $_.FullName $destDir -Force }
}

function Assert-ReleaseCrtPresent([string]$destDir) {
  foreach ($dll in $requiredDlls) {
    if (-not (Test-Path (Join-Path $destDir $dll))) {
      throw "CRT bundle incomplete: missing $dll in $destDir"
    }
  }
}

if (-not (Test-Path $ReleaseDir)) { throw "Release dir not found: $ReleaseDir" }

$installPath = Find-VisualStudioInstallPath
$crtDir = Find-RedistCrtDirectory $installPath

if ($crtDir) {
  Write-Host "Bundling CRT (redist) from $($crtDir.FullName)"
  Copy-CrtDlls -sourceDir $crtDir.FullName -destDir $ReleaseDir -AllDlls
} else {
  Write-Warning "Redist CRT folder not found; using VC Tools bin fallback."
  $binDir = Find-ToolsMsvcBinDirectory $installPath
  if (-not $binDir) { throw "MSVC CRT not found under Redist or VC\Tools\MSVC" }
  Write-Host "Bundling CRT (tools) from $binDir"
  Copy-CrtDlls -sourceDir $binDir -destDir $ReleaseDir
}

Assert-ReleaseCrtPresent $ReleaseDir
Write-Host "MSVC runtime bundled into $ReleaseDir"
