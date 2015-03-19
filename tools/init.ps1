param($installPath, $toolsPath, $package)

$reloadRequired = $false
# Get the solution
$solution = Get-Interface $dte.Solution ([EnvDTE80.Solution2])

# Make sure the .nuget file folder exists
$solutionPath = $solution.FullName | Split-Path -Parent
$nugetPath = Join-Path $solutionPath '.nuget'
if ((Test-Path $nugetPath) -eq $false) { New-Item -Path $solutionPath -Name '.nuget' -ItemType 'directory' }

# Make sure the NuGet.config file exists
$configPath = Join-Path $nugetPath 'NuGet.config'
if ((Test-Path $configPath) -eq $false) 
{
    @('<?xml version="1.0" encoding="utf-8"?>',
      '<configuration>',
      '  <solution>',
      '    <add key="disableSourceControlIntegration" value="true" />',
      '  </solution>',
      '</configuration>') | Out-File -FilePath $configPath -Encoding 'UTF8' 
    $reloadRequired = $true
}

# Make sure the .nuget solution folder exists
$nugetProject = $solution.GetEnumerator() | where { $_.ProjectName -eq '.nuget' } | Select-Object -First 1
if ($nugetProject -eq $null) { $nugetProject = $solution.AddSolutionFolder('.nuget') }

# Make sure the NuGet.config is added to the solution
$projectItems = Get-Interface $nugetProject.ProjectItems ([EnvDTE.ProjectItems])
$nugetConfig = $projectItems.GetEnumerator() | where { $_.Name -eq 'NuGet.config' } | Select-Object -First 1
if ($nugetConfig -eq $null) 
{
    $projectItems.AddFromFile($configPath) 
    $reloadRequired = $true
}

# If there is no .tfigonre, add it
$tfignorePath = Join-Path $solutionPath '.tfignore'
if ((Test-Path $tfignorePath) -eq $false) 
{
    '\packages' | Out-File -FilePath $tfignorePath 
    $reloadRequired = $true
}

# Add .tfignore to the solution if it does not already exist
if ($solution.FindProjectItem('.tfignore') -eq $null) 
{
    $projectItems.AddFromFile($tfignorePath)
    $reloadRequired = $true
}

if ($reloadRequired)
{
    $solutionFullPath = $solution.FullName
    $solution.Close($true)
    $solution.Open($solutionFullPath)
}