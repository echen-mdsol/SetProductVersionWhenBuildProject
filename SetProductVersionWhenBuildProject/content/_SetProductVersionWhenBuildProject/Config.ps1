# The relative path of assembly information cs file under the project.
# If not specified, 'Properties\AssemblyInfo.cs' will be used.
$assemblyInfoFileRelativePath = ""

# Product version value in the dll file property, which is set by AssemblyInformationalVersionAttribute in AssemblyInfo.cs
$productVersionValue = "$(git log -1 --pretty='%h')$(if($(git status -s)){'-dirty'}else{''})"

# If keep below CSharp code in AssemblyInfo.cs after build
# [assembly: AssemblyInformationalVersion("blah")]
$keepAssemblyInfoChangeAfterBuild = $false
