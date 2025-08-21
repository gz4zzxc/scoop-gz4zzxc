# LobeChat 安装程序测试脚本
# 用于验证安装逻辑是否正确

Write-Host "=== LobeChat 安装程序测试 ===" -ForegroundColor Cyan

# 模拟 scoop 安装目录
$testDir = Join-Path $env:TEMP "lobechat-test"
if (Test-Path $testDir) {
    Remove-Item $testDir -Recurse -Force
}
New-Item -ItemType Directory -Path $testDir | Out-Null

Write-Host "测试目录: $testDir" -ForegroundColor Yellow

# 模拟下载的安装文件
$exePath = Join-Path $testDir "LobeHub-Beta-1.114.0-setup.exe"
"# 模拟安装文件内容" | Out-File -FilePath $exePath -Encoding UTF8

Write-Host "创建模拟安装文件: $exePath" -ForegroundColor Green

# 测试安装脚本逻辑
Write-Host "`n=== 测试安装脚本逻辑 ===" -ForegroundColor Cyan

$dir = $testDir

try {
    Write-Host '开始安装 LobeChat...' -ForegroundColor Cyan
    Write-Host "# 查找安装文件" -ForegroundColor Gray
    
    # 查找安装文件
    $exe = Get-ChildItem $dir -Filter '*.exe' | Where-Object { $_.Name -match 'LobeHub.*setup' } | Select-Object -First 1
    
    if(-not $exe){
        Write-Host '未找到安装文件，尝试其他方式...' -ForegroundColor Yellow
        $exe = Get-ChildItem $dir -Filter '*.exe' | Select-Object -First 1
    }
    
    if(-not $exe){
        Write-Host '目录内容:' -ForegroundColor Yellow
        Get-ChildItem $dir | ForEach-Object { Write-Host $_.Name -ForegroundColor Gray }
        throw '未找到任何可执行文件'
    }
    
    Write-Host "找到安装文件: $($exe.Name)" -ForegroundColor Green
    Write-Host '执行静默安装...' -ForegroundColor Cyan
    
    # 模拟安装过程（不实际执行）
    Write-Host "模拟执行: $($exe.FullName) /S" -ForegroundColor Green
    Write-Host '安装完成（模拟）' -ForegroundColor Green
    
} catch {
    Write-Host "安装过程中出现错误: $_" -ForegroundColor Red
    throw
}

Write-Host "`n=== 测试完成 ===" -ForegroundColor Cyan

# 清理测试目录
Remove-Item $testDir -Recurse -Force
Write-Host "清理测试目录完成" -ForegroundColor Green
