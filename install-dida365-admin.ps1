# 滴答清单管理员权限安装脚本
Write-Host "🔐 滴答清单管理员权限安装脚本" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# 检查是否以管理员身份运行
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "❌ 当前 PowerShell 没有管理员权限" -ForegroundColor Red
    Write-Host "请右键点击 PowerShell，选择'以管理员身份运行'" -ForegroundColor Yellow
    Write-Host "然后重新运行此脚本" -ForegroundColor Yellow
    Read-Host "按任意键退出"
    exit 1
}

Write-Host "✅ 当前 PowerShell 具有管理员权限" -ForegroundColor Green

# 检查 Scoop 是否安装
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Scoop 未安装" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Scoop 已安装" -ForegroundColor Green

# 检查 bucket 状态
Write-Host "`n📦 检查 bucket 状态..." -ForegroundColor Yellow
$buckets = scoop bucket list | Where-Object { $_.Name -eq "gz4zzxc" }
if ($buckets) {
    Write-Host "✅ gz4zzxc bucket 已添加" -ForegroundColor Green
} else {
    Write-Host "⚠️  gz4zzxc bucket 未找到，正在添加..." -ForegroundColor Yellow
    scoop bucket add gz4zzxc https://github.com/gz4zzxc/scoop-gz4zzxc
}

# 检查是否已安装
Write-Host "`n🔍 检查安装状态..." -ForegroundColor Yellow
$installed = scoop list | Select-String "dida365"
if ($installed) {
    Write-Host "⚠️  滴答清单已安装，先卸载..." -ForegroundColor Yellow
    scoop uninstall dida365
}

# 执行安装
Write-Host "`n📦 开始安装滴答清单..." -ForegroundColor Yellow
try {
    scoop install gz4zzxc/dida365
    if ($?) {
        Write-Host "✅ 安装成功！" -ForegroundColor Green
        
        # 验证安装
        $appPath = scoop prefix dida365
        if (Test-Path $appPath) {
            Write-Host "安装路径: $appPath" -ForegroundColor Cyan
            
            # 查找可执行文件
            $exeFiles = Get-ChildItem $appPath -Filter "*.exe" -Recurse
            if ($exeFiles) {
                Write-Host "找到可执行文件:" -ForegroundColor Cyan
                $exeFiles | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor White }
            }
            
            # 检查版本
            $version = scoop list | Select-String "dida365" | ForEach-Object { 
                if ($_ -match "dida365\s+\(([^)]+)\)") { $matches[1] } 
            }
            Write-Host "安装版本: $version" -ForegroundColor Cyan
            
        } else {
            Write-Host "❌ 安装路径不存在" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ 安装失败" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ 安装过程出错: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`n✨ 安装完成！" -ForegroundColor Green
Write-Host "滴答清单已成功安装，无需 UAC 弹窗！" -ForegroundColor Green
Read-Host "按任意键退出"
