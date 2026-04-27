param(
    [string]$JdkHome = "D:\tools\jdks\temurin-21",
    [string]$GradleWrapper = "",
    [string]$ProjectDir = $PSScriptRoot,
    [switch]$SkipNpm,
    [switch]$SkipTests
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-PathExists {
    param(
        [string]$PathValue,
        [string]$Message
    )

    if (-not (Test-Path -LiteralPath $PathValue)) {
        throw $Message
    }
}

$resolvedProjectDir = (Resolve-Path -LiteralPath $ProjectDir).Path

if (-not $GradleWrapper) {
    $GradleWrapper = Join-Path $resolvedProjectDir "gradlew.bat"
}
$resolvedGradleWrapper = (Resolve-Path -LiteralPath $GradleWrapper).Path

Assert-PathExists -PathValue $resolvedGradleWrapper -Message "Gradle wrapper was not found at '$resolvedGradleWrapper'."

if (-not (Test-Path -LiteralPath (Join-Path $JdkHome "bin\java.exe"))) {
    if ($env:JAVA_HOME -and (Test-Path -LiteralPath (Join-Path $env:JAVA_HOME "bin\java.exe"))) {
        $JdkHome = $env:JAVA_HOME
        Write-Host "Default JDK path not found; using JAVA_HOME: $JdkHome"
    }
}

if (-not (Test-Path -LiteralPath (Join-Path $JdkHome "bin\java.exe"))) {
    throw "JDK not found. Expected java.exe at '$JdkHome\bin\java.exe' or set JAVA_HOME to a JDK 21 install."
}

$resolvedJdkHome = (Resolve-Path -LiteralPath $JdkHome).Path
Assert-PathExists -PathValue (Join-Path $resolvedJdkHome "bin\java.exe") -Message "java.exe was not found under '$resolvedJdkHome'."

$env:JAVA_HOME = $resolvedJdkHome
$env:Path = "$resolvedJdkHome\bin;$env:Path"

$resourcesDir = Join-Path $resolvedProjectDir "src\main\resources"
if (-not $SkipNpm) {
    Assert-PathExists -PathValue (Join-Path $resourcesDir "package.json") -Message "package.json not found under '$resourcesDir'."
    Push-Location $resourcesDir
    try {
        $npm = Get-Command npm -ErrorAction SilentlyContinue
        if (-not $npm) {
            $distIndex = Join-Path $resourcesDir "dist\index.html"
            if (Test-Path -LiteralPath $distIndex) {
                Write-Warning "npm was not found in PATH, but '$distIndex' exists. Skipping frontend build."
            } else {
                throw "npm was not found in PATH and '$distIndex' is missing. Install Node.js or run with -SkipNpm only after building dist/."
            }
        } else {
            Write-Host "Running npm run build in $resourcesDir"
            & $npm run build
            if ($LASTEXITCODE -ne 0) {
                throw "npm run build failed with exit code $LASTEXITCODE."
            }
        }
    } finally {
        Pop-Location
    }
}

$stagingRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("MGMeter-portable-" + [System.Guid]::NewGuid().ToString("N"))
$portableAppDir = Join-Path $stagingRoot "app"
$portableRuntimeDir = Join-Path $stagingRoot "runtime"
$installDir = Join-Path $resolvedProjectDir "build\install\MGMeter"
$packagingDir = Join-Path $resolvedProjectDir "packaging"
$stalePortableDir = Join-Path $resolvedProjectDir "build\portable"

$buildGradlePath = Join-Path $resolvedProjectDir "build.gradle.kts"
$appVersion = "dev"
if (Test-Path -LiteralPath $buildGradlePath) {
    $pattern = '^\s*version\s*=\s*"([^"]+)"\s*$'
    $m = [regex]::Match(
        (Get-Content -LiteralPath $buildGradlePath -Raw),
        $pattern,
        [System.Text.RegularExpressions.RegexOptions]::Multiline
    )
    if ($m.Success) { $appVersion = $m.Groups[1].Value }
}
$zipPath = Join-Path $resolvedProjectDir ("build\distributions\MGMeter-portable-{0}.zip" -f $appVersion)

$gradleTasks = @()
$gradleTasks += "clean"
if (-not $SkipTests) {
    $gradleTasks += "test"
}
$gradleTasks += "installDist"

Write-Host "Using JAVA_HOME: $resolvedJdkHome"
Write-Host "Running Gradle tasks: $($gradleTasks -join ', ')"

& $resolvedGradleWrapper -p $resolvedProjectDir @gradleTasks
if ($LASTEXITCODE -ne 0) {
    throw "Gradle build failed with exit code $LASTEXITCODE."
}

Assert-PathExists -PathValue $installDir -Message "installDist output was not created at '$installDir'."
Assert-PathExists -PathValue $packagingDir -Message "Packaging assets were not found at '$packagingDir'."

if (Test-Path -LiteralPath $stalePortableDir) {
    Remove-Item -LiteralPath $stalePortableDir -Recurse -Force
}

if (Test-Path -LiteralPath $stagingRoot) {
    Remove-Item -LiteralPath $stagingRoot -Recurse -Force
}

New-Item -ItemType Directory -Path $portableAppDir -Force | Out-Null
New-Item -ItemType Directory -Path $portableRuntimeDir -Force | Out-Null

Copy-Item -Path (Join-Path $installDir "*") -Destination $portableAppDir -Recurse -Force

foreach ($entry in @("bin", "conf", "legal", "lib")) {
    Copy-Item -LiteralPath (Join-Path $resolvedJdkHome $entry) -Destination (Join-Path $portableRuntimeDir $entry) -Recurse -Force
}
Copy-Item -LiteralPath (Join-Path $resolvedJdkHome "release") -Destination (Join-Path $portableRuntimeDir "release") -Force

Copy-Item -LiteralPath (Join-Path $packagingDir "RunMGMeter.bat") -Destination (Join-Path $stagingRoot "RunMGMeter.bat") -Force
Copy-Item -LiteralPath (Join-Path $packagingDir "RunMGMeter.vbs") -Destination (Join-Path $stagingRoot "RunMGMeter.vbs") -Force
Copy-Item -LiteralPath (Join-Path $packagingDir "RunMGMeterElevated.cmd") -Destination (Join-Path $stagingRoot "RunMGMeterElevated.cmd") -Force
Copy-Item -LiteralPath (Join-Path $packagingDir "README-PORTABLE.txt") -Destination (Join-Path $stagingRoot "README-PORTABLE.txt") -Force

if (Test-Path -LiteralPath $zipPath) {
    Remove-Item -LiteralPath $zipPath -Force
}

New-Item -ItemType Directory -Path (Split-Path -Parent $zipPath) -Force | Out-Null
Compress-Archive -Path (Join-Path $stagingRoot "*") -DestinationPath $zipPath -Force
Remove-Item -LiteralPath $stagingRoot -Recurse -Force

Write-Host ""
Write-Host "Portable zip:    $zipPath"
