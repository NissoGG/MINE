$ErrorActionPreference = "Stop"

$addonName = "MINE"
$projectDirectory = $PSScriptRoot
$tocPath = Join-Path $projectDirectory "$addonName.toc"
$filesToPackage = @(
    "$addonName.toc",
    "Core.lua",
    "README.md"
)

if (-not (Test-Path -LiteralPath $tocPath -PathType Leaf)) {
    throw "Addon manifest not found: $tocPath"
}

$tocContent = [System.IO.File]::ReadAllText($tocPath, [System.Text.Encoding]::UTF8)
if ($tocContent -notmatch '(?m)^## Version:\s*(\S+)\s*$') {
    throw "Could not read the addon version from $tocPath"
}
$version = $Matches[1]
if ($tocContent -notmatch '(?m)^## Interface:\s*(\d+)\s*$') {
    throw "Could not read the client interface version from $tocPath"
}

$interfaceVersion = $Matches[1]

foreach ($file in $filesToPackage) {
    if (-not (Test-Path -LiteralPath (Join-Path $projectDirectory $file) -PathType Leaf)) {
        throw "Required package file not found: $(Join-Path $projectDirectory $file)"
    }
}

$outputDirectory = Join-Path $projectDirectory "dist"
$archivePath = Join-Path $outputDirectory "$addonName-$version.zip"
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
if (Test-Path -LiteralPath $archivePath) {
    Remove-Item -LiteralPath $archivePath -Force
}

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::Open(
    $archivePath,
    [System.IO.Compression.ZipArchiveMode]::Create
)
try {
    foreach ($file in $filesToPackage) {
        $entry = $archive.CreateEntry("$addonName/$file", [System.IO.Compression.CompressionLevel]::Optimal)
        $entryStream = $entry.Open()
        if ($file -eq "$addonName.toc") {
            $writer = New-Object System.IO.StreamWriter($entryStream, (New-Object System.Text.UTF8Encoding($false)))
            try {
                $writer.Write($tocContent)
            }
            finally {
                $writer.Dispose()
                $entryStream.Dispose()
            }
        }
        else {
            $sourceStream = [System.IO.File]::OpenRead((Join-Path $projectDirectory $file))
            try {
                $sourceStream.CopyTo($entryStream)
            }
            finally {
                $sourceStream.Dispose()
                $entryStream.Dispose()
            }
        }
    }
}
finally {
    $archive.Dispose()
}

$archive = [System.IO.Compression.ZipFile]::OpenRead($archivePath)
try {
    $entryNames = @($archive.Entries | ForEach-Object { $_.FullName })
    foreach ($file in $filesToPackage) {
        if ($entryNames -notcontains "$addonName/$file") {
            throw "Package is missing expected entry: $addonName/$file"
        }
    }
}
finally {
    $archive.Dispose()
}

Write-Output "Created WoW Forever addon package: $archivePath (Interface: $interfaceVersion)"
