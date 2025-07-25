# 自动更新工作流说明

## 概述

这个 GitHub Action 工作流会自动检测阿里网盘的更新，并同步到 Scoop 配置文件中。

## 功能特性

### 🕐 定时执行
- **执行时间**: 每天北京时间早上 8:00 (UTC 00:00)
- **手动触发**: 支持通过 GitHub Actions 页面手动运行

### 🔍 更新检测
工作流使用多种方法检测阿里网盘的新版本：

1. **方法一**: 直接解析官方下载页面
2. **方法二**: 检查当前下载链接是否仍然有效
3. **方法三**: 尝试常见的版本号递增模式

### 📝 自动更新内容
当检测到新版本时，工作流会自动更新：

- `bucket/aliyundrive.json` - Scoop 配置文件
- `README.md` - 版本信息表格

### 🚀 自动发布
- 创建 Git 标签和 GitHub Release
- 生成详细的更新说明
- 包含安装和更新指令

### 📢 通知机制
- 创建 GitHub Issue 通知更新
- 自动关闭之前的更新通知
- 包含详细的变更信息

## 工作流步骤

1. **环境准备**
   - 检出代码
   - 设置 Python 环境
   - 安装依赖包

2. **验证现有配置**
   - 运行 `scripts/validate-manifests.py`
   - 确保当前配置文件格式正确

3. **检测更新**
   - 获取当前版本号
   - 检查官方下载页面
   - 验证新版本下载链接

4. **更新文件**
   - 更新 JSON 配置文件
   - 更新 README 版本信息
   - 提交更改到仓库

5. **发布和通知**
   - 创建 GitHub Release
   - 创建通知 Issue
   - 添加相关标签

## 配置文件

### 主要配置
```yaml
# 执行时间 - 北京时间每天早上8点
schedule:
  - cron: '0 0 * * *'

# 权限设置
permissions:
  contents: write
  pull-requests: write
```

### 环境变量
- `GITHUB_TOKEN`: 自动提供，用于 API 调用
- `GITHUB_OUTPUT`: 用于步骤间数据传递

## 使用方法

### 启用自动更新
1. 确保仓库中存在 `.github/workflows/excavator.yml`
2. 工作流会自动在设定时间运行
3. 也可以在 Actions 页面手动触发

### 手动运行
1. 进入 GitHub 仓库
2. 点击 "Actions" 标签
3. 选择 "Auto Update Manifests" 工作流
4. 点击 "Run workflow" 按钮

### 监控更新
- 查看 Actions 页面的运行日志
- 关注自动创建的 Issue 通知
- 检查 Releases 页面的新发布

## 故障排除

### 常见问题

1. **网络连接失败**
   - 工作流会自动重试
   - 检查阿里网盘官网是否可访问

2. **版本检测失败**
   - 工作流会尝试多种检测方法
   - 可以手动运行测试脚本验证

3. **文件更新失败**
   - 检查文件权限和格式
   - 运行 `scripts/validate-manifests.py` 验证

### 调试工具

- `scripts/test-url-check.py` - 测试 URL 可用性
- `scripts/validate-manifests.py` - 验证配置文件
- `scripts/check-aliyundrive-update.py` - 完整更新检测

## 维护说明

### 定期检查
- 每月检查工作流运行状态
- 验证检测逻辑是否仍然有效
- 更新依赖包版本

### 更新检测逻辑
如果阿里网盘更改了下载页面结构：
1. 更新正则表达式模式
2. 调整 URL 检测逻辑
3. 测试新的检测方法

### 扩展功能
- 添加更多软件的自动更新
- 集成邮件或其他通知方式
- 添加更详细的版本比较逻辑
