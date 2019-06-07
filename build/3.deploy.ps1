param(
    $repotype = "local",
    $reponame,
    $sourcelocation,
    $publishlocation,
    $modulepath = "$($env:ProgramFiles)\WindowsPowershell\Modules",
    $apikey
)
$modulename = $($env:CI_PROJECT_NAME).tolower()

Remove-Item "$modulepath\$modulename" -Recurse -Force -erroraction silentlycontinue
Copy-Item ".\$modulename" -Recurse -Destination $modulepath
$commitmsg = (Get-BuildEnvironment).CommitMessage
if ($commitmsg -like "*nobuild*"){
    exit
}
if ($($env:repotype) -eq "psgallery") {
    Publish-Module -Name $modulename -NuGetApiKey $($env:apikey) -Verbose
}

Elseif ($env:repotype -eq "local") {
    Register-PSRepository -name $($env:reponame) -sourcelocation $($env:sourcelocation) -publishlocation $($env:publishlocation) -erroraction silentlycontinue

    try {
        Publish-Module -Name $modulename -Repository $env:reponame -Verbose -Force
    }
    Catch {
        throw "An error occurred publishing the module $modulename"
    }
}
Elseif ($env:repotype -eq "nuget") {
    Register-PSRepository -name $($env:reponame) -sourcelocation $($env:sourcelocation) -publishlocation $($env:publishlocation) -erroraction silentlycontinue
    try {
        Publish-Module -Name $modulename -Repository $env:reponame -NuGetApiKey $env:apikey -Verbose -Force
    }
    Catch {
        throw "An error occurred publishing the module $modulename"
    }
}