# MkDocs Helper Script
# Adds Python to PATH and runs mkdocs commands

param(
    [Parameter(Mandatory = $false, Position = 0)]
    [string]$Command = "serve",

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Args
)

# Add Python to PATH for this session
$pythonPath = "C:\Program Files\Python311"
$pythonScripts = "$pythonPath\Scripts"
$userScripts = "$env:APPDATA\Python\Python311\Scripts"

# Add to current session PATH
$env:PATH = "$pythonPath;$pythonScripts;$userScripts;$env:PATH"

# Run mkdocs via Python module
$mkdocsArgs = @($Command) + $Args
Write-Host "Running: python -m mkdocs $($mkdocsArgs -join ' ')" -ForegroundColor Cyan
python -m mkdocs @mkdocsArgs
