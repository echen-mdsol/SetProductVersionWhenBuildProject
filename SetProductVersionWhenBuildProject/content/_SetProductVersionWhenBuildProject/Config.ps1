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
$productVersionValueMyGet = "$($env:VersionFormat)-build$($env:BuildCounter.PadLeft(4,'0'))-$githash"

# If keep below CSharp code in AssemblyInfo.cs after build
# [assembly: AssemblyInformationalVersion("blah")]
$keepAssemblyInfoChangeAfterBuild = $false

# Regex pattern for Product Version in AssemblyInfo.cs
$productVersionPattern = '\s*\[assembly\s*:\s*AssemblyInformationalVersion\s*\(@?"[^"]*"\)\s*\]'
