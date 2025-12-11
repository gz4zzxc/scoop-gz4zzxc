# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Project Overview

This is a custom [Scoop](https://scoop.sh/) bucket for managing specific Windows applications. It focuses on providing "clean" (portable/unpacked) versions of apps that are often hard to find or problematic in official buckets.

**Tech Stack**:
-   **Manifests**: JSON
-   **Scripts**: PowerShell (Core) 7+
-   **Automation**: GitHub Actions (Windows Runner)

## Common Commands

### Testing Manifests

Only possible on Windows with Scoop installed.

```powershell
# Install/Reinstall a specific app from local source
scoop install bucket\app-name.json

# Uninstall
scoop uninstall app-name

# Debugging installation scripts
scoop install bucket\app-name.json -g # -g shows global script output
```

### Validating Changes

```powershell
# Use Scoop's native checkver to verify regex and autoupdate logic
# (Requires checkver.ps1 in path or via scoop-search)
./bin/checkver.ps1 bucket/app-name.json -u
```

## Architecture

### Automated Update System
-   **Workflow**: `.github/workflows/excavator.yml`
-   **Mechanism**: Runs `checkver * -u` on a daily schedule using Scoop's native infrastructure.
-   **Logic**:
    1.  Downloads latest version information (via API, Regex, or Script).
    2.  Updates `version`, `hash`, and `autoupdate` fields in manifests.
    3.  Updates the `README.md` version table.
    4.  Commits changes back to `main`.

### Manifest Patterns

#### 1. AliyunDrive (CDNs with Anti-Leech)
AliyunDrive's CDN blocks generic User-Agents.
-   **Fix**: `checkver` block MUST include `"useragent": "Mozilla/5.0..."`.
-   **Installation**: `pre_install` script manually downloads the installer using `Invoke-WebRequest -UserAgent ...` to bypass 403 errors.

#### 2. Dida365 (Checkver Script)
Dida365 (TickTick China) doesn't have a simple version API.
-   **Checkver**: Uses a PowerShell block (`script`) to download the executable header and read `ProductVersion`.
-   **Installation**: Uses `"innosetup": true` to unpack the installer without running it (Portable Mode).

#### 3. Miniforge (Custom Shim)
Designed to coexist with other Python managers (uv, system python).
-   **Design**: Only exposes `conda` shim.
-   **Safety**: Explicitly avoids creating `python.exe` shim (`bin` field is restricted to `conda.bat`).

## Development Guidelines

1.  **JSON Format**: Keep standard Scoop formatting (4 space indent).
2.  **PowerShell Compatibility**: Scripts should run on PowerShell Core (pwsh) as that's what the GitHub Action uses.
3.  **Hash**: Always use SHA256. For autoupdate, prefer `hash.mode: download` if the vendor doesn't provide a hash file.
4.  **No "Sleep"**: Avoid using `Start-Sleep` in install scripts; check for process termination or file locks instead.