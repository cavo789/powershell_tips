$content = "Ipso lorem`n`n@TOdo Christophe: do this.`n`nIpso lorem"

$pattern = [regex]"(?msi)^(\@todo ([^\n\r]*))"

if (($pattern.Match($content)).success) {
    Write-Warning "@TODO found at the beginning of the string"
    Write-Host "There is a TODO for $($pattern.Match($content).groups[2].value)"
}
