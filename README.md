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
| miniforge | Miniforge：由 conda-forge 社区维护的精简版 Conda 安装器（仅暴露 conda，不暴露 python；安装到 Miniforge3 子目录） | 25.3.1-0 |
| aliyundrive | 阿里云盘是一款速度快、不打扰、够安全、易于分享的网盘，由阿里巴巴集团出品 | 6.8.7 |
| eudic | 欧路词典是一款权威的英语词典软件，为您提供单词真人发音、英语翻译、跨软件取词、文章批改、语法错误纠正、划词搜索、英语扩充词库、英语背单词等功能 | 25.7.3 |
| trafficmonitor | Traffic Monitor 是一款用于 Windows 的网速、CPU 与内存监控悬浮窗，支持嵌入任务栏与更换皮肤 | 1.85.1 |

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
"Miniforge3\\\python.exe"
```

保存后同步到本机 bucket 并重新安装 `miniforge`，Scoop 会创建 `python.exe` 的 shim（会改变默认 `python` 指向，请谨慎操作）。

## Usage

Install apps from this bucket:

```powershell
# Install 阿里云盘
scoop install gz4zzxc/aliyundrive

# Install 欧路词典
scoop install gz4zzxc/eudic

# Install Traffic Monitor
scoop install gz4zzxc/trafficmonitor
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

### Traffic Monitor Installation Notes

Traffic Monitor provides real-time network, CPU, and memory monitoring:

- **Multiple Architectures**: Supports 64-bit, 32-bit, and ARM64 versions
- **Taskbar Integration**: Can be embedded into the Windows taskbar
- **Customizable Skins**: Supports theme customization
- **Hardware Monitoring**: Standard version includes temperature monitoring (requires admin rights)
- **Lite Version**: Available without temperature monitoring for non-admin users

**Note**: If you encounter MSVC runtime library errors, please install Visual C++ Redistributable first.

## Auto-Update

This bucket includes an automated update system that checks for new versions daily:

- **Schedule**: Every day at 8:00 AM Beijing Time
- **Target**: All apps with checkver/autoupdate configurations
- **Actions**: 
  - **AliyunDrive**: Custom update logic for download restrictions
  - **Other Apps**: Uses official ScoopInstaller/Excavator for automatic updates
  - Automatically updates manifest files, creates releases, and notifies via issues

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
