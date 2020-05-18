
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
