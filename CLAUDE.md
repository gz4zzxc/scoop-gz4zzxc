# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a custom Scoop bucket for managing Windows applications through the Scoop package manager. The repository contains JSON manifests for various Chinese and international applications with automated update capabilities.

## Common Commands

### Testing Manifests
```bash
# Validate JSON syntax of all manifests
python3 -m json.tool bucket/*.json

# Test installation of a specific app (requires Scoop on Windows)
scoop install bucket/app-name.json

# Check manifest syntax using Scoop's built-in validation
scoop checkver bucket/app-name.json
```

### Running Updates
```bash
# The automated update system runs via GitHub Actions daily
# Manual testing of update logic:
python3 .github/workflows/excavator.yml  # Run update checks locally
```

### Adding New Applications
1. Create manifest file in `bucket/` directory following Scoop JSON schema
2. Include required fields: `version`, `description`, `homepage`, `architecture`, `bin`
3. Add `checkver` and `autoupdate` configurations for automatic updates
4. Test the manifest with `scoop install` before submitting PR

## Architecture

### Automated Update System
The project features a sophisticated automated update system (`.github/workflows/excavator.yml`) that:

- **Runs daily** at 8:00 AM Beijing Time
- **Handles complex download scenarios** with custom User-Agent headers and fallback mechanisms
- **Supports multiple update strategies**:
  - GitHub API releases (LobeChat, Miniforge)
  - Web scraping with regex extraction (AliyunDrive, Dida365)
  - CDN URL verification and fallback testing

### Manifest Structure
All manifests follow the modern Scoop architecture format:

```json
{
  "version": "x.y.z",
  "architecture": {
    "64bit": {
      "url": "...",
      "hash": "..."
    }
  },
  "autoupdate": {
    "architecture": {
      "64bit": {
        "url": "..."
      }
    }
  }
}
```

### Special Handling by Application

**AliyunDrive**: 
- Requires custom User-Agent headers to bypass CDN restrictions
- Implements multi-step fallback download verification
- URL pattern: `https://cdn.aliyundrive.net/downloads/apps/desktop/aDrive-{version}.exe`

**Miniforge**:
- Custom conda-only installation (excludes python.exe shim)
- Installs to `Miniforge3` subdirectory
- GitHub API-based version checking with SHA256 verification

**Dida365**:
- Converts version numbers between semantic format (6.3.5.0) and numeric format (6350)
- Handles UAC prompts during installation with NSIS silent install
- CDN URL pattern: `https://cdn.dida365.cn/download/win64/dida_win_setup_release_x64_{version}.exe`

**LobeChat**:
- Uses GitHub releases with complex asset name patterns
- Falls back to parsing `latest.yml` when exact asset names change
- Electron-builder NSIS installer with silent install support

## Development Notes

### Manifest Validation
- All manifests must pass JSON syntax validation
- SHA256 hashes are required for security integrity
- URLs must be accessible and return correct installers
- `architecture.64bit` structure is preferred over root-level fields

### Update Logic Patterns
- **GitHub Releases**: Use `github: user/repo` in checkver
- **Web Scraping**: Implement fallback mechanisms for CDN restrictions
- **Version Conversion**: Handle semantic vs. custom version formats
- **Download Verification**: Always verify URLs exist before updating manifests

### Testing Guidelines
- Test installations on Windows systems with Scoop installed
- Verify updates work by running the automated update logic
- Check that shortcuts and bin entries work correctly
- Ensure uninstallation removes all components cleanly

### Error Handling
The automated system includes comprehensive error handling:
- Fallback download methods when primary fails
- Version number extraction from multiple sources
- URL accessibility verification before committing changes
- Graceful handling of missing or malformed assets