﻿<!-- This file has been generated by the concat-md.ps1 script. -->
<!-- Don't modify this file manually (you'll loose your changes) -->
<!-- but run the tool once more -->

<!-- Last refresh date: 2020-06-05 11:44:14 -->

<!-- below, content of ./index.md -->

# PowerShell tips and snippets

![Banner](./banner.svg)

> A few PowerShell tips and functions snippets

<!-- table-of-contents - start -->
* [Core features](#core-features)
  * [Syntax elements](#syntax-elements)
    * [Define global variables](#define-global-variables)
    * [Include external script](#include-external-script)
    * [Split long string on multiple lines](#split-long-string-on-multiple-lines)
  * [Variables](#variables)
* [Some helpers](#some-helpers)
  * [Files](#files)
    * [Check if file exists](#check-if-file-exists)
    * [Get a flat list of files](#get-a-flat-list-of-files)
      * [Get the depth too](#get-the-depth-too)
      * [Get list of files, recursively](#get-list-of-files-recursively)
  * [Folders](#folders)
    * [Get parent folder](#get-parent-folder)
    * [Get the target filename of a symlink](#get-the-target-filename-of-a-symlink)
    * [Prettify JSON](#prettify-json)
    * [Consume XML response](#consume-xml-response)
* [Regex](#regex)
  * [Between two tags](#between-two-tags)
  * [Case insensitive](#case-insensitive)
  * [Match all occurrences](#match-all-occurrences)
  * [Multiline](#multiline)
* [License](#license)
<!-- table-of-contents - end -->

<!-- below, content of ./010-core/readme.md -->

## Core features

<!-- below, content of ./010-core/syntax/readme.md -->

### Syntax elements

<!-- below, content of ./010-core/syntax/global_variables/readme.md -->

#### Define global variables

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

<!-- below, content of ./010-core/syntax/include/readme.md -->

#### Include external script

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

<!-- below, content of ./010-core/syntax/split_command/readme.md -->

#### Split long string on multiple lines

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

For commands too, don't write things like:

```powershell
$target = Get-Item -Path $filename | Select-Object -ExpandProperty Target | Select-Object -First 1
```

but split the command like this:

```powershell
$target = Get-Item -Path $filename `
    | Select-Object -ExpandProperty Target `
    | Select-Object -First 1
```

<!-- below, content of ./010-core/variables/readme.md -->

### Variables

| Variable                       | Description                                                               |
| ------------------------------ | ------------------------------------------------------------------------- |
| `[string](Get-Location)`       | Get the current folder.                                                   |
| `$MyInvocation.MyCommand.Name` | Return the full name of the running script (return f.i. `c:\temp\a.ps1`). |
| `$PSScriptRoot`                | Return the folder of the running script (`c:\temp`)                       |

<!-- below, content of ./040-helpers/readme.md -->

## Some helpers

<!-- below, content of ./040-helpers/files/readme.md -->

### Files

<!-- below, content of ./040-helpers/files/file_exists/readme.md -->

#### Check if file exists

```powershell
<#
.SYNOPSIS
    Check if a file exists on disk
.PARAMETER Filename
    Name of the file to check
.OUTPUTS
    True if the file exists,
    False othwerise
#>
function fileExists([string] $filename) {
    return [Boolean](Test-Path $filename -PathType Leaf)
}
```

Alternative solution: `[System.IO.File]::Exists($filename)` (no support for wildcard characters)

<!-- below, content of ./040-helpers/files/get_list_of_files/readme.md -->

#### Get a flat list of files

The function below will retrieve the list of all files below the current running folder and will returns a flat list (i.e. only files name).

The function support exclusions like skipping specific folders or files.

```powershell
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
```

This will return something like below:

```text
C:\Christophe\demo\readme.md
C:\Christophe\demo\03_Annex\index.md
C:\Christophe\demo\03_Annex\01_Annex1\index.md
C:\Christophe\demo\07_Date\index.md
```

##### Get the depth too

The following snippet calculate a FolderDepth column based on the number of `\` separator in the filename:

```powershell
<!-- concat-md::include "./files/getListOfFilesWithDepth.ps1" -- >
```

This will return something like below:

```powershell
<!-- concat-md::include "./files/getListOfFilesWithDepth.txt" -- >
```

##### Get list of files, recursively

Get the list of files, with or without a filter like a file's extension and define the maximum deep allowed so it's possible to get only the root folder (`MaxDepth=0`, the root and the first children, ...).

```powershell
<!-- concat-md::include "./files/getListOfFilesRecursiveWithMaxDepth.ps1" -- >
```

<!-- below, content of ./040-helpers/folders/readme.md -->

### Folders

<!-- below, content of ./040-helpers/folders/get_parentfolder/readme.md -->

#### Get parent folder

```powershell
<#
.SYNOPSIS
    Return the parent folder of a file
.PARAMETER Filename
    Filename for which the parent folder should be returned
.OUTPUTS
    String
#>
function getParentFolderName([string] $filename) {
    return (Split-Path -Path $filename)
}
```

<!-- below, content of ./040-helpers/folders/get_symlinktargetpath/readme.md -->

#### Get the target filename of a symlink

When a file is a symbolic or hard link, the following function will return the original filename.

For instance if `c:\temp\a.ps1` is symlink to `c:\christophe\repositories\tools\utils.ps1`, the following function will return the full name of the original filename so will return `c:\christophe\repositories\tools\utils.ps1`.

```powershell
<#
.DESCRIPTION
    When a file is a symlink, return the target path i.e. the original path of the file
    Note: when the same file is symlinked multiple times, the ExpandProperty
    will return all files so get only the first item which is the original file
.PARAMETER Filename
    That file should be a symlink (hard or symbolic)
.OUTPUTS
    String
#>
function getSymLinkTargetPath([string] $filename) {
    $target = Get-Item -Path $filename  `
    | Select-Object -ExpandProperty Target `
    | Select-Object -First 1

    return [string]$target
}
```

<!-- below, content of ./040-helpers/json/prettify/readme.md -->

#### Prettify JSON

```powershell
$objJSON = Get-Content -Path ".\test.json"
$objJSON | ConvertFrom-Json | ConvertTo-Json | Out-File -FilePath ".\test-Pretty.json"
Get-Content ".\test-Pretty.json"
```

<!-- below, content of ./040-helpers/webservice/consume_xml/readme.md -->

#### Consume XML response

Consume a service returning XML and display the response

```powershell
[int] $Amount = 5
[string] $Type = "pargraphs"
[string] $Start = "yes"

[xml]$Temp = Invoke-WebRequest -UseBasicParsing -Uri "https://www.lipsum.com/feed/xml?amount=$Amount&what=$Type&start=$Start"

$Temp.feed.lipsum
```

<!-- below, content of ./050-regex/readme.md -->

## Regex

> [List of modifiers](https://www.regular-expressions.info/modifiers.html)

<!-- below, content of ./050-regex/between_tags/readme.md -->

### Between two tags

Retrieve the content between two HTML tags:

```powershell

# Search for the pattern like:
#       <!-- start -->
#       CONTENT
#       <!-- end -->
#
# Can be on the same line or on multiple lines
$content = "<!-- start -->Ipso Lorem<!-- end -->"

$pattern = [regex]$(
    "\n?\<\!\-\- start \-\-\>" +
    "([\s\S]*?)" +
    "\<\!\-\- end \-\-\>\n?"
)

# Write the CONTENT
Write-Host $([string]($pattern).Match($content).groups[1].value)
```

<!-- below, content of ./050-regex/case_insensitive/readme.md -->

### Case insensitive

The default mode is case sensitive, to change this, the mode to use is `(?i)` at the very start of the `[regex]` expression:

```powershell
$content = "Ipso lorem`n`n@TOdo Christophe: do this.`n`nIpso lorem"

$pattern = [regex]"(?msi)^(\@todo ([^\n\r]*))"

if (($pattern.Match($content)).success) {
    Write-Warning "@TODO found at the beginning of the string"
    Write-Host "There is a TODO for $($pattern.Match($content).groups[2].value)"
}
```

<!-- below, content of ./050-regex/match_all/readme.md -->

### Match all occurrences

Process every occurrences:

```powershell
$content = "# Heading 1`n`n## Heading 1.1`n`n## Heading 1.2`n`n## Heading 1.3"

# Skip heading 1 so start at 2
#    (?ms)       ==> Multi-lines regex
#    ^           ==> The start of the line
#    (\#{2,})    ==> We need to find at least two consecutive #
#     ([^\n\r]*) ==> Capture the end of the line (exclude CRLF)
#    $          ==> End of the line
$pattern = [regex]"(?ms)^(\#{2,}) ([^\n\r]*)$"

$headings = $pattern.Matches($content);

if ($headings.Count -gt 0) {
    $match = $pattern.Match($content)

    while ($match.Success) {
        # Isolate the # (one or more) and the title
        $pattern = [regex]"(#{2,})* (.*)"

        # Display "Heading 1.1", "Heading 1.2", ...
        Write-Host $pattern.Match($match).Groups[2].Value

        $match = $match.NextMatch()
    }
}
```

<!-- below, content of ./050-regex/multiline/readme.md -->

### Multiline

To make a search on more than one line:

```powershell

# Match a YAML block
#
#   The block start with --- on his own line
#   Then there is a content (one or more line)
#   The block ends with --- on his own line

$content = "---`nTitle: My great title`n---`n"

$pattern = [regex]"(?ms)(^\-{3}([\s\S]*\s)^\-{3})"

# Write the YAML content
Write-Host $([string]($pattern).Match($content).groups[2].value)
```

<!-- below, content of ./999-license/readme.md -->

## License

[MIT](./../LICENSE)
