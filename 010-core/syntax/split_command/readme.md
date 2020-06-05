# Split long string on multiple lines

Don't write things like:

```powershell
Write-Error "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab ...")
```

but split the string using the `$( ...)` syntax:

```powershell
Write-Error $("Sed ut perspiciatis unde omnis iste natus error " +
    "sit voluptatem accusantium doloremque laudantium, totam rem "
    "aperiam, eaque ipsa quae ab ...")
```

For commands too, don't write things like:

```powershell
$target = Get-Item -Path $filename | Select-Object -ExpandProperty Target | Select-Object -First 1
```

but split the command like this:

```powershell
$target = Get-Item -Path $filename `
    | Select-Object -ExpandProperty Target `
    | Select-Object -First 1
```
