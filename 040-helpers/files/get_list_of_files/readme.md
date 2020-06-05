# Get a flat list of files

The function below will retrieve the list of all files below the current running folder and will returns a flat list (i.e. only files name).

The function support exclusions like skipping specific folders or files.

```powershell
<!-- concat-md::include "./files/getListOfFiles.ps1" -->
```

This will return something like below:

```text
<!-- concat-md::include "./files/getListOfFiles.txt" -->
```

## Get the depth too

The following snippet calculate a FolderDepth column based on the number of `\` separator in the filename:

```powershell
<!-- concat-md::include "./files/getListOfFilesWithDepth.ps1" -- >
```

This will return something like below:

```powershell
<!-- concat-md::include "./files/getListOfFilesWithDepth.txt" -- >
```

## Get list of files, recursively

Get the list of files, with or without a filter like a file's extension and define the maximum deep allowed so it's possible to get only the root folder (`MaxDepth=0`, the root and the first children, ...).

```powershell
<!-- concat-md::include "./files/getListOfFilesRecursiveWithMaxDepth.ps1" -- >
```

