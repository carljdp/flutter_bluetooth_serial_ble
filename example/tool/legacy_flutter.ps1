

# Usage:
# ```powershell
# .\tool\legacy_flutter.ps1 clean`
# .\tool\legacy_flutter.ps1 devices list
# .\tool\legacy_flutter.ps1 run "--debug" "-d" "'SM J530F'"`
# .\tool\legacy_flutter.ps1 build apk "--debug" "-d" "'SM J530F'"`
# ```



$dirSep = [System.IO.Path]::DirectorySeparatorChar
$pathSep = [System.IO.Path]::PathSeparator

# Function to get the Flutter SDK path from the local.properties file
function Get-FlutterSdkPathLocal {
    $localPropertiesPath = "./android/local.properties"
    $pattern = "^flutter\.sdk=(.*)(?:\s+#.*)?$"

    if (-not (Test-Path $localPropertiesPath)) {
        Write-Error "local.properties file not found in the ./android directory."
        exit 1
    }

    $line = Get-Content -Path $localPropertiesPath | Where-Object { $_ -match $pattern } | Select-Object -First 1
    if (-not $line) {
        Write-Error "Could not find the flutter sdk path in the local.properties file."
        exit 1
    }

    $path = $line -replace $pattern, '$1'

    $path = $path -replace "\\\\", "$dirSep"

    return $path
}

# Function to get the Flutter SDK path from the global PATH environment variable
function Get-FlutterSdkPathGlobal {
    $pathEnvVar = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Machine)
    $paths = $pathEnvVar -split "\$pathSep" # backslash to escape patter
    $results = @()

    foreach ($path in $paths) {
        $elements = $path -split "\$dirSep" # backslash to escape patter
         if ($elements.Length -ge 2) {
            if ($elements[-2] -eq "flutter" -and $elements[-1] -eq "bin") {
                $sdkPath = $elements[0..($elements.Length - 2)] -join "$dirSep"
                $results += $sdkPath
            }
        }
    }

    if ($results.Length -eq 0) {
        Write-Error "Could not find the flutter bin path in the PATH environment variable."
        exit 1
    }

    if ($results.Length -gt 1) {
        Write-Error "Found more than one flutter bin path in the PATH environment variable."
        exit 1
    }

    return $results[0]
}

# Function to run a Flutter command with the local Flutter SDK path added to PATH
function Run-LegacyFlutterCommand {
    param (
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$AllArgs
    )

    Write-Host ""

    $flutterSdkLocal = Get-FlutterSdkPathLocal
    if (-not (Test-Path "$flutterSdkLocal${dirSep}bin")) {
        Write-Error "The Flutter SDK bin path does not exist: $flutterSdkLocal${dirSep}bin"
        exit 1
    }

    $env:PATH = "${flutterSdkLocal}${dirSep}bin${pathSep}${env:PATH}"
    Write-Host " -> Prefixed PATH with: $flutterSdkLocal"

    $env:JAVA_HOME = "C:\Tools\JetBrains\Android Studio\jbr"
    if (-not (Test-Path $env:JAVA_HOME)) {
        Write-Error "The JAVA_HOME path does not exist: $env:JAVA_HOME"
        exit 1
    }
    Write-Host " -> Set JAVA_HOME to:   $env:JAVA_HOME"

    # Prefix with 'flutter'
    $commandArray = @('flutter') + $AllArgs

    # Join all elements with spaces
    $commandString = $commandArray -join ' '

    Write-Host ""
    Write-Host "Running: $commandString"
    Write-Host ""
    Write-Host "--- Start ---"
    Write-Host ""
    Invoke-Expression $commandString
    Write-Host ""
    Write-Host "--- Done ----"
    Write-Host ""
}

# Forward the string args passed to this script
Run-LegacyFlutterCommand @args
