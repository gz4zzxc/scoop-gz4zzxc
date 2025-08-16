param(
  [switch]$MsiMock,
  [switch]$PortableMock
)
$ErrorActionPreference = 'Stop'
Write-Host "[Test] Start LobeChat installer script branch tests..." -ForegroundColor Cyan

$manifestPath = Join-Path $PSScriptRoot '..' 'bucket' 'lobechat.json'
if(-not (Test-Path $manifestPath)){ throw "Manifest not found: $manifestPath" }

$json = Get-Content $manifestPath -Raw | ConvertFrom-Json
$origUrl = $json.url; $origVersion = $json.version

function Restore { $json.url = $origUrl; $json.version=$origVersion; ($json | ConvertTo-Json -Depth 64) | Set-Content $manifestPath -Encoding utf8NoBOM }
trap { Write-Warning $_; Restore; throw }

if($MsiMock -and $PortableMock){ throw 'Cannot set both -MsiMock and -PortableMock' }

$temp = New-Item -ItemType Directory -Path (Join-Path $env:TEMP ("lobechatTest_"+[guid]::NewGuid()))
Push-Location $temp.FullName

try {
  if($MsiMock){
    Write-Host '[Test] MSI branch' -ForegroundColor Yellow
    # Use a small known MSI (7zip example)
    $json.url = 'https://www.7-zip.org/a/7z2301-x64.msi#dl.7z'
    $json.version = '0.0.0-msi-test'
  } elseif($PortableMock){
    Write-Host '[Test] Portable branch' -ForegroundColor Yellow
    $json.version = '0.0.0-portable-test'
    $portableDir = New-Item -ItemType Directory -Path (Join-Path $temp.FullName 'p')
    Copy-Item $PSHOME\powershell.exe (Join-Path $portableDir.FullName 'LobeChatPortable.exe')
    $zip = Join-Path $temp.FullName 'portable-test.zip'
    Compress-Archive $portableDir $zip -Force
    # Start local server
    $serverJob = Start-Job -ScriptBlock { param($path) Push-Location $path; python -m http.server 8765 }
    Start-Sleep 2
    $json.url = 'http://127.0.0.1:8765/portable-test.zip#dl.7z'
  } else {
    Write-Host '[Test] Setup exe branch (real upstream asset)' -ForegroundColor Yellow
  }
  ($json | ConvertTo-Json -Depth 64) | Set-Content $manifestPath -Encoding utf8NoBOM

  scoop cache rm lobechat | Out-Null
  scoop uninstall lobechat -p 2>$null | Out-Null
  scoop install lobechat -k

  Write-Host 'Installed files:' -ForegroundColor Cyan
  Get-ChildItem "$env:USERPROFILE\scoop\apps\lobechat\current" | Select Name,Length | Format-Table | Out-String | Write-Host

  Write-Host 'Shim:' -ForegroundColor Cyan
  Get-Command lobechat | Format-List | Out-String | Write-Host

  scoop uninstall lobechat | Out-Null
  Write-Host '[Test] Uninstall completed'
}
finally {
  if($serverJob){ Stop-Job $serverJob -Force | Out-Null }
  Restore
  Pop-Location
  Remove-Item $temp.FullName -Recurse -Force
}
Write-Host '[Test] Done.' -ForegroundColor Green
