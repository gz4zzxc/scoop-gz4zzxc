@echo off
chcp 65001 >nul
title 滴答清单管理员权限安装器

echo 🔐 滴答清单管理员权限安装器
echo =====================================
echo.

:: 检查管理员权限
net session >nul 2>&1
if %errorLevel% == 0 (
    echo ✅ 当前具有管理员权限
    goto :install
) else (
    echo ⚠️  需要管理员权限来安装滴答清单
    echo 正在请求管理员权限...
    echo.
    
    :: 重新以管理员身份运行此脚本
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:install
echo.
echo 📦 开始安装滴答清单...
echo.

:: 运行 PowerShell 安装脚本
powershell -ExecutionPolicy Bypass -File "%~dp0install-dida365-admin.ps1"

echo.
echo 安装完成！按任意键退出...
pause >nul
