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
