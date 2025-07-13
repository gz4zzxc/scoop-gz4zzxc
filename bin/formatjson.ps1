# Format JSON files in the bucket directory
param(
    [String]$App = '*'
)

$bucketDir = Join-Path $PSScriptRoot '..\bucket'
$manifests = Get-ChildItem $bucketDir -Filter '*.json' | Where-Object { $_.BaseName -like $App }

if ($manifests.Count -eq 0) {
    Write-Warning "No manifests found matching pattern: $App"
    exit 0
}

foreach ($manifest in $manifests) {
    Write-Host "Formatting $($manifest.Name)..." -ForegroundColor Cyan
    
    try {
        $json = Get-Content $manifest.FullName -Raw | ConvertFrom-Json
        $formatted = $json | ConvertTo-Json -Depth 100
        Set-Content -Path $manifest.FullName -Value $formatted -Encoding UTF8
        Write-Host "✓ Formatted successfully" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to format $($manifest.Name): $_"
    }
}
