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
| example-app | An example application | 1.0.0 |

## Usage

Install apps from this bucket:

```powershell
scoop install gz4zzxc/<app-name>
```

## Contributing

1. Fork this repository
2. Create your feature branch (`git checkout -b feature/new-app`)
3. Add your manifest file to the `bucket/` directory
4. Test your manifest locally
5. Commit your changes (`git commit -am 'Add new app'`)
6. Push to the branch (`git push origin feature/new-app`)
7. Create a Pull Request

## Manifest Format

See [Scoop Wiki](https://github.com/ScoopInstaller/Scoop/wiki/App-Manifests) for detailed manifest documentation.

## License

This bucket is licensed under the [Unlicense](https://unlicense.org/).
