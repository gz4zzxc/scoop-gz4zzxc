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
| 7zip | A multi-format file archiver with high compression ratios (Custom configuration) | 25.00 |
| aliyundrive | 阿里云盘是一款速度快、不打扰、够安全、易于分享的网盘，由阿里巴巴集团出品 | 6.8.7 |

## Usage

Install apps from this bucket:

```powershell
# Install 阿里云盘
scoop install gz4zzxc/aliyundrive

# Install 7-Zip (custom configuration)
scoop install gz4zzxc/7zip
```

### AliyunDrive Installation Notes

The AliyunDrive manifest has been specially configured to handle download restrictions:

- **Automatic User-Agent Handling**: The manifest automatically downloads the installer with proper User-Agent headers to avoid 403 Forbidden errors
- **Fallback Download Method**: If the primary download method fails, it automatically tries an alternative approach
- **Progress Feedback**: Clear progress indicators and error messages during download and installation

If you encounter any download issues, the manifest includes comprehensive error handling and will attempt multiple download methods automatically.

## Auto-Update

This bucket includes an automated update system that checks for new versions daily:

- **Schedule**: Every day at 8:00 AM Beijing Time
- **Target**: AliyunDrive client updates
- **Actions**: Automatically updates manifest files and creates releases

See [docs/auto-update-workflow.md](docs/auto-update-workflow.md) for detailed information.

## Scripts

- `scripts/validate-manifests.py` - Validate all manifest files

## Contributing

1. Fork this repository
2. Create your feature branch (`git checkout -b feature/new-app`)
3. Add your manifest file to the `bucket/` directory
4. Test your manifest using `python3 scripts/validate-manifests.py`
5. Commit your changes (`git commit -am 'Add new app'`)
6. Push to the branch (`git push origin feature/new-app`)
7. Create a Pull Request

## Manifest Format

See [Scoop Wiki](https://github.com/ScoopInstaller/Scoop/wiki/App-Manifests) for detailed manifest documentation.

## License

This bucket is licensed under the [Unlicense](https://unlicense.org/).
