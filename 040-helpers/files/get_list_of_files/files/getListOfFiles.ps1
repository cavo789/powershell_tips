<#
.DESCRIPTION
    Retrieve the list of all files (based on the mentioned pattern).
    The result will be a flat list (i.e. only files name).
    Support exclusions like skipping folders or files.
.PARAMETER Pattern
    Pattern for files like c:\temp\*.* or just *.*
.PARAMETER Exclude
    It's a regex that contains patterns to exclude
    For instance, exclude some folders
        ".*\\\.config\\|.*\\\.git\\|.*\\backup\\"
    And exclude files based on their extensions
        ".bmp$|.gif$|.ico$|.jpe?g$|.png$"
.OUTPUTS
    Array
#>
function getListOfFiles([string] $pattern = "*.*", [string] $exclude = "") {
    # Get the list of all files, retrieve a flatlist and
    # don't report errors when f.i. a folder is a symlink
    $files = Get-ChildItem . -Filter $pattern -Recurse `
    | Where-Object { $_.Fullname -notmatch $exclude } `
    | Group-Object "FullName" `
    | Select-Object "Name"

    return $files
}

# Sample
# Skip .git and backups folders
$exclude = ".*\\\.git\\|.*\\backups\\"
# and skip some extensions
$exclude += "|.bmp$|.gif$|.ico$|.jpe?g$|.png$"

$files = getListOfFiles '*.*'  $exclude

foreach ($file in $files) {
    Write-Host "Process" $file.Name
}
