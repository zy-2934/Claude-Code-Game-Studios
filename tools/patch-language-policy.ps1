param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("agents", "skills", "verify")]
    [string]$Mode,

    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# Read the policy line from an external UTF-8 file so we never store Chinese
# characters inside a Windows PowerShell 5.1 script literal (which would be
# read with the system codepage and mangled).
$snippetPath = Join-Path $PSScriptRoot "policy-snippet.txt"
if (-not (Test-Path $snippetPath)) {
    throw "policy-snippet.txt not found at $snippetPath"
}
$policyLine = (Get-Content -Path $snippetPath -Raw -Encoding UTF8).TrimEnd("`r", "`n")

function Get-TargetFiles {
    param([string]$Mode)
    if ($Mode -eq "agents") {
        return Get-ChildItem -Path ".claude/agents/*.md" -File
    } elseif ($Mode -eq "skills") {
        return Get-ChildItem -Path ".claude/skills" -Recurse -Filter "SKILL.md" -File
    } elseif ($Mode -eq "verify") {
        $agents = Get-ChildItem -Path ".claude/agents/*.md" -File
        $skills = Get-ChildItem -Path ".claude/skills" -Recurse -Filter "SKILL.md" -File
        return @($agents) + @($skills)
    }
}

$files = Get-TargetFiles -Mode $Mode

$updated = 0
$skipped = 0
$errors = 0
$errorList = @()

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8

    if ($null -eq $content) {
        $errors++
        $errorList += "EMPTY: $($file.FullName)"
        continue
    }

    if ($content -match "Language Policy") {
        $skipped++
        continue
    }

    if ($Mode -eq "verify") {
        $errors++
        $errorList += "MISSING POLICY: $($file.FullName)"
        continue
    }

    if ($content -match "(?s)^(---\r?\n.*?\r?\n---\r?\n)(.*)$") {
        $frontmatter = $matches[1]
        $body = $matches[2]

        # Trim any leading whitespace from the body so spacing is uniform.
        $body = $body -replace "^\s+", ""

        $newContent = $frontmatter + "`r`n" + $policyLine + "`r`n`r`n" + $body

        if ($DryRun) {
            Write-Output "WOULD UPDATE: $($file.FullName)"
        } else {
            # Write as UTF-8 without BOM
            $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
            [System.IO.File]::WriteAllText($file.FullName, $newContent, $utf8NoBom)
        }
        $updated++
    } else {
        $errors++
        $errorList += "NO FRONTMATTER: $($file.FullName)"
    }
}

Write-Output "================================"
Write-Output "Mode: $Mode  DryRun: $DryRun"
Write-Output "Total files: $($files.Count)"
Write-Output "Updated/would-update: $updated"
Write-Output "Skipped (already has policy): $skipped"
Write-Output "Errors: $errors"
if ($errorList.Count -gt 0) {
    Write-Output "--- Errors ---"
    $errorList | ForEach-Object { Write-Output $_ }
}
