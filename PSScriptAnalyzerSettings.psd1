# PSScriptAnalyzer settings for PowerShell-DevKit
# This file customizes which rules to run and their severity

@{
    # Use all default rules from PSGallery settings as baseline
    IncludeDefaultRules = $true
    
    # Severity levels to include
    Severity = @('Error', 'Warning', 'Information')
    
    # Rules to exclude (customize based on your project needs)
    ExcludeRules = @(
        # Profile-specific exclusions
        'PSAvoidGlobalVars',           # Profile often needs global scope
        'PSUseDeclaredVarsMoreThanAssignments'  # Profile has intentional one-time assignments
    )
    
    # Rules to include (in addition to defaults)
    IncludeRules = @(
        'PSUseCompatibleCmdlets',      # Ensure cmdlet compatibility
        'PSUseCompatibleSyntax',       # Ensure syntax compatibility
        'PSUseCompatibleCommands'      # Ensure command compatibility
    )
    
    # Custom rule configurations
    Rules = @{
        # PowerShell version compatibility
        PSUseCompatibleSyntax = @{
            Enable = $true
            TargetVersions = @('7.0', '7.1', '7.2', '7.3', '7.4')
        }
        
        PSUseCompatibleCmdlets = @{
            Enable = $true
            Compatibility = @('core-7.0.0-windows', 'core-7.0.0-linux', 'core-7.0.0-macos')
        }
        
        # Best practices
        PSAvoidUsingCmdletAliases = @{
            Enable = $true
            Whitelist = @('cd', 'ls', 'cat', 'man')  # Common aliases that are acceptable
        }
        
        PSUseCmdletCorrectly = @{
            Enable = $true
        }
        
        PSAvoidUsingPositionalParameters = @{
            Enable = $true
        }
        
        PSUseOutputTypeCorrectly = @{
            Enable = $true
        }
    }
}