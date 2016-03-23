
param ([string]$ProjectFilePath, [string]$OutputDirectory, [string]$BuildConfiguration, [string]$BuildPlatform)

# Turn on Strict Mode to help catch syntax-related errors.
# 	This must come after a script's/function's param section.
# 	Forces a function to be the first non-comment code to appear in a PowerShell Module.
Set-StrictMode -Version Latest

# Display the parameter values passed to this script.
Write-Output "ProjectFilePath parameter value passed to script is '$ProjectFilePath'."
Write-Output "OutputDirectory parameter value passed to script is '$OutputDirectory'."
Write-Output "BuildConfiguration parameter value passed to script is '$BuildConfiguration'."
Write-Output "BuildPlatform parameter value passed to script is '$BuildPlatform'."

# Get the directory that this script is in.
$THIS_SCRIPTS_DIRECTORY_PATH = Split-Path $script:MyInvocation.MyCommand.Path
$CONFIG_FILE_PATH = Join-Path -Path (Split-Path -Path $THIS_SCRIPTS_DIRECTORY_PATH -Parent) -ChildPath 'Config.ps1'
if (Test-Path -Path $CONFIG_FILE_PATH) { . $CONFIG_FILE_PATH }
else { Write-Warning "Could not find Config file at '$CONFIG_FILE_PATH'. Default values will be used instead." }

if([string]::IsNullOrEmpty($assemblyInfoFileRelativePath)) {
  $assemblyInfoFileRelativePath = 'Properties\AssemblyInfo.cs'
}

[string]$assemblyInfoFile = Join-Path -path "$ProjectFilePath\.." -ChildPath $assemblyInfoFileRelativePath

Write-Output "AssemblyInfo.cs path is '$assemblyInfoFile'."

if ($env:BuildRunner -eq 'MyGet') {
  Write-Output "Using MyGet build runner."  
  $productVersionValue = $productVersionValueMyGet
}

Write-Output "ProductVersion value is '$productVersionValue'."

function SetProductVersion([string]$content, [string] $productVersionValue){
  $content = [regex]::replace($content, $productVersionPattern, '');
  $content += "`r`n[assembly: AssemblyInformationalVersion(`"$productVersionValue`")]"
  return $content
}

$sr = New-Object System.IO.StreamReader($assemblyInfoFile)
$encoding = $sr.CurrentEncoding
[string]$content = $sr.ReadToEnd();
$sr.Close();
$content = SetProductVersion $content $productVersionValue
[System.IO.File]::WriteAllText($assemblyInfoFile, $content, $encoding)
