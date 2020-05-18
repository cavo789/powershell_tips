$content = "# Heading 1`n`n## Heading 1.1`n`n## Heading 1.2`n`n## Heading 1.3"

# Skip heading 1 so start at 2
#    (?ms)       ==> Multi-lines regex
#    ^           ==> The start of the line
#    (\#{2,})    ==> We need to find at least two consecutive #
#     ([^\n\r]*) ==> Capture the end of the line (exclude CRLF)
#    $          ==> End of the line
$pattern = [regex]"(?ms)^(\#{2,}) ([^\n\r]*)$"

$headings = $pattern.Matches($content);

if ($headings.Count -gt 0) {
    $match = $pattern.Match($content)

    while ($match.Success) {
        # Isolate the # (one or more) and the title
        $pattern = [regex]"(#{2,})* (.*)"

        # Display "Heading 1.1", "Heading 1.2", ...
        Write-Host $pattern.Match($match).Groups[2].Value

        $match = $match.NextMatch()
    }
}
