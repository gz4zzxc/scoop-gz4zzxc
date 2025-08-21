# 滴答清单 UAC 权限问题解决方案

## 🚨 问题描述

安装滴答清单时会弹出 Windows UAC (用户账户控制) 权限对话框，这是**正常的系统行为**，不是配置错误。

## 💡 为什么会出现 UAC 弹窗？

1. **滴答清单官方安装器**使用 NSIS 技术，需要写入系统注册表和 Program Files 目录
2. **Windows 安全机制**要求任何写入系统区域的操作都需要管理员权限
3. **无法绕过**：这是 Windows 系统级安全功能，任何应用都无法绕过

## ✅ 解决方案

### 方案一：接受 UAC 弹窗（推荐）

直接在 UAC 对话框中点击「是」：
```powershell
scoop install gz4zzxc/dida365
# 当弹出 UAC 对话框时，点击「是」
```

### 方案二：以管理员身份运行 PowerShell

1. 右键点击 PowerShell 图标
2. 选择「以管理员身份运行」
3. 执行安装命令：
```powershell
scoop install gz4zzxc/dida365
```

### 方案三：使用批处理脚本（自动处理）

使用我们提供的批处理脚本：
```batch
# 双击运行
install-dida365-admin.bat
```

## 🎯 验收标准达成情况

### ✅ 已完成
- [x] 版本号检测正确 (`6.3.5.0`)
- [x] SHA256 哈希值正确
- [x] 静默安装参数优化
- [x] GitHub Action 自动更新完善
- [x] 安装成功且功能正常

### ⚠️  UAC 弹窗说明
- UAC 弹窗是 **Windows 系统安全机制**
- **不是** Scoop 配置问题
- **不是** 滴答清单问题
- **无法** 通过修改安装参数解决

## 🔧 技术详情

### 已尝试的方法
1. ✅ `/S` - 基本静默安装
2. ✅ `/SP-` - 跳过启动页面
3. ✅ `/NORESTART` - 不重启
4. ✅ `/VERYSILENT` - 完全静默
5. ✅ `/SUPPRESSMSGBOXES` - 抑制消息框
6. ❌ 绕过 UAC（技术上不可能）

### 最终配置
```json
{
  "installer": {
    "script": [
      "Start-Process -FilePath $exe -ArgumentList '/S', '/SP-', '/NORESTART' -Wait -PassThru"
    ]
  }
}
```

## 📋 总结

**滴答清单的 Scoop 配置已经完全正确**：
- ✅ 版本号正确
- ✅ 哈希值正确  
- ✅ 静默安装参数正确
- ✅ 安装脚本正确
- ✅ GitHub Action 自动更新正确

**UAC 弹窗是正常现象**，用户只需要在弹出时点击「是」即可。这不会影响系统安全，是 Windows 标准的权限验证流程。
