# scoop-gz4zzxc

[![Excavator](https://github.com/gz4zzxc/scoop-gz4zzxc/actions/workflows/excavator.yml/badge.svg)](https://github.com/gz4zzxc/scoop-gz4zzxc/actions/workflows/excavator.yml)

A custom [Scoop](https://scoop.sh/) bucket for gz4zzxc's applications.

## Installation

Make sure you have Scoop installed:

```powershell
# Install Scoop (if not already installed)
iwr -useb get.scoop.sh | iex
```

Add this bucket:

```powershell
scoop bucket add gz4zzxc https://github.com/gz4zzxc/scoop-gz4zzxc
```

## Available Apps

| App | Description | Version |
|-----|-------------|---------|
| lobehub | LobeChat 桌面客户端 | 1.124.4 |
| miniforge | Miniforge：由 conda-forge 社区维护的精简版 Conda 安装器（仅暴露 conda，不暴露 python；安装到 Miniforge3 子目录） | 25.3.1-0 |
| aliyundrive | 阿里云盘是一款速度快、不打扰、够安全、易于分享的网盘，由阿里巴巴集团出品 | 6.8.7 |
| eudic | 欧路词典是一款权威的英语词典软件，为您提供单词真人发音、英语翻译、跨软件取词、文章批改、语法错误纠正、划词搜索、英语扩充词库、英语背单词等功能 | 14.2.1.0 |
| dida365 | 滴答清单 (TickTick) 待办/日历/番茄融合，便携解包 (InnoSetup) | 6.3.6.0 |

### Miniforge (conda-forge minimal installer)

本仓库的 `miniforge` 清单是为个人需求定制的版本，具备以下特性：

- 只暴露 `conda`，不暴露 `python`
  - `bin` 仅导出 `Miniforge3\\condabin\\conda.bat`
  - 不会创建 `python.exe` 的 shim，避免覆盖系统或 UV 管理的 Python
- 安装到子目录 `Miniforge3`
  - 安装路径：`~\\scoop\\apps\\miniforge\\<version>\\Miniforge3`
  - 安装脚本会在应用目录内清理旧的 `Miniforge3` 子目录，避免因目录非空而失败（不会触碰 `%USERPROFILE%\\.conda\\envs` 等用户环境目录）
- 启动提示与建议
  - 安装完成后建议执行：`conda init` 初始化当前 Shell
  - 如果不想自动激活 base：`conda config --set auto_activate_base false`
  - 推荐设置通道优先级：`conda config --set channel_priority strict`

安装：

```powershell
scoop install gz4zzxc/miniforge
```

使用（示例）：

```powershell
# 查看 conda 版本与位置
scoop which conda
conda -V

# 不激活环境，直接运行指定环境内命令
conda run -n base python -V
conda run -n <env> pip list

# 激活与退出环境
conda activate <env>
conda deactivate
```

如果你需要在命令行直接使用 Miniforge 的 `python`，有两种方式：

- 方式 A：先 `conda activate <env>`，随后直接运行 `python`
- 方式 B：编辑本仓库 `bucket/miniforge.json`，在 `bin` 中加入：

```json
"Miniforge3\\python.exe"
```

保存后同步到本机 bucket 并重新安装 `miniforge`，Scoop 会创建 `python.exe` 的 shim（会改变默认 `python` 指向，请谨慎操作）。

## Usage

Install apps from this bucket:

```powershell
# Install 阿里云盘
scoop install gz4zzxc/aliyundrive

# Install 欧路词典
scoop install gz4zzxc/eudic


# Install 滴答清单
scoop install gz4zzxc/dida365
```

### AliyunDrive Installation Notes

The AliyunDrive manifest has been specially configured to handle download restrictions:

- **Automatic User-Agent Handling**: The manifest automatically downloads the installer with proper User-Agent headers to avoid 403 Forbidden errors
- **Fallback Download Method**: If the primary download method fails, it automatically tries an alternative approach
- **Progress Feedback**: Clear progress indicators and error messages during download and installation

If you encounter any download issues, the manifest includes comprehensive error handling and will attempt multiple download methods automatically.

### Eudic Installation Notes

The Eudic (欧路词典) manifest provides a comprehensive English dictionary solution:

- **Automatic Download**: The manifest automatically downloads the latest installer from the official website
- **Smart Installation**: Automatically detects and runs the installer executable from the downloaded archive
- **Rich Features**: Supports real pronunciation, cross-software word lookup, article correction, grammar error correction, and more
- **Multi-platform Sync**: Supports cloud synchronization of learning records across devices

The installation includes comprehensive progress feedback and error handling for a smooth setup experience.


### Dida365 (TickTick) Portable Notes

当前 `dida365` 清单使用 InnoSetup 安装包的解包模式（`"innosetup": true`），不直接执行安装程序：

- **无 UAC**：不写入 `Program Files`，全部文件解包到 Scoop 版本目录。
- **32/64 位**：同时提供 `type=win` 与 `type=win64` 下载地址，Scoop 自动选择。
- **纯便携**：不会创建系统卸载项；卸载只移除解包的程序文件。
- **数据独立**：运行后上游仍可能在 `%APPDATA%` / `%LOCALAPPDATA%` 生成用户数据（暂未做 `persist`，可视需要添加）。
- **自动版本探测**：`checkver.script` 通过下载安装包读取 `ProductVersion`。
- **更新简单**：`scoop update dida365` 即可，失败时可先 `scoop cache rm dida365` 再重试。

#### 安装

```powershell
scoop install gz4zzxc/dida365
```

#### 可能的后续增强（未实现）

- 持久化用户数据目录（需先确认具体文件夹名）。
- 在 manifest 中启用 `hash.mode: download` 以减少手动维护。
- 提供可选启动参数包装（番茄钟/调试等）。

如应用启动失败，请列出目录：

```powershell
Get-ChildItem "$env:USERPROFILE\scoop\apps\dida365\current" | Select Name
```

并反馈 issue。

## Auto-Update

This bucket uses Scoop’s native checkver/autoupdate to refresh manifests and the README version table:

- **Schedule**: Daily at 08:00 Beijing Time (00:00 UTC), plus manual dispatch
- **Scope**: All apps that define `checkver` and `autoupdate`
- **Mechanism**:
  - Runs `checkver * -u` to bump `version`, `url`, and `hash` where needed
  - Updates the Versions in the README “Available Apps” table to match manifests
  - Commits and pushes changes directly to `main` with `[skip ci]` to avoid loop

Notes:
- The workflow runs on `windows-latest` and installs Scoop transiently to use `checkver.ps1` (per Scoop docs)
- If upstream has no new release, the run completes with “No changes” and no PR is created

## Contributing

1. Fork this repository
2. Create your feature branch (`git checkout -b feature/new-app`)
3. Add your manifest file to the `bucket/` directory
4. Test your manifest using `scoop install <path-to-manifest>`
5. Commit your changes (`git commit -am 'Add new app'`)
6. Push to the branch (`git push origin feature/new-app`)
7. Create a Pull Request

## Manifest Format

See [Scoop Wiki](https://github.com/ScoopInstaller/Scoop/wiki/App-Manifests) for detailed manifest documentation.

## License

This bucket is licensed under the [Unlicense](https://unlicense.org/).
