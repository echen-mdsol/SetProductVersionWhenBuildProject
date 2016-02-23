param($installPath, $toolsPath, $package, $project)

# Get the current Event text.
$preBuildEventText = $project.Properties.Item("PreBuildEvent").Value
$postBuildEventText = $project.Properties.Item("PostBuildEvent").Value

# Define the Event Code to add.
$preBuildEventCode = @'
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '$(ProjectDir)_SetProductVersionWhenBuildProject\DoNotModify\SetProductVersion.ps1' -ProjectFilePath '$(ProjectPath)' -OutputDirectory '$(TargetDir)' -BuildConfiguration '$(ConfigurationName)' -BuildPlatform '$(PlatformName)'"
'@
$postBuildEventCode = @'
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '$(ProjectDir)_SetProductVersionWhenBuildProject\DoNotModify\RemoveAssemblyInfoFileChange.ps1' -ProjectFilePath '$(ProjectPath)' -OutputDirectory '$(TargetDir)' -BuildConfiguration '$(ConfigurationName)' -BuildPlatform '$(PlatformName)'"
'@

# If there is already a call to the PowerShell script in the pre build event, then just exit.
if ($preBuildEventText.Contains($preBuildEventCode))
{
  Write-Verbose "SetProductVersion.ps1 is already referenced in the Pre-Build Event, so not updating pre-build event code."
}else{
  $preBuildEventText += "`n`r`n`r$preBuildEventCode"
  $project.Properties.Item("PreBuildEvent").Value = $preBuildEventText.Trim()
}

if ($postBuildEventText.Contains($postBuildEventCode))
{
  Write-Verbose "RemoveAssemblyInfoFileChange.ps1 is already referenced in the Post-Build Event, so not updating pre-build event code."
}else{
  $postBuildEventText += "`n`r`n`r$postBuildEventCode"
  $project.Properties.Item("PostBuildEvent").Value = $postBuildEventText.Trim()
}

# Save the changes we made.
$project.Save()
