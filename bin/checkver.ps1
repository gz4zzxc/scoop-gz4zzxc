# Check version script for all manifests in the bucket
param(
    [String]$App = '*',
    [Switch]$Update,
    [Switch]$ForceUpdate,
    [Switch]$SkipUpdated
)

if (-not (Get-Command 'scoop' -ErrorAction SilentlyContinue)) {
    Write-Error "Scoop is not installed or not in PATH"
    exit 1
}

$bucketDir = Join-Path $PSScriptRoot '..\bucket'
$manifests = Get-ChildItem $bucketDir -Filter '*.json' | Where-Object { $_.BaseName -like $App }

if ($manifests.Count -eq 0) {
    Write-Warning "No manifests found matching pattern: $App"
    exit 0
}

foreach ($manifest in $manifests) {
    $name = $manifest.BaseName
    Write-Host "Checking $name..." -ForegroundColor Cyan
    
    $params = @($name)
    if ($Update) { $params += '-u' }
    if ($ForceUpdate) { $params += '-f' }
    if ($SkipUpdated) { $params += '-s' }
    
    & scoop checkver @params
    Write-Host ""
}
