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
