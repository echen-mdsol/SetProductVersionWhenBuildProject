param($installPath, $toolsPath, $package, $project)

# Get the current Pre-Build Event text.
$preBuildEventText = $project.Properties.Item("PreBuildEvent").Value
$postBuildEventText = $project.Properties.Item("PostBuildEvent").Value

# Define the Event Code to add.
$preBuildEventCode = @'
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '$(ProjectDir)_SetProductVersionWhenBuildProject\DoNotModify\SetProductVersion.ps1' -ProjectFilePath '$(ProjectPath)' -OutputDirectory '$(TargetDir)' -BuildConfiguration '$(ConfigurationName)' -BuildPlatform '$(PlatformName)'"
'@
$postBuildEventCode = @'
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '$(ProjectDir)_SetProductVersionWhenBuildProject\DoNotModify\RemoveAssemblyInfoFileChange.ps1' -ProjectFilePath '$(ProjectPath)' -OutputDirectory '$(TargetDir)' -BuildConfiguration '$(ConfigurationName)' -BuildPlatform '$(PlatformName)'"
'@

# Remove the Post-Build Event Code to the project and save it.
$preBuildEventText = $preBuildEventText.Replace($preBuildEventCode, [string]::Empty)
$project.Properties.Item("PreBuildEvent").Value = $preBuildEventText.Trim()

$postBuildEventText = $postBuildEventText.Replace($postBuildEventCode, [string]::Empty)
$project.Properties.Item("PostBuildEvent").Value = $postBuildEventText.Trim()

$project.Save()
