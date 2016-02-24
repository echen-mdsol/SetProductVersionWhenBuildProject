# SetProductVersionWhenBuildProject NuGet Package
This content NuGet package is to automatically set "Product version" of the assembly file property, which appears on the "Details" tab of the right-click file property window.

The "Product version" of a .NET assembly is specified with the `AssemblyInformationalVersionAttribute` in AssemblyInfo.cs when build, like below code
```cs
// In AssemblyInfo.cs
[assembly: AssemblyInformationalVersion("blah")]
```
# How to use
Use add this NuGet package in your csporj. That's it. After build you can see the "Product version" from the output dll file property.
```powershell
PM> Install-Package SetProductVersionWhenBuildProject
```

## Contents added in to your csproj
- `_SetProductVersionWhenBuildProject\DoNotModify\*` Executing scripts that you should never modify nor remove.
- `_SetProductVersionWhenBuildProject\Config.ps1` Configure the behavior of setting `AssemblyInformationalVersion`.
- **A PreBuildEvent** in csproj that sets `AssemblyInformationalVersion` in AssemblyInfo.cs file, so that the build process can embed "Product version" into the output dll.
- **A PostBuildEvent** in csproj that optinally remove the added `AssemblyInformationalVersion` from AssemblyInfo.cs, so that this change won't pollute your git status.

## Config.ps1
There are only three variables in this configuration file. You can find the usage form comments.
```powershell
# The relative path of assembly information cs file under the project.
# If not specified, 'Properties\AssemblyInfo.cs' will be used.
$assemblyInfoFileRelativePath = ""

# Product version value in the dll file property, which is set by AssemblyInformationalVersionAttribute in AssemblyInfo.cs
$productVersionValue = "$(git log -1 --pretty='%h')$(if($(git status -s)){'-dirty'}else{''})"

# If keep below CSharp code in AssemblyInfo.cs after build
# [assembly: AssemblyInformationalVersion("blah")]
$keepAssemblyInfoChangeAfterBuild = $false
```

By default, the value of `$productVersionValue` will be your current Git commit hash in short format, and with a "-dirty" postfix if there is any uncommitted change. The AssemblyInfo.cs file will look like
```cs
[assembly: AssemblyInformationalVersion("613247e")]
```
or below if there is uncommitted change.
```cs
[assembly: AssemblyInformationalVersion("613247e-dirty")]
```
