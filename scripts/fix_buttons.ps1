
# M2 Button Standardization Script
# Replaces all legacy purple ElevatedButton patterns with PrimaryButton across all screens
# Run from project root: powershell -File scripts\fix_buttons.ps1

Set-Location $PSScriptRoot\..
$screensDir = "lib\features\patient\presentation\screens"
$primaryImport = "import '../../../../shared/widgets/primary_button.dart';"

function NormalizeToLF($text) { return $text.Replace("`r`n", "`n").Replace("`r", "`n") }
function NormalizeToCRLF($text) { return $text.Replace("`n", "`r`n") }

function AddImportIfMissing($content, $file) {
    if ($content -notmatch "primary_button\.dart") {
        # Insert after last existing import line
        $content = $content -replace "(import '[^']+\.dart';)(\n(?!import ))", "`$1`n$primaryImport`$2"
    }
    return $content
}

$files = Get-ChildItem "$screensDir\*.dart" | Select-Object -ExpandProperty FullName
$totalFixed = 0

foreach ($filePath in $files) {
    $fileName = Split-Path $filePath -Leaf
    $rawContent = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)
    $content = NormalizeToLF $rawContent
    $original = $content

    # Only process files that have ElevatedButton
    if ($content -notmatch "ElevatedButton") { continue }

    $content = AddImportIfMissing $content $filePath

    # Pattern 1: Purple ElevatedButton with SizedBox wrapper (most common)
    # Matches: SizedBox(width: double.infinity, height: XX, child: ElevatedButton(onPressed: X, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFXXXXXX - purple), ...child: Text('LABEL',...)))
    # This handles the common case - we'll do specific replacements per file for complex cases

    # Generic: Replace simple purple-background ElevatedButton with PrimaryButton
    # Pattern: backgroundColor: const Color(0xFF5B14B8|7C3AED|6D28D9|3B0764)
    # We use a line-by-line approach for safety

    $lines = $content -split "`n"
    $result = [System.Collections.Generic.List[string]]::new()
    $i = 0
    $fileChanged = $false

    while ($i -lt $lines.Count) {
        $line = $lines[$i]

        # Detect start of SizedBox wrapping an ElevatedButton
        if ($line -match '^\s+SizedBox\(' -and ($i + 2) -lt $lines.Count) {
            # Look ahead to find ElevatedButton block
            $indent = ($line -match '^(\s+)') ? $Matches[1] : '                    '
            $blockStart = $i
            $j = $i + 1
            $foundEB = $false
            $ebStart = -1

            # Scan up to 5 lines ahead for ElevatedButton or ElevatedButton.icon
            while ($j -lt [Math]::Min($i + 6, $lines.Count)) {
                if ($lines[$j] -match '^\s+child: ElevatedButton[\.\(]') {
                    $foundEB = $true
                    $ebStart = $j
                    break
                }
                $j++
            }

            if ($foundEB) {
                # Collect the entire ElevatedButton block by bracket counting
                $depth = 0
                $k = $blockStart
                $blockLines = [System.Collections.Generic.List[string]]::new()
                $inBlock = $false

                while ($k -lt $lines.Count) {
                    $l = $lines[$k]
                    $blockLines.Add($l)
                    foreach ($ch in $l.ToCharArray()) {
                        if ($ch -eq '(') { $depth++; $inBlock = $true }
                        elseif ($ch -eq ')') { $depth-- }
                    }
                    if ($inBlock -and $depth -le 0) { $k++; break }
                    $k++
                }

                $blockText = $blockLines -join "`n"

                # Only replace if it has a purple/dark background color (primary CTA)
                $isPurple = $blockText -match 'backgroundColor: const Color\(0xFF(5B14B8|7C3AED|6D28D9|3B0764|0F172A|0B1C30)'

                if ($isPurple) {
                    # Extract label text
                    $labelMatch = [regex]::Match($blockText, "(?:child: (?:const )?Text\(\s*'([^']+)'|label: (?:const )?Text\(\s*'([^']+)')")
                    $label = if ($labelMatch.Success) { 
                        if ($labelMatch.Groups[1].Success) { $labelMatch.Groups[1].Value }
                        else { $labelMatch.Groups[2].Value }
                    } else { 'Button' }

                    # Extract onPressed
                    $onPressedMatch = [regex]::Match($blockText, 'onPressed: ([^,]+(?:\{[^}]*\})?)')
                    $onPressed = if ($onPressedMatch.Success) { $onPressedMatch.Groups[1].Value.Trim() } else { 'null' }

                    # Check for isSubmitting loading pattern
                    $hasLoading = $blockText -match '_isSubmitting \? null :'
                    $hasDark = $blockText -match 'Color\(0xFF(0F172A|0B1C30)\)'

                    $btnIndent = $indent

                    if ($hasDark -and -not $hasLoading) {
                        # Dark navy button - use dark backgroundColor
                        $replacement = "$btnIndent`PrimaryButton(`n$btnIndent  label: '$label',`n$btnIndent  onPressed: $onPressed,`n$btnIndent  backgroundColor: const Color(0xFF0B1C30),`n$btnIndent),"
                    } elseif ($hasLoading) {
                        $replacement = "$btnIndent`PrimaryButton(`n$btnIndent  label: '$label',`n$btnIndent  onPressed: _isSubmitting ? null : _handleAcceptOffer,`n$btnIndent  isLoading: _isSubmitting,`n$btnIndent),"
                    } else {
                        $replacement = "$btnIndent`PrimaryButton(`n$btnIndent  label: '$label',`n$btnIndent  onPressed: $onPressed,`n$btnIndent),"
                    }

                    $result.Add($replacement)
                    $i = $k
                    $fileChanged = $true
                    continue
                }
            }
        }

        $result.Add($line)
        $i++
    }

    if ($fileChanged) {
        $newContent = $result -join "`n"
        [System.IO.File]::WriteAllText($filePath, (NormalizeToCRLF $newContent), [System.Text.Encoding]::UTF8)
        Write-Host "UPDATED: $fileName"
        $totalFixed++
    }
}

Write-Host "`nTotal files updated: $totalFixed"
