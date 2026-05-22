param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("agents", "skills", "both", "verify-removed")]
    [string]$Mode,

    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Get-TargetFiles {
    param([string]$Mode)
    $agents = @(Get-ChildItem -Path ".claude/agents/*.md" -File)
    $skills = @(Get-ChildItem -Path ".claude/skills" -Recurse -Filter "SKILL.md" -File)

    switch ($Mode) {
        "agents" { return $agents }
        "skills" { return $skills }
        "both" { return $agents + $skills }
        "verify-removed" { return $agents + $skills }
    }
}

$files = Get-TargetFiles -Mode $Mode

$updated = 0
$skipped = 0
$errors = 0
$errorList = @()

# Pattern matches: ---\r\n[blank line]**Language Policy**: <one-line>\r\n[blank line]
# Replaces with: ---\r\n[blank line] -- restoring the original spacing.
$pattern = "(?s)(---\r?\n)(\r?\n)\*\*Language Policy\*\*:[^\r\n]*\r?\n\r?\n"

foreach ($file in $files) {
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    $content = [System.IO.File]::ReadAllText($file.FullName, $utf8NoBom)

    if ($null -eq $content -or $content.Length -eq 0) {
        $errors++
        $errorList += "EMPTY: $($file.FullName)"
        continue
    }

    $hasPolicy = $content -match "\*\*Language Policy\*\*"

    if ($Mode -eq "verify-removed") {
        if ($hasPolicy) {
            $errors++
            $errorList += "STILL HAS POLICY: $($file.FullName)"
        }
        continue
    }

    if (-not $hasPolicy) {
        $skipped++
        continue
    }

    if ($content -match $pattern) {
        $newContent = $content -replace $pattern, "`$1`$2"

        if ($DryRun) {
            Write-Output "WOULD REMOVE FROM: $($file.FullName)"
        } else {
            [System.IO.File]::WriteAllText($file.FullName, $newContent, $utf8NoBom)
        }
        $updated++
    } else {
        $errors++
        $errorList += "POLICY PRESENT BUT PATTERN DID NOT MATCH: $($file.FullName)"
    }
}

Write-Output "================================"
Write-Output "Mode: $Mode  DryRun: $DryRun"
Write-Output "Total files: $($files.Count)"
Write-Output "Updated/would-update: $updated"
Write-Output "Skipped (no policy line): $skipped"
Write-Output "Errors: $errors"
if ($errorList.Count -gt 0) {
    Write-Output "--- Errors ---"
    $errorList | ForEach-Object { Write-Output $_ }
}
