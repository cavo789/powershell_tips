
# Match a YAML block
#
#   The block start with --- on his own line
#   Then there is a content (one or more line)
#   The block ends with --- on his own line

$content = "---`nTitle: My great title`n---`n"

$pattern = [regex]"(?ms)(^\-{3}([\s\S]*\s)^\-{3})"

# Write the YAML content
Write-Host $([string]($pattern).Match($content).groups[2].value)
