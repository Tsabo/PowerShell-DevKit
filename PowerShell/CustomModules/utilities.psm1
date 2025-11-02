function clean {
    Get-ChildItem -Path . -Include bin, obj -Recurse -Force |
        ForEach-Object { Remove-Item $_.FullName -Recurse -Force }
}

function y {
    $tmp = (New-TemporaryFile).FullName
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp -Encoding UTF8
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        z $cwd
    }
    Remove-Item -Path $tmp
}

function Open-Solution {
    param([string]$solution = "*.sln")
    $sln = Get-ChildItem $solution | Select-Object -First 1
    if ($sln) {
        # Use vswhere to find the latest Visual Studio installation
        $vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
        
        if (Test-Path $vswhere) {
            # Find the latest VS installation with devenv.exe, preferring Preview releases
            $vsInstall = & $vswhere -latest -prerelease -products * -requires Microsoft.VisualStudio.Component.CoreEditor -property installationPath
            
            if ($vsInstall) {
                $devenv = Join-Path $vsInstall "Common7\IDE\devenv.exe"
                if (Test-Path $devenv) {
                    & $devenv $sln.FullName
                    return
                }
            }
        }
        
        # Fallback: try to find devenv.exe in PATH
        $devenvInPath = Get-Command devenv.exe -ErrorAction SilentlyContinue
        if ($devenvInPath) {
            & $devenvInPath.Source $sln.FullName
        }
        else {
            Write-Host "No Visual Studio installation found." -ForegroundColor Red
        }
    }
    else {
        Write-Host "No solution file found." -ForegroundColor Yellow
    }
}
