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
