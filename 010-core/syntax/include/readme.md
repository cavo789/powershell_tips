# Include external script

Including an external script (f.i. `my_helper.ps1`) can be done using the dot notation: `. my_helper.ps1`.

```powershell
<!-- concat-md::include "./files/include.ps1" -->
```

Note: functions should be declare with the `global:` prefix.
