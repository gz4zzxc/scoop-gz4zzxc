# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Project Overview

This is a custom [Scoop](https://scoop.sh/) bucket for managing specific Windows applications. It focuses on providing "clean" (portable/unpacked) versions of apps that are often hard to find or problematic in official buckets.

**Tech Stack**:

- **Manifests**: JSON
- **Scripts**: PowerShell (Core) 7+
- **Automation**: GitHub Actions (Windows Runner)

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

### Validating JSON

```bash
# On macOS/Linux (pre-commit check)
python3 -c "import json; json.load(open('bucket/app-name.json'))"

# On Windows (PowerShell)
Get-Content bucket\app-name.json -Raw | ConvertFrom-Json
```

### Validating checkver/autoupdate

```powershell
# Requires checkver.ps1 (included with Scoop or available from GitHub)
# Download checkver.ps1 if not available:
# iwr -useb https://raw.githubusercontent.com/ScoopInstaller/Scoop/master/bin/checkver.ps1 -OutFile checkver.ps1

# Test specific manifest
.\checkver.ps1 bucket\app-name.json

# Test and update (-u performs autoupdate)
.\checkver.ps1 bucket\app-name.json -u
```

## Architecture

### Automated Update System

- **Workflow**: `.github/workflows/excavator.yml`
- **Schedule**: Daily at 08:00 Beijing Time (00:00 UTC)
- **Mechanism**:
  1. Validates all JSON manifests
  2. Installs Scoop transiently on Windows runner
  3. Runs `checkver * -u` to update versions, URLs, and hashes
  4. Updates README.md version table via PowerShell regex
  5. Commits directly to `main` with `[skip ci]` to avoid workflow loops

### Manifest Patterns

#### 1. AliyunDrive (CDNs with Anti-Leech)

AliyunDrive's CDN blocks generic User-Agents.

- **Root Cause**: CDN checks `User-Agent` header, returns 403 for default requests
- **checkver Fix**: `checkver` block MUST include `"useragent": "Mozilla/5.0..."`.
- **Installation Fix**: `pre_install` manually downloads using `Invoke-WebRequest -UserAgent ...`
- **Workaround**: Uses a dummy CDN URL (`.../LICENSE#/dl-bypass`) as placeholder since Scoop requires a valid `url` field

#### 2. Dida365 (Checkver Script + InnoSetup + Hash Re-validation)

Dida365 (TickTick China) doesn't expose version via a stable API, and its CDN frequently repacks installers (same version, different hash).

- **checkver**: Uses PowerShell `script` block to download exe and extract `ProductVersion`
- **Installation**: `"innosetup": true` unpacks without running installer (Portable Mode)
- **Architecture**: Provides both `type=win` and `type=win64` URLs for auto-selection
- **Hash drift mitigation**: The CI workflow includes a "Re-validate hashes" step that downloads current installers and compares hashes against the manifest, updating even when the version number hasn't changed. This catches upstream repacks that `checkver -u` alone would miss (it only triggers on version changes).
- **Why not `release_note.json` API**: `https://pull.dida365.com/windows/release_note.json` exists but reports a different version than the exe's `ProductVersion` (e.g., API says `8.1.0.0` while exe says `8.1.0.1`), and the CDN filename pattern is unstable (`dida_win_setup` → `dida_wins_setup`), making `$cleanVersion` URL construction unreliable.
- **Why not CDN version-specific URL**: The CDN 302 redirect target includes a build number (e.g., `dida_wins_setup_release_x64_8101.exe`), but the naming pattern changes unpredictably and the build number doesn't always match `$cleanVersion` derived from the API version.

#### 3. Eudic (Nested Archive Extraction)

Eudic distributes as a zip containing an NSIS installer.

- **checkver**: Downloads zip, extracts inner exe, reads `ProductVersion` from version info
- **Installation**: Uses `Expand-7ZipArchive` (Scoop helper) to extract exe → app.7z → files
- **Cleanup**: Removes `uninst.exe.nsis` and `$PLUGINSDIR` after extraction

#### 4. Miniforge (Custom Shim for Coexistence)

Designed to coexist with other Python managers (uv, system python).

- **Design**: Only exposes `conda` shim via `bin: "Miniforge3\\condabin\\conda.bat"`
- **Safety**: Explicitly avoids creating `python.exe` shim to prevent conflicts
- **Installation**: Uses NSIS installer with `/InstallationType=JustMe /AddToPath=0 /RegisterPython=0 /S`
- **Cleanup**: `installer.script` removes old `Miniforge3` subdir before install to avoid "directory not empty" failures

#### 5. LobeHub (Standard NSIS Installer)

Standard electron-builder NSIS setup.

- **Installation**: Uses `installer.args: ["/S", "/D=$dir"]` for silent install to custom directory
- **checkver**: Queries GitHub Releases API for latest tag

## Development Guidelines

1. **JSON Format**:
   - Use 4-space indentation
   - Double quotes for keys and string values
   - No trailing commas
   - Valid JSON required (workflow will fail on invalid syntax)

2. **PowerShell Compatibility**:
   - Scripts must run on PowerShell Core (pwsh) 7+ (GitHub Action environment)
   - Avoid Windows-specific aliases; use full cmdlet names
   - Use `-UseBasicParsing` with `Invoke-WebRequest` to avoid IE dependency

3. **Hash Strategy**:
   - Always use SHA256
   - For `autoupdate`: omit `hash` section entirely when upstream doesn't provide hash files (Scoop defaults to `mode: download` — downloads and computes locally)
   - Use `"hash": { "url": "..." }` only if upstream provides .sha256 files
   - For apps with stable redirect URLs (like dida365): the CI workflow includes a dedicated hash re-validation step to catch upstream repacks that `checkver -u` alone would miss

4. **No Sleep Calls**:
   - Avoid `Start-Sleep`; check for process termination or file locks instead
   - Use `Start-Process -Wait` for synchronous operations

5. **User-Agent Handling**:
   - If CDN blocks generic UAs, add `"useragent": "Mozilla/5.0..."` to both `checkver` and `pre_install`
   - Consider using a dummy URL workaround if primary URL requires authentication/UA

6. **Updating README Table**:
   - The workflow auto-updates the version table in README.md
   - Format: `| App | Description | Version |`
   - App key must match the filename (without .json) for regex to work
   - See `excavator.yml` lines 98-104 for the app mapping

## Troubleshooting

### Workflow Failures

Check recent runs:

```bash
gh run list --limit 5
gh run view <run-id>
```

### Manifest Not Updating in README

Ensure the app is added to the `$apps` array in `excavator.yml` (lines 98-104).

### checkver Script Failures

If `checkver` can't find version:

1. Test URL manually: `iwr -useb <url> -UserAgent "..."`
2. For script-based checkver: Run script blocks in pwsh to debug
3. Check regex patterns at <https://regex101.com/>

### Installation Issues

Enable global output for debugging:

```powershell
scoop install bucket\app.json -g
```
