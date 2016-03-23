# The relative path of assembly information cs file under the project.
# If not specified, 'Properties\AssemblyInfo.cs' will be used.
$assemblyInfoFileRelativePath = ""

# githash for the latest commit
$githash = git log -1 --pretty='%h'

# Product version value in the dll file property, which is set by AssemblyInformationalVersionAttribute in AssemblyInfo.cs
$productVersionValue = "$githash$(if($(git status -s)){'-dirty'}else{''})"

# Product version value to be used when building in MyGet Build Services
$productVersionValueMyGet = "$($env:VersionFormat)-build$($env:BuildCounter)-$githash"

# If keep below CSharp code in AssemblyInfo.cs after build
# [assembly: AssemblyInformationalVersion("blah")]
$keepAssemblyInfoChangeAfterBuild = $false

# Regex pattern for Product Version in AssemblyInfo.cs
$productVersionPattern = '\s*\[assembly *: *AssemblyInformationalVersion *\(@?"[^"]*"\) *\]'
