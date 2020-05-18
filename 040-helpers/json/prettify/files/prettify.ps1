$objJSON = Get-Content -Path ".\test.json"
$objJSON | ConvertFrom-Json | ConvertTo-Json | Out-File -FilePath ".\test-Pretty.json"
Get-Content ".\test-Pretty.json"
