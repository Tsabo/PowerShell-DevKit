function git-default {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Remote = "origin",

        [Parameter()]
        [switch]$VerboseOutput
    )

    <#
    .SYNOPSIS
    Returns the default branch name for a Git remote, with robust fallbacks.

    .DESCRIPTION
    The git-default function determines the default branch for a Git remote
    (commonly 'origin'). It first attempts to read the symbolic reference at
    refs/remotes/<remote>/HEAD. If that reference is missing or not configured,
    the function falls back to:

    1. Using `git ls-remote --symref` to resolve HEAD.
    2. Selecting the first remote branch alphabetically (useful in bare repos).

    This makes the function resilient across repositories that use 'main',
    'master', or any other default branch name, and across remotes that may not
    have HEAD configured.

    .PARAMETER Remote
    Specifies the remote to inspect. Defaults to 'origin'.

    .PARAMETER VerboseOutput
    Displays diagnostic information about how the default branch was resolved.

    .EXAMPLE
    git-default
    Returns the default branch for the 'origin' remote.

    .EXAMPLE
    git-default -Remote upstream
    Returns the default branch for the 'upstream' remote.

    .EXAMPLE
    git checkout (git-default)
    Checks out the default branch without needing to know its name.
    #>

    # Ensure we're inside a Git repo
    $isRepo = git rev-parse --is-inside-work-tree 2>$null
    if (-not $isRepo) {
        Write-Error "Not inside a Git repository."
        return
    }

    # Try the symbolic ref first (best case)
    $symbolic = git symbolic-ref "refs/remotes/$Remote/HEAD" 2>$null

    if ($VerboseOutput) {
        Write-Host "Symbolic ref: $symbolic" -ForegroundColor Cyan
    }

    if ($symbolic) {
        return ($symbolic -replace "refs/remotes/$Remote/", "")
    }

    # Fallback: check remote HEAD via ls-remote
    $lsRemote = git ls-remote --symref $Remote HEAD 2>$null |
        Select-String "ref:" |
        ForEach-Object {
            ($_ -split '\s+')[1] -replace "refs/heads/", ""
        }

    if ($VerboseOutput -and $lsRemote) {
        Write-Host "ls-remote HEAD: $lsRemote" -ForegroundColor Cyan
    }

    if ($lsRemote) {
        return $lsRemote
    }

    # Fallback: pick the first branch alphabetically (common in bare repos)
    $branches = git branch -r 2>$null |
        ForEach-Object { $_.Trim() -replace "$Remote/", "" } |
        Where-Object { $_ -ne "HEAD" }

    if ($VerboseOutput -and $branches) {
        Write-Host "Remote branches: $($branches -join ', ')" -ForegroundColor DarkYellow
    }

    if ($branches) {
        return ($branches | Select-Object -First 1)
    }

    Write-Error "Unable to determine default branch for remote '$Remote'."
}

function git-diff {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Remote = "origin",

        [Parameter()]
        [string]$Branch = $null,

        [Parameter()]
        [switch]$UseForkPoint,

        [Parameter()]
        [switch]$CommittedOnly,

        [Parameter()]
        [switch]$IncludeUntracked,

        [Parameter()]
        [switch]$VerboseOutput
    )

    <#
    .SYNOPSIS
    Shows a diff between the current working state (or HEAD) and the default branch (or a specified branch).

    .DESCRIPTION
    The git-diff function produces a unified diff between a reference branch and either
    your current working tree (default) or HEAD only. By default, it compares against
    the repository's default branch (commonly 'main' or 'master'), determined via git-default.

    The function supports:
    - Custom remotes (e.g., origin, upstream)
    - Custom branches
    - Using merge-base or fork-point
    - Including uncommitted changes (default) or restricting to committed history only
    - Optionally including untracked files
    - Verbose diagnostic output

    It uses a very large unified context (100000 lines) and --minimal to produce
    cleaner diffs useful for code review and patch generation.

    .PARAMETER Remote
    Specifies the Git remote whose default branch should be used. Defaults to 'origin'.

    .PARAMETER Branch
    Overrides the branch to diff against. If omitted, the default branch is used.

    .PARAMETER UseForkPoint
    Uses `git merge-base --fork-point` instead of the standard merge-base.

    .PARAMETER CommittedOnly
    Restricts the diff to committed history only (base..HEAD), excluding any
    uncommitted working tree or staged changes. By default, uncommitted changes
    are included.

    .PARAMETER IncludeUntracked
    Includes untracked files in the diff by running `git add -N` (intent-to-add)
    before diffing. Only relevant when uncommitted changes are included (i.e.,
    -CommittedOnly is not set). Note: this modifies the index by adding
    intent-to-add entries for untracked files.

    .PARAMETER VerboseOutput
    Displays diagnostic information about branch resolution and merge-base selection.

    .EXAMPLE
    git-diff
    Shows a diff between the default branch and your current working tree (including uncommitted changes).

    .EXAMPLE
    git-diff -CommittedOnly
    Shows a diff between the default branch and HEAD only, ignoring uncommitted changes.

    .EXAMPLE
    git-diff -IncludeUntracked
    Includes untracked files in the working-tree diff.

    .EXAMPLE
    git-diff -Branch develop
    Diffs against the 'develop' branch instead of the default.

    .EXAMPLE
    git-diff -UseForkPoint
    Uses fork-point instead of merge-base for more accurate diffs on rebased branches.
    #>

    # Ensure we're inside a Git repo
    $isRepo = git rev-parse --is-inside-work-tree 2>$null
    if (-not $isRepo) {
        Write-Error "Not inside a Git repository."
        return
    }

    # Determine branch to diff against
    if (-not $Branch) {
        $Branch = git-default -Remote $Remote
        if ($VerboseOutput) {
            Write-Host "Default branch resolved to: $Branch" -ForegroundColor Cyan
        }
    }

    if (-not $Branch) {
        Write-Error "Unable to determine branch to diff against."
        return
    }

    # Determine merge-base or fork-point
    $mergeBaseArgs = @()
    if ($UseForkPoint) {
        $mergeBaseArgs += "--fork-point"
    }
    $mergeBaseArgs += $Branch
    $mergeBaseArgs += "HEAD"

    $base = git merge-base @mergeBaseArgs 2>$null

    if ($VerboseOutput) {
        Write-Host "Merge base: $base" -ForegroundColor DarkYellow
    }

    if (-not $base) {
        Write-Error "Unable to determine merge-base between '$Branch' and HEAD."
        return
    }

    # Optionally stage untracked files as intent-to-add so they show up in the diff
    if ($IncludeUntracked -and -not $CommittedOnly) {
        git add -N . 2>$null | Out-Null
    }

    # Perform diff
    if ($CommittedOnly) {
        if ($VerboseOutput) {
            Write-Host "Diffing committed history only: $base..HEAD" -ForegroundColor DarkGray
        }
        git --no-pager diff --no-prefix --unified=100000 --minimal "$base..HEAD"
    }
    else {
        if ($VerboseOutput) {
            Write-Host "Diffing working tree against: $base" -ForegroundColor DarkGray
        }
        git --no-pager diff --no-prefix --unified=100000 --minimal $base
    }
}

function git-update-submodules {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter()]
        [string]$BasePath = ".",

        [Parameter()]
        [switch]$PullMainRepo,

        [Parameter()]
        [switch]$DryRun,

        [Parameter()]
        [switch]$VerboseOutput,

        [Parameter()]
        [string[]]$Exclude = @(),

        [Parameter()]
        [int]$Depth = [int]::MaxValue
    )

    <#
    .SYNOPSIS
    Updates Git submodules for all repositories under a specified directory tree.

    .DESCRIPTION
    The git-update-submodules function scans a directory tree for Git repositories
    and updates their submodules safely and consistently. It supports:

    - Pulling the main repository before updating submodules
    - Dry-run mode for previewing actions without making changes
    - Verbose diagnostic output
    - Excluding specific repositories by name
    - Limiting recursion depth
    - Proper handling of worktrees and nested repositories
    - Safe directory handling using Push-Location / Pop-Location
    - SupportsShouldProcess for -WhatIf and -Confirm

    This makes the function ideal for multi-repo workspaces, monorepos, and
    development environments containing many nested Git projects.

    .PARAMETER BasePath
    The root directory to scan for Git repositories. Defaults to the current directory.

    .PARAMETER PullMainRepo
    Pulls the main repository before updating submodules. Useful when submodules
    track remote branches.

    .PARAMETER DryRun
    Shows what actions would be taken without performing them. No Git commands are executed.

    .PARAMETER VerboseOutput
    Displays detailed diagnostic information about repository discovery and actions taken.

    .PARAMETER Exclude
    A list of repository directory names to skip during processing.

    .PARAMETER Depth
    Limits recursion depth relative to BasePath. Useful for large directory trees.

    .EXAMPLE
    git-update-submodules
    Updates all submodules under the current directory.

    .EXAMPLE
    git-update-submodules -PullMainRepo
    Pulls each repository before updating its submodules.

    .EXAMPLE
    git-update-submodules -DryRun
    Shows what would be updated without making any changes.

    .EXAMPLE
    git-update-submodules -Exclude @("docs", "tools")
    Skips the docs and tools repositories.

    .EXAMPLE
    git-update-submodules -Depth 2
    Only processes repositories within two directory levels of BasePath.
    #>

    Write-Host "🔍 Scanning for Git repositories under: $BasePath"

    if (-not (Test-Path $BasePath)) {
        Write-Error "Base path does not exist: $BasePath"
        return
    }

    # Find all directories containing a .git folder or file (worktrees)
    $repos = Get-ChildItem -Path $BasePath -Directory -Recurse -Force |
        Where-Object {
            $gitPath = Join-Path $_.FullName ".git"
            (Test-Path $gitPath -PathType Leaf) -or
            (Test-Path $gitPath -PathType Container)
        } |
        Where-Object {
            $_.FullName.Split([IO.Path]::DirectorySeparatorChar).Count -le
            ($BasePath.Split([IO.Path]::DirectorySeparatorChar).Count + $Depth)
        } |
        Where-Object {
            $Exclude -notcontains $_.Name
        }


    if ($repos.Count -eq 0) {
        Write-Host "⚠️ No Git repositories found under: $BasePath"
        return
    }

    Write-Host "📁 Found $($repos.Count) repositories."

    foreach ($repo in $repos) {
        Write-Host ""
        Write-Host "📁 Processing repo: $($repo.FullName)"

        Push-Location $repo.FullName
        try {
            if ($PullMainRepo) {
                Write-Host "⬇️ Pulling latest changes..."
                if ($DryRun) {
                    Write-Host "[DryRun] git pull"
                }
                elseif ($PSCmdlet.ShouldProcess($repo.FullName, "git pull")) {
                    git pull
                }
            }

            Write-Host "🔧 Initializing submodules..."
            if ($DryRun) {
                Write-Host "[DryRun] git submodule init"
            }
            elseif ($PSCmdlet.ShouldProcess($repo.FullName, "git submodule init")) {
                git submodule init
            }

            Write-Host "🔄 Updating submodules recursively..."
            if ($DryRun) {
                Write-Host "[DryRun] git submodule update --recursive --remote"
            }
            elseif ($PSCmdlet.ShouldProcess($repo.FullName, "git submodule update")) {
                git submodule update --recursive --remote
            }

            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Submodules updated successfully for $($repo.Name)"
            }
            else {
                Write-Host "❌ Failed to update submodules for $($repo.Name)"
            }
        }
        finally {
            Pop-Location
        }
    }

    Write-Host ""
    Write-Host "🎉 All repositories processed."
}

function git-reset-working-tree {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [switch]$Force,
        [switch]$DryRun,
        [switch]$VerboseOutput
    )

    <#
    .SYNOPSIS
    Resets the working tree by discarding all local changes and removing all untracked files.

    .DESCRIPTION
    The git-reset-working-tree function performs a destructive reset of the current
    Git working tree. It does two things:

    1. `git reset --hard HEAD`
       Restores all tracked files to their state at HEAD, discarding any local
       modifications.

    2. `git clean -fd`
       Removes all untracked files and directories from the working tree.

    The function includes safety checks, optional dry-run mode, verbose output,
    and a -Force switch to skip confirmation.

    .PARAMETER Force
    Skips the confirmation prompt and performs the reset immediately.

    .PARAMETER DryRun
    Shows what actions *would* be taken without performing them.

    .PARAMETER VerboseOutput
    Displays detailed diagnostic information.

    .EXAMPLE
    git-reset-working-tree
    Prompts for confirmation, then resets tracked files and removes untracked files.

    .EXAMPLE
    git-reset-working-tree -Force
    Performs the reset without prompting.

    .EXAMPLE
    git-reset-working-tree -DryRun
    Shows what would be reset or deleted without making changes.
    #>

    # Ensure we're inside a Git repo
    $isRepo = git rev-parse --is-inside-work-tree 2>$null
    if (-not $isRepo) {
        Write-Error "Not inside a Git repository."
        return
    }

    # Safety confirmation unless -Force is used
    if (-not $Force -and -not $DryRun) {
        Write-Host "This will discard ALL local changes and delete ALL untracked files." -ForegroundColor Yellow
        $response = Read-Host "Continue? (y/N)"
        if ($response -notin @("y", "Y")) {
            Write-Host "Aborted."
            return
        }
    }

    Write-Host "Resetting tracked files to HEAD..." -ForegroundColor Cyan
    if ($DryRun) {
        Write-Host "[DryRun] git reset --hard HEAD"
    }
    elseif ($PSCmdlet.ShouldProcess("Working tree", "git reset --hard HEAD")) {
        git reset --hard HEAD
    }

    Write-Host "Cleaning untracked files..." -ForegroundColor Cyan
    if ($DryRun) {
        Write-Host "[DryRun] git clean -fd"
    }
    elseif ($PSCmdlet.ShouldProcess("Working tree", "git clean -fd")) {
        git clean -fd
    }

    if ($VerboseOutput) {
        Write-Host "Verbose: Reset and clean operations completed." -ForegroundColor DarkGray
    }

    Write-Host "Working tree reset complete." -ForegroundColor Green
}
