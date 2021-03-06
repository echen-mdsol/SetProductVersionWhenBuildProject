# SetProductVersionWhenBuildProject NuGet Package
This NuGet package is to automatically set "Product version" of the assembly file property, which appears on the "Details" tab of the right-click file property window, at build time.

The "Product version" of a .NET assembly is specified by the `AssemblyInformationalVersionAttribute` in AssemblyInfo.cs, like below
```cs
// In AssemblyInfo.cs
[assembly: AssemblyInformationalVersion("blah")]
```
# How to use
Add this NuGet package in your csporj. That's it.
```powershell
PM> Install-Package SetProductVersionWhenBuildProject
```

After build you can see the "Product version" is set with the current Git commit hash from the output dll file property.

## Contents added into your csproj
- `_SetProductVersionWhenBuildProject\DoNotModify\*` Executing scripts that you should never touch.
- `_SetProductVersionWhenBuildProject\Config.ps1` Configure how to set value of `AssemblyInformationalVersion`.
- **A PreBuildEvent** in csproj that sets `AssemblyInformationalVersion` in AssemblyInfo.cs file, so that the build process can embed "Product version" into the output dll.
- **A PostBuildEvent** in csproj that optinally removes the added `AssemblyInformationalVersion` from AssemblyInfo.cs, so it won't pollute your git status.

## Config.ps1
These are the variables in this configuration file. You can find the usage form comments.
```powershell
# The relative path of assembly information cs file under the project.
# If not specified, 'Properties\AssemblyInfo.cs' will be used.
$assemblyInfoFileRelativePath = ""

# githash for the latest commit
$githash = git log -1 --pretty='%h'

# Product version value in the dll file property, which is set by AssemblyInformationalVersionAttribute in AssemblyInfo.cs
$productVersionValue = "$githash$(if($(git status -s)){'-dirty'}else{''})"

# Product version value using environment variables available when building in MyGet Build Services.
# http://docs.myget.org/docs/reference/build-services#Available_Environment_Variables
#
# Please always PadLeft the build number if you decide to use it,
# because NuGet versioning system sorts prerelease package in lexicographic ASCII sort order.
# As a result "1.0.0-build9" will be unexpectedly treated as newer than "1.0.0-build10".
# But "1.0.0-build0010" will be newer than "1.0.0-build0009".
$productVersionValueMyGet = "$($env:VersionFormat)-build$("{0:D4}" -f [int]$env:BuildCounter)-$githash"

# If keep below CSharp code in AssemblyInfo.cs after build
# [assembly: AssemblyInformationalVersion("blah")]
$keepAssemblyInfoChangeAfterBuild = $false

# Regex pattern for Product Version in AssemblyInfo.cs
$productVersionPattern = '\s*\[assembly\s*:\s*AssemblyInformationalVersion\s*\(@?"[^"]*"\)\s*\]'


```

By default, the value of `$productVersionValue` will be your current Git commit hash in short format, and with a "-dirty" postfix if there is any uncommitted change. The AssemblyInfo.cs file may look like
```cs
[assembly: AssemblyInformationalVersion("613247e")]
```
or below if there is uncommitted change.
```cs
[assembly: AssemblyInformationalVersion("613247e-dirty")]
```

# Integration with MyGet Build Service
This NuGet package can be used to assist publishing your NuGet package with MyGet Build Service. When MyGet Build Service triggers the build process, the product version will be set with the value specified by `$productVersionValueMyGet` in the Config.ps1.

The default format is "X.Y.Z-Build-hash", wherein "X.Y.Z" is your NuGet package version (you can specify in MyGet Build Service configuration), "Build" is the automatically incrementing build number by MyGet <sup>See caveat 1</sup>, and "hash" is the value of `$githash`. Refer to http://docs.myget.org/docs/reference/build-services#Available_Environment_Variables for MyGet Build Service environment variables. Below is an example.
```cs
[assembly: AssemblyInformationalVersion("1.0.0-build0001-613247e")]
```

## Caveats
1. Always pad left the build number (prepending "0") if you decide to use it. Because NuGet versioning system sorts prerelease package in lexicographic ASCII sort order. As a result "1.0.0-build9" will be unexpectedly treated as newer than "1.0.0-build10". But "1.0.0-build0010" will be newer than "1.0.0-build0009".
2. There is no need to put a `-dirty` flag when integrated with MyGet Build Service. Since the process will always change the AssemblyInfo.cs file and then pollute the local Git repo.

# Acknowledgement
This project is inspired by https://www.nuget.org/packages/CreateNewNuGetPackageFromProjectAfterEachBuild/
