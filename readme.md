![Banner](images/banner.png)

# PowerShell tips and snippets

> A few PowerShell tips and functions snippets

* [Variables](#variables)
* [Some functions](#some-functions)
  * [Check if file exists](#check-if-file-exists)
  * [Get a flat list of files](#get-a-flat-list-of-files)
  * [Get parent folder](#get-parent-folder)
  * [Get the target filename of a symlink](#get-the-target-filename-of-a-symlink)
* [License](#license)

## Variables

| Variable                     | Description                                                                 |
| ---------------------------- | --------------------------------------------------------------------------- |
| [string](Get-Location)       | Get the current folder (where the `.ps1`script is running; f.i. `c:\temp`). |
| $MyInvocation.MyCommand.Name | Return the full name of the running script (return f.i. `c:\temp\a.ps1`).   |

## Some functions

### Check if file exists

```powershell
<#
.DESCRIPTION
    Return true if the file has been retrieved; false otherwise
.PARAMETER filename
#>
function fileExists([string] $filename) {
    return [Boolean](Test-Path $filename -PathType Leaf)
}
```

### Get a flat list of files

The function below will retrieve the list of all files below the current running folder and will returns a flat list (i.e. only files name).

The function support exclusions like skipping specific folders or files.

```powershell
<#
.DESCRIPTION
    Retrieve the list of all files (based on the mentioned pattern).
    The result will be a flat list (i.e. only files name).
    Support exclusions like skipping folders or files. 
.PARAMETER pattern
    Pattern for files like c:\temp\*.* or just *.*
.PARAMETER exclude
    It's a regex that contains patterns to exclude
    For instance, exclude some folders
        ".*\\\.config\\|.*\\\.git\\|.*\\backup\\"
    And exclude files based on their extensions
        ".bmp$|.gif$|.ico$|.jpe?g$|.png$"
#>
function getListOfFiles([string] $pattern = "*.*", [string] $exclude = "") {
    # Get the list of all files, retrieve a flatlist and 
    # don't report errors when f.i. a folder is a symlink
    $files = Get-ChildItem $pattern -File -Recurse -ErrorAction SilentlyContinue `
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
    $filename = $file.Name
    Write-Host "Process $filename"
}
```

### Get parent folder

```powershell
<#
.DESCRIPTION
    Return the parent folder of a file
.PARAMETER filename
#>
function getParentFolderName([string] $filename) {
    return (Split-Path -Path $filename)
}
```

### Get the target filename of a symlink

When a file is a symbolic or hard link, the following function will return the original filename.

For instance if `c:\temp\a.ps1` is symlink to `c:\christophe\repositories\tools\utils.ps1`, the following function will return the full name of the original filename so will return `c:\christophe\repositories\tools\utils.ps1`.

```powershell
<#
.DESCRIPTION
    When a file is a symlink, return the target path i.e. the original path of the file
    Note: when the same file is symlinked multiple times, the ExpandProperty
    will return all files so get only the first item which is the original file
.PARAMETER filename
    That file should be a symlink (hard or symbolic)
#>
function getSymLinkTargetPath([string] $filename) {
    $target = Get-Item -Path $filename  `
    | Select-Object -ExpandProperty Target `
    | Select-Object -First 1

    return [string]$target
}
```

## License

[MIT](LICENSE)
