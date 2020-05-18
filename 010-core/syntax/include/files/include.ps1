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
