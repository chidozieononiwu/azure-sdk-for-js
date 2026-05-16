<#
.SYNOPSIS
    Caches an external package in Azure DevOps feed by enabling upstreaming and installing it.

.DESCRIPTION
    This script automates the process of caching a package in an Azure DevOps NPM feed:
    1. Toggles the "allow externally sourced versions" flag for the package via DevOps API
    2. Authenticates to the DevOps feed using artifacts-npm-credprovider
    3. Installs the package to cache it in the feed

    This is useful when you need to pre-cache packages in a DevOps feed to avoid 
    transient network failures during builds when upstream package registries are unavailable.

.PARAMETER PackageName
    The name of the package to cache (e.g., "lodash", "@babel/core").

.PARAMETER PackageVersion
  The specific package version to install.

.PARAMETER FeedName
    The name of the Azure DevOps feed (default: "azure-sdk-for-js").

.PARAMETER Organization
    The Azure DevOps organization name (default: "azure-sdk").

.PARAMETER Project
    The Azure DevOps project name (default: "internal").

.PARAMETER WhatIf
    Shows what would be executed without actually running the commands.

.EXAMPLE
    # Cache a specific version of lodash in the default feed
    .\Cache-ExternalPackage.ps1 -PackageName "lodash" -PackageVersion "4.17.21"

.EXAMPLE
  # Cache @babel/core with WhatIf to preview
  .\Cache-ExternalPackage.ps1 -PackageName "@babel/core" -PackageVersion "7.20.0" -WhatIf

.EXAMPLE
    # Cache package in a custom feed
  .\Cache-ExternalPackage.ps1 -PackageName "axios" -PackageVersion "1.7.9" -FeedName "my-custom-feed" -Organization "my-org"

.NOTES
    Requires:
    - PowerShell 7.0 or later
    - Azure DevOps PAT token (via environment variable: SYSTEM_ACCESSTOKEN or ADO_PAT)
    - npx and npm available in PATH
    - .npmrc file configured with the Azure DevOps feed

    Authentication:
    - In Azure Pipelines: Uses SYSTEM_ACCESSTOKEN if available
    - Locally: Uses ADO_PAT environment variable or prompts for credentials
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
  [Parameter(Mandatory = $false, HelpMessage = "Package name (e.g., 'lodash' or '@scope/package')")]
  [string]$PackageName = "",

  [Parameter(Mandatory = $false, HelpMessage = "Specific package version to install")]
  [string]$PackageVersion = "",

  [Parameter(Mandatory = $false, HelpMessage = "Azure DevOps feed name")]
  [string]$FeedName = "azure-sdk-for-js",

  [Parameter(Mandatory = $false, HelpMessage = "Azure DevOps organization")]
  [string]$Organization = "azure-sdk",

  [Parameter(Mandatory = $false, HelpMessage = "Azure DevOps project")]
  [string]$Project = "internal"
)

# Import logging utilities
. "${PSScriptRoot}\..\common\scripts\logging.ps1"
. "${PSScriptRoot}\..\common\scripts\Invoke-DevOpsAPI.ps1"

function Get-DevOpsAuthToken {
  <#
  .SYNOPSIS
    Retrieves Azure DevOps authentication token from environment or prompts user.
  #>
  
  # Try SYSTEM_ACCESSTOKEN first (Azure Pipelines)
  if (-not [string]::IsNullOrWhiteSpace($env:SYSTEM_ACCESSTOKEN)) {
    LogInfo "Using SYSTEM_ACCESSTOKEN from Azure Pipelines environment"
    return $env:SYSTEM_ACCESSTOKEN
  }

  # Try ADO_PAT environment variable
  if (-not [string]::IsNullOrWhiteSpace($env:ADO_PAT)) {
    LogInfo "Using ADO_PAT from environment"
    return $env:ADO_PAT
  }

  LogError "No Azure DevOps authentication token found. Set SYSTEM_ACCESSTOKEN or ADO_PAT environment variable."
  exit 1
}

function Test-ArtifactsCredProvider {
  <#
  .SYNOPSIS
    Verifies that artifacts-npm-credprovider is available.
  #>
  
  try {
    $output = npx artifacts-npm-credprovider --version 2>&1
    if ($LASTEXITCODE -eq 0) {
      LogInfo "artifacts-npm-credprovider is available"
      return $true
    }
  }
  catch {
    # Fall through to return false
  }

  LogWarning "artifacts-npm-credprovider not found. Attempting to install via npx..."
  return $false
}

function Enable-PackageUpstreaming {
  <#
  .SYNOPSIS
    Toggles the allowExternallySourcedVersions flag for a package in the DevOps feed.
  #>
  
  param (
    [Parameter(Mandatory = $true)]
    [string]$PackageName,
    [Parameter(Mandatory = $true)]
    [string]$FeedName,
    [Parameter(Mandatory = $true)]
    [string]$Organization,
    [Parameter(Mandatory = $true)]
    [string]$Project,
    [Parameter(Mandatory = $true)]
    [string]$AuthToken
  )

  try {
    LogInfo "Enabling externally sourced versions for package: $PackageName"
    
    $encodedAuthToken = Get-Base64EncodedToken -AuthToken $AuthToken
    
    $result = Set-PackageUpstreamingFlag `
      -Organization $Organization `
      -Project $Project `
      -FeedName $FeedName `
      -PackageName $PackageName `
      -Protocol "npm" `
      -AllowExternallySourcedVersions $true `
      -Base64EncodedToken $encodedAuthToken

    LogSuccess "Successfully enabled upstreaming for $PackageName"
    return $result
  }
  catch {
    LogError "Failed to enable upstreaming for $PackageName : $_"
    exit 1
  }
}

function Disable-PackageUpstreaming {
  <#
  .SYNOPSIS
    Disables the allowExternallySourcedVersions flag for a package in the DevOps feed.
  #>

  param (
    [Parameter(Mandatory = $true)]
    [string]$PackageName,
    [Parameter(Mandatory = $true)]
    [string]$FeedName,
    [Parameter(Mandatory = $true)]
    [string]$Organization,
    [Parameter(Mandatory = $true)]
    [string]$Project,
    [Parameter(Mandatory = $true)]
    [string]$AuthToken
  )

  try {
    LogInfo "Disabling externally sourced versions for package: $PackageName"

    $encodedAuthToken = Get-Base64EncodedToken -AuthToken $AuthToken

    $result = Set-PackageUpstreamingFlag `
      -Organization $Organization `
      -Project $Project `
      -FeedName $FeedName `
      -PackageName $PackageName `
      -Protocol "npm" `
      -AllowExternallySourcedVersions $false `
      -Base64EncodedToken $encodedAuthToken

    LogSuccess "Successfully disabled upstreaming for $PackageName"
    return $result
  }
  catch {
    LogError "Failed to disable upstreaming for $PackageName : $_"
    exit 1
  }
}

function Install-PackageToFeed {
  <#
  .SYNOPSIS
    Installs a package from upstream registry to cache it in the DevOps feed.
  #>
  
  param (
    [Parameter(Mandatory = $true)]
    [string]$PackageName,
    [Parameter(Mandatory = $true)]
    [string]$PackageVersion,
    [Parameter(Mandatory = $true)]
    [string]$AuthToken
  )

  try {
    LogInfo "Setting up npm authentication via artifacts-npm-credprovider..."
    
    # The artifacts-npm-credprovider reads from .npmrc and uses environment variables
    # No need to explicitly set credentials here - the provider handles auth automatically
    # when npm commands are executed
    
    $fullPackageName = "$PackageName@$PackageVersion"

    LogInfo "Installing package: $fullPackageName"
    LogInfo "This may take a moment as the package is downloaded and cached..."
    
    # Run npm install with the credential provider
    # The credential provider intercepts npm auth requests and uses the PAT
    npm install $fullPackageName --verbose
    
    if ($LASTEXITCODE -ne 0) {
      LogError "npm install failed with exit code $LASTEXITCODE"
      LogError "Possible causes:"
      LogError "  - Package name is incorrect or does not exist"
      LogError "  - Network connectivity issue with upstream registry"
      LogError "  - Feed permissions issue in Azure DevOps"
      LogError ""
      LogError "For more information, check the verbose output above."
      exit 1
    }

    LogSuccess "Successfully installed $fullPackageName to cache in DevOps feed"
  }
  catch {
    LogError "Failed to install package: $_"
    exit 1
  }
}

function Get-PackagePublishedAt {
  <#
  .SYNOPSIS
    Gets the publish timestamp for a specific package version from npm metadata.
  #>

  param (
    [Parameter(Mandatory = $true)]
    [string]$PackageName,
    [Parameter(Mandatory = $true)]
    [string]$PackageVersion
  )

  $packageRef = "$PackageName@$PackageVersion"
  $metadataRaw = npm view $PackageName time --json --registry "https://registry.npmjs.org/"
  if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($metadataRaw)) {
    throw "Unable to read publish time for $packageRef from npm metadata."
  }

  $metadata = $metadataRaw | ConvertFrom-Json -AsHashtable
  if (-not $metadata.ContainsKey($PackageVersion)) {
    throw "Version '$PackageVersion' was not found in npm metadata for package '$PackageName'."
  }

  return [DateTimeOffset]::Parse($metadata[$PackageVersion])
}

function Assert-MinimumPackageAge {
  <#
  .SYNOPSIS
    Ensures the package version is at least 24 hours old before installation.
  #>

  param (
    [Parameter(Mandatory = $true)]
    [string]$PackageName,
    [Parameter(Mandatory = $true)]
    [string]$PackageVersion,
    [Parameter(Mandatory = $false)]
    [int]$MinimumAgeHours = 24
  )

  $packageRef = "$PackageName@$PackageVersion"
  LogInfo "Checking package age for $packageRef (minimum: $MinimumAgeHours hours)..."

  try {
    $publishedAt = Get-PackagePublishedAt -PackageName $PackageName -PackageVersion $PackageVersion
  }
  catch {
    throw "Failed to retrieve package metadata from npm registry for $packageRef. $($_.Exception.Message)"
  }

  $age = [DateTimeOffset]::UtcNow - $publishedAt.ToUniversalTime()
  if ($age.TotalHours -lt $MinimumAgeHours) {
    $ageHoursRounded = [Math]::Round($age.TotalHours, 2)
    throw "Package version $packageRef is only $ageHoursRounded hours old; minimum required age is $MinimumAgeHours hours."
  }

  $ageHoursRounded = [Math]::Round($age.TotalHours, 2)
  LogSuccess "Package version $packageRef is $ageHoursRounded hours old and meets the minimum age requirement."
}

function Invoke-CachePackage {
  <#
  .SYNOPSIS
    Main orchestration function for caching a package in the DevOps feed.
  #>
  
  param (
    [Parameter(Mandatory = $true)]
    [string]$PackageName,
    [Parameter(Mandatory = $true)]
    [string]$PackageVersion,
    [Parameter(Mandatory = $true)]
    [string]$FeedName,
    [Parameter(Mandatory = $true)]
    [string]$Organization,
    [Parameter(Mandatory = $true)]
    [string]$Project
  )

  LogInfo "=========================================="
  LogInfo "DevOps Feed Package Caching Utility"
  LogInfo "=========================================="
  LogInfo "Package: $PackageName"
  if (-not [string]::IsNullOrWhiteSpace($PackageVersion)) {
    LogInfo "Version: $PackageVersion"
  }
  LogInfo "Feed: $FeedName"
  LogInfo "Organization: $Organization"
  LogInfo "Project: $Project"
  LogInfo "=========================================="

  # Get authentication token
  $authToken = Get-DevOpsAuthToken

  $packageDisplay = "$PackageName@$PackageVersion"

  # Gate on package age before mutating feed state or installing.
  Assert-MinimumPackageAge `
    -PackageName $PackageName `
    -PackageVersion $PackageVersion `
    -MinimumAgeHours 24

  # Step 1: Toggle upstreaming flag
  Enable-PackageUpstreaming `
    -PackageName $PackageName `
    -FeedName $FeedName `
    -Organization $Organization `
    -Project $Project `
    -AuthToken $authToken

  # Step 2: Install package
  Install-PackageToFeed `
    -PackageName $PackageName `
    -PackageVersion $PackageVersion `
    -AuthToken $authToken

  # Step 3: Disable upstreaming flag
  Disable-PackageUpstreaming `
    -PackageName $PackageName `
    -FeedName $FeedName `
    -Organization $Organization `
    -Project $Project `
    -AuthToken $authToken

  LogSuccess "Package caching operation completed successfully!"
}

function Invoke-CacheExternalPackageMain {
  <#
  .SYNOPSIS
    Entrypoint for script execution.
  #>

  try {
    # Validate inputs
    if ($PackageName -match '^\s*$') {
      LogError "PackageName cannot be empty"
      exit 1
    }

    if ($PackageName -match '[<>:"|?*]') {
      LogError "PackageName contains invalid characters: $PackageName"
      exit 1
    }

    if ($PackageVersion -match '[<>:"|?*]') {
      LogError "PackageVersion contains invalid characters: $PackageVersion"
      exit 1
    }

    Invoke-CachePackage `
      -PackageName $PackageName `
      -PackageVersion $PackageVersion `
      -FeedName $FeedName `
      -Organization $Organization `
      -Project $Project
  }
  catch {
    LogError "Unexpected error: $_"
    exit 1
  }
}

# Execute only when run directly, not when dot-sourced by tests.
if ($MyInvocation.InvocationName -ne '.') {
  Invoke-CacheExternalPackageMain `
    -PackageName $PackageName `
    -PackageVersion $PackageVersion `
    -FeedName $FeedName `
    -Organization $Organization `
    -Project $Project
}
