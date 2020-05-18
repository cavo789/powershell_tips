[int] $Amount = 5
[string] $Type = "pargraphs"
[string] $Start = "yes"

[xml]$Temp = Invoke-WebRequest -UseBasicParsing -Uri "https://www.lipsum.com/feed/xml?amount=$Amount&what=$Type&start=$Start"

$Temp.feed.lipsum
