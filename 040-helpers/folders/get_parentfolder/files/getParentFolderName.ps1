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
