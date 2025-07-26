#!/usr/bin/env pwsh
# Test script for AliyunDrive installation via Scoop

Write-Host "=== AliyunDrive Scoop Installation Test ===" -ForegroundColor Cyan
Write-Host ""

# Check if Scoop is installed
if (-not (Get-Command 'scoop' -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Scoop is not installed. Please install Scoop first:" -ForegroundColor Red
    Write-Host "   iwr -useb get.scoop.sh | iex" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Scoop is installed" -ForegroundColor Green

# Add bucket if not already added
$buckets = scoop bucket list
if ($buckets -notmatch "gz4zzxc") {
    Write-Host "📦 Adding gz4zzxc bucket..." -ForegroundColor Yellow
    scoop bucket add gz4zzxc https://github.com/gz4zzxc/scoop-gz4zzxc
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Bucket added successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to add bucket" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ gz4zzxc bucket already added" -ForegroundColor Green
}

# Check if AliyunDrive is already installed
$installed = scoop list aliyundrive 2>$null
if ($installed) {
    Write-Host "⚠️  AliyunDrive is already installed. Uninstalling first..." -ForegroundColor Yellow
    scoop uninstall aliyundrive
}

# Install AliyunDrive
Write-Host "📥 Installing AliyunDrive..." -ForegroundColor Yellow
scoop install gz4zzxc/aliyundrive

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ AliyunDrive installed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Installation Summary:" -ForegroundColor Cyan
    scoop list aliyundrive
    Write-Host ""
    Write-Host "🎉 You can now find AliyunDrive in your Start Menu or Desktop!" -ForegroundColor Green
    Write-Host "💡 First time users need to login with their Alibaba Cloud account." -ForegroundColor Yellow
} else {
    Write-Host "❌ Installation failed!" -ForegroundColor Red
    exit 1
}
