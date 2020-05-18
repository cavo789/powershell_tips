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
