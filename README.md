# 🪣 scoop-gz4zzxc

[![Excavator](https://github.com/gz4zzxc/scoop-gz4zzxc/actions/workflows/excavator.yml/badge.svg)](https://github.com/gz4zzxc/scoop-gz4zzxc/actions/workflows/excavator.yml)

一个定制的 [Scoop](https://scoop.sh/) Bucket，主要提供「便携解包」版本的应用程序，也收录少数需要官方安装器和系统组件的应用。

## 📥 安装

确保已安装 Scoop：

```powershell
# 安装 Scoop（如果尚未安装）
iwr -useb get.scoop.sh | iex
```

添加此 Bucket：

```powershell
scoop bucket add gz4zzxc https://github.com/gz4zzxc/scoop-gz4zzxc
```

## 📦 可用应用

| App | Description | Version |
| --- | --- | --- |
| lobehub | LobeChat 桌面客户端 | 2.2.10 |
| miniforge | Conda-forge 精简版（仅 conda） | 26.3.2-3 |
| aliyundrive | 阿里云盘官方客户端 | 6.9.1 |
| eudic | 欧路词典：英语词典软件 | 26.4.0.0 |
| dida365 | 滴答清单：待办/日历/番茄钟 | 8.1.2.0 |
| motrix-next | 基于 Tauri 重写的 Motrix 下载管理器 | 3.9.6 |
| ndi-tools | NDI 音视频网络工具集 | 6.3.2 |
| pixpin | 强大且免费的截图贴图工具（截图/贴图/OCR/标注） | 3.4.3.2 |

### 🐍 Miniforge (conda-forge minimal installer)

本仓库提供的 `miniforge` 清单采用较保守的集成方式，适合希望将 Conda 与系统 Python、UV 或自定义 shell 配置分开管理的用户。

- **默认行为**
  - 仅导出 `Miniforge3\\condabin\\conda.bat`，不创建 `python.exe` shim
  - 不自动修改 PATH，不自动改写 shell profile
  - 安装目录为 `~\\scoop\\apps\\miniforge\\<version>\\Miniforge3`
- **升级边界**
  - Scoop 升级会替换 `~\\scoop\\apps\\miniforge\\<version>\\Miniforge3` 下的安装内容
  - 不会修改用户级 `~/.condarc`、`%USERPROFILE%\\.conda` 或你的 shell profile
  - 安装脚本只会清理版本目录内旧的 `Miniforge3` 子目录，以避免目录非空导致安装失败
- **Shell 集成说明**
  - 如果你只使用 `conda run`、`conda create`、`conda install` 等命令，通常不需要执行 `conda init`
  - 只有当你需要 `conda activate` 直接影响当前 shell 时，才需要按需执行 `conda init <shell>`
  - Bash / Zsh / Fish 等常规 shell 建议先运行 `conda init --dry-run <shell>`，确认将修改哪些文件
  - PowerShell 用户，尤其是已使用 Starship、oh-my-posh 或自定义 profile 的用户，请不要直接执行 `conda init powershell`；建议先查看 `conda init --dry-run powershell`
  - 如果误执行了 `conda init powershell`，可先用 `conda init --reverse powershell` 查看或回退上次初始化影响
- **建议配置**
  - 如不希望自动激活 `base`：`conda config --set auto_activate_base false`
  - 如使用 Starship 或其他 prompt 框架显示 Conda 环境名：`conda config --set changeps1 false`
  - 如希望通道解析更严格：`conda config --set channel_priority strict`

#### 安装

```powershell
scoop install gz4zzxc/miniforge
```

#### 使用（示例）

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

> 💡 **提示**：如果你需要在命令行直接使用 Miniforge 的 `python`，有两种方式：
>
> - **方式 A**：先 `conda activate <env>`，随后直接运行 `python`
> - **方式 B**：编辑本仓库 `bucket/miniforge.json`，在 `bin` 中加入：
>
> ```json
> "Miniforge3\\python.exe"
> ```
>
> 保存后同步到本机 bucket 并重新安装 `miniforge`，Scoop 会创建 `python.exe` 的 shim（会改变默认 `python` 指向，请谨慎操作）。

## 🚀 使用

从 Bucket 安装应用：

```powershell
# 安装阿里云盘
scoop install gz4zzxc/aliyundrive

# 安装欧路词典
scoop install gz4zzxc/eudic

# 安装滴答清单
scoop install gz4zzxc/dida365

# 安装 NDI Tools（包含运行库/驱动，可能需要管理员权限）
scoop install gz4zzxc/ndi-tools

# 安装 PixPin（截图贴图）
scoop install gz4zzxc/pixpin
```

ndi-tools 使用官方完整安装器，不是纯便携包；如果系统中已有通过 Program Files 或 WinGet 安装的 NDI Tools，请先卸载旧版，否则 manifest 会主动中止安装以避免 Inno Setup 注册项冲突。

### 📌 PixPin 安装说明

PixPin 是免费截图/贴图/长截图/OCR 工具，本仓库使用官方 zip 便携版：

- **便携解包**：manifest 不运行传统安装程序，直接解包到 Scoop 应用目录
- **数据持久化**：`Config`、`Data`、`History` 目录通过 `persist` 保留，更新不丢配置
- **命令行**：安装后可用 `pixpin` 命令直接启动
- **更新**：`scoop update pixpin` 即可，失败时可先 `scoop cache rm pixpin` 再重试

### ☁️ AliyunDrive 安装说明

AliyunDrive 清单已特别配置以处理下载限制：

- **自动 User-Agent 处理**：清单自动使用正确的 User-Agent 头下载安装程序，避免 403 Forbidden 错误
- **备用下载方法**：如果主下载方法失败，会自动尝试替代方案
- **哈希复核**：自动更新工作流会重新计算真实安装包的 SHA256，避免同版本重新打包导致安装失败
- **进度反馈**：下载和安装期间提供清晰的进度指示和错误消息

### 📖 Eudic 安装说明

Eudic（欧路词典）清单提供全面的英语词典解决方案：

- **自动下载**：清单自动从官方网站下载最新安装程序
- **智能安装**：自动检测并运行下载的压缩包中的安装程序可执行文件
- **丰富功能**：支持真人发音、跨软件取词、文章批改、语法错误纠正等
- **多平台同步**：支持跨设备的云同步学习记录

### ✅ Dida365 (TickTick) 便携版说明

当前 `dida365` 清单使用 InnoSetup 安装包的解包模式（`"innosetup": true`），不直接执行安装程序：

- **无 UAC**：不写入 `Program Files`，全部文件解包到 Scoop 版本目录
- **32/64 位**：同时提供 `type=win` 与 `type=win64` 下载地址，Scoop 自动选择
- **纯便携**：不会创建系统卸载项；卸载只移除解包的程序文件
- **数据独立**：运行后上游仍可能在 `%APPDATA%` / `%LOCALAPPDATA%` 生成用户数据（暂未做 `persist`，可视需要添加）
- **自动版本探测**：`checkver.script` 通过下载安装包读取 `ProductVersion`
- **更新简单**：`scoop update dida365` 即可，失败时可先 `scoop cache rm dida365` 再重试

#### 安装命令

```powershell
scoop install gz4zzxc/dida365
```

#### 仍可评估的增强

- 持久化用户数据目录（需先确认具体文件夹名）
- 提供可选启动参数包装（番茄钟/调试等）

> ⚠️ 如应用启动失败，请列出目录并反馈 issue：
>
> ```powershell
> Get-ChildItem "$env:USERPROFILE\scoop\apps\dida365\current" | Select Name
> ```

## 🔄 自动更新

本 Bucket 使用 Scoop 原生的 checkver/autoupdate 来刷新清单和 README 版本表格：

- **调度时间**：每天 08:00 北京时间（00:00 UTC），以及手动触发
- **范围**：所有定义了 `checkver` 和 `autoupdate` 的应用
- **工作原理**：
  - 运行 `checkver * -u` 更新 `version`、`url` 和 `hash`
  - 对 AliyunDrive、Dida365 等特殊 CDN 清单额外复核真实安装包哈希
  - 更新 README 「可用应用」表格中的版本以匹配清单
  - 使用 `[skip ci]` 直接提交并推送到 `main` 分支以避免循环

> **注意**：
>
> - 工作流在 `windows-latest` 上运行，并临时安装 Scoop 以使用 `checkver.ps1`（遵循 Scoop 文档）
> - 如果上游没有新版本，运行将以「无更改」完成，不会创建 PR

## 🤝 贡献

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/new-app`)
3. 将清单文件添加到 `bucket/` 目录
4. 使用 `scoop install <path-to-manifest>` 测试清单
5. 提交更改 (`git commit -am 'Add new app'`)
6. 推送到分支 (`git push origin feature/new-app`)
7. 创建 Pull Request

## 📋 清单格式

详细清单文档请参阅 [Scoop Wiki](https://github.com/ScoopInstaller/Scoop/wiki/App-Manifests)。

## 📜 许可证

本 Bucket 采用 [Unlicense](https://unlicense.org/) 许可证。
