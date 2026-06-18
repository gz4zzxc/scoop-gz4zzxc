# AGENTS.md

Guidance for any AI coding agent working in this repository. This is the canonical source; tool-specific files (e.g. `CLAUDE.md`) point here.

## Project Overview

A custom [Scoop](https://scoop.sh/) bucket for specific Windows apps — focused on "clean" (portable/unpacked) versions that are hard to find or problematic in official buckets.

**Tech Stack**:
- **Manifests**: JSON
- **Scripts**: PowerShell (Core) 7+
- **Automation**: GitHub Actions (Windows Runner)

## Common Commands

### Testing Manifests (Windows + Scoop only)

```powershell
scoop install bucket\app-name.json          # install from local source
scoop uninstall app-name
scoop install bucket\app-name.json -g       # -g shows global script output (debugging)
```

### Validating JSON

```bash
# macOS/Linux (pre-commit)
python3 -c "import json; json.load(open('bucket/app-name.json'))"

# Windows (PowerShell)
Get-Content bucket\app-name.json -Raw | ConvertFrom-Json
```

### Validating checkver/autoupdate

```powershell
# Requires checkver.ps1 (bundled with Scoop, or download from upstream)
iwr -useb https://raw.githubusercontent.com/ScoopInstaller/Scoop/master/bin/checkver.ps1 -OutFile checkver.ps1

.\checkver.ps1 bucket\app-name.json       # test
.\checkver.ps1 bucket\app-name.json -u    # -u performs autoupdate
```

## Architecture

### Automated Update System

- **Workflow**: `.github/workflows/excavator.yml`
- **Schedule**: Daily at 08:00 Beijing Time (00:00 UTC)
- **Pipeline**:
  1. Validate all JSON manifests
  2. Install Scoop transiently on the Windows runner
  3. Run `checkver * -u` to update versions, URLs, hashes
  4. Re-validate hashes for stable-URL apps (catches upstream repacks — see dida365)
  5. Sync README.md version table via PowerShell regex
  6. Commit to `main` with `[skip ci]` to avoid workflow loops

### Manifest Patterns

#### 1. AliyunDrive (CDN anti-leech)

CDN blocks generic `User-Agent` headers with 403.

- **checkver**: MUST include `"useragent": "Mozilla/5.0..."`.
- **install**: `pre_install` downloads manually via `Invoke-WebRequest -UserAgent ...`
- **Workaround**: a dummy CDN URL (`.../LICENSE#/dl-bypass`) is used as placeholder since Scoop requires a valid `url` field

#### 2. Dida365 (checkver script + InnoSetup + hash re-validation)

Dida365 (TickTick China) exposes no stable version API and its CDN frequently repacks installers — same version, different binary hash.

- **checkver**: PowerShell `script` block downloads the exe and extracts `ProductVersion`
- **install**: `"innosetup": true` unpacks without running the installer (portable mode)
- **architecture**: provides both `type=win` and `type=win64` URLs for auto-selection
- **Hash drift mitigation**: the CI workflow downloads current installers and compares hashes against the manifest, updating even when the version number hasn't changed. This is required because `checkver -u` only fires on version changes.
- **Why not `release_note.json`**: `https://pull.dida365.com/windows/release_note.json` exists but reports a different version than the exe's `ProductVersion` (e.g. API `8.1.0.0` vs exe `8.1.0.1`), and the CDN filename pattern is unstable (`dida_win_setup` → `dida_wins_setup`), so `$cleanVersion` URL construction is unreliable.
- **Why not version-specific CDN URL**: the 302 redirect target includes a build number (e.g. `dida_wins_setup_release_x64_8101.exe`), but the pattern changes unpredictably and doesn't always match `$cleanVersion` derived from the API version.

#### 3. Eudic (nested archive extraction)

Distributes as a zip containing an NSIS installer.

- **checkver**: download zip, extract inner exe, read `ProductVersion`
- **install**: `Expand-7ZipArchive` (Scoop helper) extracts exe → app.7z → files
- **cleanup**: removes `uninst.exe.nsis` and `$PLUGINSDIR` after extraction

#### 4. Miniforge (custom shim for coexistence)

Designed to coexist with other Python managers (uv, system python).

- **Design**: only the `conda` shim is exposed via `bin: "Miniforge3\\condabin\\conda.bat"`
- **Safety**: explicitly avoids creating a `python.exe` shim to prevent conflicts
- **install**: NSIS installer with `/InstallationType=JustMe /AddToPath=0 /RegisterPython=0 /S`
- **cleanup**: `installer.script` removes the old `Miniforge3` subdir before install to avoid "directory not empty"

#### 5. LobeHub (standard NSIS installer)

Standard electron-builder NSIS setup.

- **install**: `installer.args: ["/S", "/D=$dir"]` for silent install to a custom directory
- **checkver**: queries GitHub Releases API for the latest tag

## Development Guidelines

1. **JSON format**
   - 4-space indentation
   - Double quotes for keys and string values
   - No trailing commas
   - Valid JSON required (workflow fails on invalid syntax)

2. **PowerShell compatibility**
   - Must run on PowerShell Core (pwsh) 7+ (GitHub Action environment)
   - Avoid Windows-specific aliases; use full cmdlet names
   - Use `-UseBasicParsing` with `Invoke-WebRequest` to avoid IE dependency

3. **Hash strategy**
   - Always SHA256
   - For `autoupdate`: **omit** the `hash` section entirely when upstream doesn't provide hash files (Scoop defaults to `mode: download` — downloads and computes locally)
   - Use `"hash": { "url": "..." }` only if upstream provides `.sha256` files
   - For apps with stable redirect URLs (like dida365): the CI workflow's dedicated hash re-validation step catches upstream repacks that `checkver -u` alone would miss

4. **No `Start-Sleep`**
   - Check for process termination or file locks instead
   - Use `Start-Process -Wait` for synchronous operations

5. **User-Agent handling**
   - If a CDN blocks generic UAs, add `"useragent": "Mozilla/5.0..."` to **both** `checkver` and `pre_install`
   - Consider a dummy URL workaround if the primary URL requires authentication/UA

6. **README version table**
   - The workflow auto-updates the version table in README.md
   - Format: `| App | Description | Version |`
   - App key must match the filename (without `.json`) for the regex to work
   - See `excavator.yml` (`$apps` array) for the app mapping

## Commit Conventions

- Prefix: `fix(bucket):`, `chore(bucket):`, `feat(bucket):`
- Auto-commits from CI use `[skip ci]` to avoid workflow loops
- Never push secrets

## Troubleshooting

### Workflow failures

```bash
gh run list --limit 5
gh run view <run-id>
```

### Manifest not updating in README

Ensure the app is in the `$apps` array in `excavator.yml`.

### checkver script failures

If `checkver` can't find the version:

1. Test the URL manually: `iwr -useb <url> -UserAgent "..."`
2. For script-based checkver: run the script blocks in pwsh to debug
3. Check regex patterns at <https://regex101.com/>

### Installation issues

```powershell
scoop install bucket\app.json -g   # enable global output for debugging
```
