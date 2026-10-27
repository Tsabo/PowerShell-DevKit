BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '..\PowerShell\IncludedModules\git.psm1') -Force

    function New-TestRepo {
        param([hashtable]$Remotes = @{})

        $path = Join-Path $TestDrive ([guid]::NewGuid())
        git init --quiet $path
        foreach ($name in $Remotes.Keys) {
            git -C $path remote add $name $Remotes[$name]
        }
        return $path
    }
}

Describe 'git-remote-ssh' {
    AfterEach {
        Pop-Location -ErrorAction SilentlyContinue
    }

    Context 'HTTPS remotes' {
        It 'converts <Url> to <Expected>' -ForEach @(
            @{ Url = 'https://github.com/Trecerdo-LLC/Trecerdo.Ascend.Next.git'; Expected = 'git@github.com:Trecerdo-LLC/Trecerdo.Ascend.Next.git' }
            @{ Url = 'https://github.com/Owner/Repo'; Expected = 'git@github.com:Owner/Repo.git' }
            @{ Url = 'https://user@github.com/Owner/Repo.git/'; Expected = 'git@github.com:Owner/Repo.git' }
            @{ Url = 'http://gitlab.example.com:8443/group/sub/repo.git'; Expected = 'git@gitlab.example.com:group/sub/repo.git' }
        ) {
            Push-Location (New-TestRepo -Remotes @{ origin = $Url })

            git-remote-ssh 6>$null

            git remote get-url origin | Should -Be $Expected
        }

        It 'converts the remote named by -Remote and leaves others alone' {
            Push-Location (New-TestRepo -Remotes @{
                    origin   = 'https://github.com/Owner/Repo.git'
                    upstream = 'https://github.com/Upstream/Repo.git'
                })

            git-remote-ssh -Remote upstream 6>$null

            git remote get-url upstream | Should -Be 'git@github.com:Upstream/Repo.git'
            git remote get-url origin | Should -Be 'https://github.com/Owner/Repo.git'
        }

        It 'does not change the remote with -DryRun' {
            Push-Location (New-TestRepo -Remotes @{ origin = 'https://github.com/Owner/Repo.git' })

            $output = git-remote-ssh -DryRun 6>&1

            git remote get-url origin | Should -Be 'https://github.com/Owner/Repo.git'
            "$output" | Should -BeLike '*git@github.com:Owner/Repo.git*'
        }

        It 'does not change the remote with -WhatIf' {
            Push-Location (New-TestRepo -Remotes @{ origin = 'https://github.com/Owner/Repo.git' })

            git-remote-ssh -WhatIf 6>$null

            git remote get-url origin | Should -Be 'https://github.com/Owner/Repo.git'
        }
    }

    Context 'Remotes that are already SSH' {
        It 'leaves <Url> unchanged' -ForEach @(
            @{ Url = 'git@github.com:Owner/Repo.git' }
            @{ Url = 'ssh://git@github.com/Owner/Repo.git' }
        ) {
            Push-Location (New-TestRepo -Remotes @{ origin = $Url })

            git-remote-ssh 6>$null

            git remote get-url origin | Should -Be $Url
        }
    }

    Context 'Errors' {
        It 'fails when the remote does not exist' {
            Push-Location (New-TestRepo)

            { git-remote-ssh -Remote missing -ErrorAction Stop } | Should -Throw "*Remote 'missing' not found*"
        }

        It 'fails when the URL is not HTTPS' {
            Push-Location (New-TestRepo -Remotes @{ origin = 'file:///srv/repo.git' })

            { git-remote-ssh -ErrorAction Stop } | Should -Throw '*not a recognized HTTPS URL*'
            git remote get-url origin | Should -Be 'file:///srv/repo.git'
        }

        It 'fails outside a Git repository' {
            $dir = New-Item -ItemType Directory -Path (Join-Path $TestDrive ([guid]::NewGuid()))
            Push-Location $dir

            { git-remote-ssh -ErrorAction Stop } | Should -Throw '*Not inside a Git repository*'
        }
    }
}
