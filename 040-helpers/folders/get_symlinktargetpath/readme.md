# Get the target filename of a symlink

When a file is a symbolic or hard link, the following function will return the original filename.

For instance if `c:\temp\a.ps1` is symlink to `c:\christophe\repositories\tools\utils.ps1`, the following function will return the full name of the original filename so will return `c:\christophe\repositories\tools\utils.ps1`.

```powershell
<!-- concat-md::include "./files/getSymLinkTargetPath.ps1" -->
```
