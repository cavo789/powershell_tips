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
