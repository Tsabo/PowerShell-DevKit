using namespace System.Management.Automation
using namespace System.Management.Automation.Language

# Skip profile if running in VS Code
if ($env:TERM_PROGRAM -eq "vscode") {
    return
}

# Load PSReadLine for ConsoleHost
if ($host.Name -eq 'ConsoleHost') {
    Import-Module PSReadLine
}

# Set UTF-8 encoding
[console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

# Profile directory
$profileDir = Split-Path -Parent $PROFILE

# Add script directories to PATH for this session
# IncludedScripts - bundled with repo
# CustomScripts - user-specific (auto-created, git-ignored)
$includedScriptsDir = Join-Path $profileDir "IncludedScripts"
$customScriptsDir = Join-Path $profileDir "CustomScripts"

$scriptPaths = @()
if (Test-Path $includedScriptsDir) { $scriptPaths += $includedScriptsDir }
if (Test-Path $customScriptsDir) { $scriptPaths += $customScriptsDir }

if ($scriptPaths.Count -gt 0) {
    $env:PATH = ($scriptPaths -join ";") + ";$env:PATH"
}

# Deferred module loading
function Import-CustomModules {
    # Store original title
    $originalTitle = $Host.UI.RawUI.WindowTitle

    try {
        # Auto-discover custom modules from CustomModules directory
        # Any .psm1 file in CustomModules/ will be automatically loaded
        # Modules are loaded alphabetically - use numeric prefixes (01-, 02-) if load order matters
        $customModulesPath = Join-Path $profileDir "CustomModules"
        $customModules = if (Test-Path $customModulesPath) {
            Get-ChildItem -Path $customModulesPath -Filter "*.psm1" -ErrorAction SilentlyContinue |
                Sort-Object Name |
                ForEach-Object {
                    @{ Type = "CustomModule"; Name = "CustomModules\$($_.Name)"; Options = @{ WarningAction = "SilentlyContinue" } }
                }
        }
        else { @() }

        # Included modules (bundled with repo, static list)
        $includedModules = @(
            @{ Type = "CustomModule"; Name = "IncludedModules\utilities.psm1"; Options = @{ WarningAction = "SilentlyContinue" } },
            @{ Type = "CustomModule"; Name = "IncludedModules\build_funtions.psm1"; Options = @{ WarningAction = "SilentlyContinue" } }
        )

        # Standard modules and tools (environment-dependent)
        $standardItems = @(
            @{ Type = "StandardModule"; Name = "posh-git"; Options = @{} },
            @{ Type = "StandardModule"; Name = "git-aliases"; Options = @{ DisableNameChecking = $true } },
            @{ Type = "StandardModule"; Name = "F7History"; Options = @{} },
            @{ Type = "StandardModule"; Name = "Microsoft.WinGet.CommandNotFound"; Options = @{} },
            @{ Type = "StandardModule"; Name = "EmojiTools"; Options = @{} },
            @{ Type = "StandardModule"; Name = "gsudoModule"; Options = @{} },
            @{ Type = "StandardModule"; Name = "PowerColorLS"; Options = @{} },
            @{ Type = "Tool"; Name = "zoxide"; Command = { Invoke-Expression (& { (zoxide init powershell | Out-String) }) } }
        )

        # Combine auto-discovered custom modules with included modules and standard items
        $itemsToLoad = $customModules + $includedModules + $standardItems

        $totalItems = $itemsToLoad.Count
        $currentItem = 0

        # Load all items
        foreach ($item in $itemsToLoad) {
            $currentItem++
            $Host.UI.RawUI.WindowTitle = "Loading modules [$currentItem/$totalItems]"

            try {
                $options = $item.Options
                switch ($item.Type) {
                    "CustomModule" {
                        if ($options.Count -gt 0) {
                            Import-Module "$profileDir\$($item.Name)" @options
                        }
                        else {
                            Import-Module "$profileDir\$($item.Name)"
                        }
                    }
                    "StandardModule" {
                        if ($options.Count -gt 0) {
                            Import-Module -Name $item.Name @options
                        }
                        else {
                            Import-Module -Name $item.Name
                        }
                    }
                    "Tool" {
                        & $item.Command
                    }
                }
            }
            catch {
                # Silently continue on module load errors to prevent profile from breaking
                Write-Debug "Failed to load $($item.Name): $($_.Exception.Message)"
            }
        }
    }
    finally {
        # Restore original title
        $Host.UI.RawUI.WindowTitle = $originalTitle
    }
}

Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
    Import-CustomModules
} | Out-Null

oh-my-posh --init --shell pwsh --config ~\OneDrive\PowerShell\Posh\iterm2.omp.json | Invoke-Expression

# Terminal Icons (conditionally)
if (-not (Get-Module -Name Terminal-Icons)) {
    Import-Module -Name Terminal-Icons
}

# Argument completers
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
    $Local:word = $wordToComplete.Replace('"', '""')
    $Local:ast = $commandAst.ToString().Replace('"', '""')
    winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
    dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

# PSReadLine configuration
if ($host.Name -eq 'ConsoleHost') {
    Set-PSReadLineOption -HistoryNoDuplicates
    Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
    Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Alt+b -Function ShellBackwardWord
    Set-PSReadLineKeyHandler -Key Alt+f -Function ShellForwardWord
    Set-PSReadLineKeyHandler -Key Alt+d -Function ShellKillWord
    Set-PSReadLineKeyHandler -Key Alt+Backspace -Function ShellBackwardKillWord
    Set-PSReadLineKeyHandler -Key RightArrow -BriefDescription ForwardOrAcceptWord -ScriptBlock {
        param($key, $arg)
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
        if ($cursor -lt $line.Length) {
            [Microsoft.PowerShell.PSConsoleReadLine]::ForwardChar($key, $arg)
        }
        else {
            [Microsoft.PowerShell.PSConsoleReadLine]::AcceptNextSuggestionWord($key, $arg)
        }
    }
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -EditMode Windows
}
