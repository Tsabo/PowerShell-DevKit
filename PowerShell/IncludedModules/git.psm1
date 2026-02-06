function git-default
{
    (git symbolic-ref refs/remotes/origin/HEAD) -replace 'refs/remotes/origin/', ''
}

function git-diff {
    git --no-pager diff --no-prefix --unified=100000 --minimal "$((git merge-base $(git-default) --fork-point))..HEAD"
}

function git-update-submodules {
    param(
        [string]$BasePath = ".",
        [switch]$PullMainRepo
    )

    Write-Host "🔍 Scanning for Git repositories under: $BasePath"

    if (-not (Test-Path $BasePath)) {
        Write-Error "Base path does not exist: $BasePath"
        return
    }

    # Find all directories containing a .git folder
    $repos = Get-ChildItem -Path $BasePath -Directory -Recurse |
        Where-Object { Test-Path (Join-Path $_.FullName ".git") }

    if ($repos.Count -eq 0) {
        Write-Host "⚠️ No Git repositories found under: $BasePath"
        return
    }

    foreach ($repo in $repos) {
        Write-Host ""
        Write-Host "📁 Processing repo: $($repo.FullName)"
        Set-Location $repo.FullName

        if ($PullMainRepo) {
            Write-Host "⬇️ Pulling latest changes for main repo..."
            git pull
        }

        Write-Host "🔧 Initializing submodules..."
        git submodule init

        Write-Host "🔄 Updating submodules recursively..."
        git submodule update --recursive --remote

        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Submodules updated successfully for $($repo.Name)"
        } else {
            Write-Host "❌ Failed to update submodules for $($repo.Name)"
        }
    }

    Write-Host ""
    Write-Host "🎉 All repositories processed."
}