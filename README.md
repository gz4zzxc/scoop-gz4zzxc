# 🪣 scoop-gz4zzxc

[![Excavator](https://github.com/gz4zzxc/scoop-gz4zzxc/actions/workflows/excavator.yml/badge.svg)](https://github.com/gz4zzxc/scoop-gz4zzxc/actions/workflows/excavator.yml)

一个定制的 [Scoop](https://scoop.sh/) Bucket，提供「便携解包」版本的应用程序。

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
| lobehub | LobeChat 桌面客户端 | 1.143.2 |
| miniforge | Conda-forge 精简版（仅 conda） | 25.11.0-1 |
| aliyundrive | 阿里云盘官方客户端 | 6.9.1 |
| eudic | 欧路词典：英语词典软件 | 14.2.1.0 |
| dida365 | 滴答清单：待办/日历/番茄钟 | 6.4.2.0 |

### 🐍 Miniforge (conda-forge minimal installer)

本仓库的 `miniforge` 清单是为个人需求定制的版本，具备以下特性：

- **只暴露 `conda`，不暴露 `python`**
  - `bin` 仅导出 `Miniforge3\\condabin\\conda.bat`
  - 不会创建 `python.exe` 的 shim，避免覆盖系统或 UV 管理的 Python
- **安装到子目录 `Miniforge3`**
  - 安装路径：`~\\scoop\\apps\\miniforge\\<version>\\Miniforge3`
  - 安装脚本会在应用目录内清理旧的 `Miniforge3` 子目录，避免因目录非空而失败（不会触碰 `%USERPROFILE%\\.conda\\envs` 等用户环境目录）
- **启动提示与建议**
  - 安装完成后建议执行：`conda init` 初始化当前 Shell
  - 如果不想自动激活 base：`conda config --set auto_activate_base false`
  - 推荐设置通道优先级：`conda config --set channel_priority strict`

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
```

### ☁️ AliyunDrive 安装说明

AliyunDrive 清单已特别配置以处理下载限制：

- **自动 User-Agent 处理**：清单自动使用正确的 User-Agent 头下载安装程序，避免 403 Forbidden 错误
- **备用下载方法**：如果主下载方法失败，会自动尝试替代方案
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

#### 可能的后续增强（未实现）

- 持久化用户数据目录（需先确认具体文件夹名）
- 在 manifest 中启用 `hash.mode: download` 以减少手动维护
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
