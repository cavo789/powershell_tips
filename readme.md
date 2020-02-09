![Banner](images/banner.png)

# PowerShell tips and snippets

> A few PowerShell tips and functions snippets

* [Variables](#variables)
* [Syntax elements](#syntax-elements)
  * [Define global variables](#define-global-variables)
  * [Include external script](#include-external-script)
  * [Split long string on multiple lines](#split-long-string-on-multiple-lines)
  * [Split long command on multiple lines](#split-long-command-on-multiple-lines)
* [Some functions](#some-functions)
  * [Check if file exists](#check-if-file-exists)
  * [Get a flat list of files](#get-a-flat-list-of-files)
    * [Get the depth too](#get-the-depth-too)
  * [Get parent folder](#get-parent-folder)
  * [Get the target filename of a symlink](#get-the-target-filename-of-a-symlink)
  * [Files](#files)
    * [Get list of files, recursively](#get-list-of-files-recursively)
    * [Prettify JSON](#prettify-json)
  * [Web services](#web-services)
    * [Consume XML response](#consume-xml-response)
* [License](#license)

## Variables

| Variable                       | Description                                                                 |
| ------------------------------ | --------------------------------------------------------------------------- |
| `[string](Get-Location)`       | Get the current folder (where the `.ps1`script is running; f.i. `c:\temp`). |
| `$MyInvocation.MyCommand.Name` | Return the full name of the running script (return f.i. `c:\temp\a.ps1`).   |

## Syntax elements

### Define global variables

Defining a variable for the entire script; initialize it once and use it everywhere.

The key is to use the `$global:` prefix like below:

```powershell
begin {

    # Folder where the running Powershell script is stored
    $global:scriptDir = ""

    function initialize() {
        $global:scriptDir = Split-Path $script:MyInvocation.MyCommand.Path
    }

    function someFunction() {
        Write-Host $global:scriptDir
    }
}
```

### Include external script

Including an external script (f.i. `my_helper.ps1`) can be done using the dot notation: `. my_helper.ps1`.

```powershell
# Define the debug mode constant
set-variable -name DEBUG -value ([boolean]$FALSE) -option Constant

function include_helpers() {

    # List of helpers to load
    $helpers = @("files", "images", "markdown")

    if ($DEBUG -eq $TRUE) {
        # If debug mode is enabled, debug.ps1 will also be loaded
        $helpers = $helpers + @("debug")
    }

    foreach ($helper in $helpers) {
        # Suppose that files are in the helpers sub folder
        $filename = ".\helpers\$helper.ps1"

        try {
            if ([System.IO.File]::Exists($filename)) {
                # The file exists; load it
                . $filename
            }
        }
        catch {
            Write-Error "Error while loading helper $filename"
        }
    }

    return;
}
```

Note: functions should be declare with the `global:` prefix.

For instance, in the file `files.ps1` we'll have:

```powershell
begin {
    # global: is used so that function can be used in the calling script 
    function global:fileExists([string] $filename) {
        return [Boolean]([System.IO.File]::Exists($filename))
    }

    # global: is NOT used; this function is private
    function aDummyFunction() {}
}

```

### Split long string on multiple lines

Don't write things like:

```powershell
Write-Error "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab ...")
```

but split the string using the `$( ...)` syntax:

```powershell
Write-Error $("Sed ut perspiciatis unde omnis iste natus error " + 
    "sit voluptatem accusantium doloremque laudantium, totam rem "
    "aperiam, eaque ipsa quae ab ...")
```

### Split long command on multiple lines

Don't write things like:

```powershell
$target = Get-Item -Path $filename | Select-Object -ExpandProperty Target | Select-Object -First 1
```

but split the command like this:

```powershell
$target = Get-Item -Path $filename `
    | Select-Object -ExpandProperty Target `
    | Select-Object -First 1
```

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

Alternative solution: `[System.IO.File]::Exists($filename)` (no support for wildcard characters)

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
```

This will return something like below:

```text
C:\Christophe\demo\readme.md
C:\Christophe\demo\03_Annex\index.md
C:\Christophe\demo\03_Annex\01_Annex1\index.md
C:\Christophe\demo\07_Date\index.md
```

#### Get the depth too

The following snippet calculate a FolderDepth column based on the number of `\` seperator in the filename:

```powershell
function global:getListOfFiles([string] $pattern = "*.*", [string] $exclude = "") {
    $files = Get-ChildItem $pattern -File -Recurse -ErrorAction SilentlyContinue `
    | Where-Object { $_.Fullname -notmatch $exclude } `
    | Group-Object "FullName" `
    | Select-Object "Name", @{Name = 'FolderDepth'; Expression = { $_.Name.Split('\').Count } } `
    | Sort-Object "Name"

    return $files
}

# Sample
$files = getListOfFiles '*.md'

foreach ($file in $files) {
    Write-Host "Process " $file.Name $file.FolderDepth
}
```

This will return something like below:

```text
C:\Christophe\demo\03_Annex\01_Annex1\index.md 5
C:\Christophe\demo\03_Annex\index.md 4
C:\Christophe\demo\07_Date\index.md 4
C:\Christophe\demo\readme.md 3
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

### Files

#### Get list of files, recursively

Get the list of files, with or without a filter like a file's extension and define the maximum deep allowed so it's possible to get only the root folder (`MaxDepth=0`, the root and the first children, ...).

```powershell
function Get-ListOfFiles {
    param
    (
        [String] $Path,
        [String] $Filter = '*',
        [System.Int32] $MaxDepth = 3,
        [System.Int32] $Depth = 0
    )

    $Depth++

    Get-ChildItem -Path $Path -Filter $Filter -File 

    if ($Depth -le $MaxDepth) {
        Get-ChildItem -Path $Path -Directory |
        ForEach-Object { Get-ListOfFiles -Path $_.FullName -Filter $Filter -Depth $Depth -MaxDepth $MaxDepth }
    }

}

Get-ListOfFiles -Path . -Filter *.csv -MaxDepth 5 -ErrorAction SilentlyContinue |
Select-Object -ExpandProperty FullName
```

#### Prettify JSON

```powershell
$objJSON = Get-Content -Path ".\test.json"
$objJSON | ConvertFrom-Json | ConvertTo-Json | Out-File -FilePath ".\test-Pretty.json"
Get-Content ".\test-Pretty.json"
```

### Web services

#### Consume XML response

Consume a service returning XML and display the response

```powershell
[int] $Amount = 5
[string] $Type = "pargraphs"
[string] $Start = "yes"

[xml]$Temp = Invoke-WebRequest -UseBasicParsing -Uri "https://www.lipsum.com/feed/xml?amount=$Amount&what=$Type&start=$Start"

$Temp.feed.lipsum
```

## License

[MIT](LICENSE)
