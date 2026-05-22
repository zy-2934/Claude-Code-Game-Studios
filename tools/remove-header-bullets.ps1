param(
    [switch]$DryRun,
    [switch]$IncludeYamlHeaders
)

$ErrorActionPreference = "Stop"

$files = Get-ChildItem -Path ".claude/skills" -Recurse -Filter "SKILL.md" -File

$updated = 0
$skipped = 0
$linesRemoved = 0

foreach ($file in $files) {
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    $content = [System.IO.File]::ReadAllText($file.FullName, $utf8NoBom)
    $original = $content

    # Pattern 1: markdown bullet `- Header: "..."` or `- **Header**: "..."` (capital H)
    # Match the entire line including trailing newline.
    $content = $content -replace '(?m)^\s*-\s*(\*\*)?Header(\*\*)?:\s*".*"\s*\r?\n', ''

    if ($IncludeYamlHeaders) {
        # Pattern 2: YAML-style `header: "..."` (lowercase, inside fenced code blocks)
        $content = $content -replace '(?m)^\s*header:\s*".*"\s*\r?\n', ''
    }

    if ($content -ne $original) {
        $originalLines = ($original -split "`n").Count
        $newLines = ($content -split "`n").Count
        $diff = $originalLines - $newLines

        if ($DryRun) {
            Write-Output "WOULD UPDATE: $($file.FullName) (-$diff lines)"
        } else {
            [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBom)
        }
        $updated++
        $linesRemoved += $diff
    } else {
        $skipped++
    }
}

Write-Output "================================"
Write-Output "Mode: remove-header-bullets  DryRun: $DryRun  IncludeYamlHeaders: $IncludeYamlHeaders"
Write-Output "Files updated: $updated"
Write-Output "Files unchanged: $skipped"
Write-Output "Total lines removed: $linesRemoved"
