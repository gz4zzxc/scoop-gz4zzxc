# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a custom Scoop bucket for gz4zzxc's applications, providing Windows package manifests for various software tools. The bucket includes both standard applications and customized installations with specific configurations.

## Common Commands

### Testing Manifests
```powershell
# Test a specific manifest installation
scoop install .\bucket\appname.json

# Test with current manifest (lobechat has comprehensive test script)
.\tests\test-lobechat-installer.ps1

# Test specific installer scenarios
.\tests\test-lobechat-installer.ps1 -MsiMock
.\tests\test-lobechat-installer.ps1 -PortableMock
```

### Development Workflow
```powershell
# Clean app cache before testing
scoop cache rm appname

# Uninstall app (purge)
scoop uninstall appname -p

# Install with keep flag (for testing)
scoop install appname -k

# Validate JSON syntax
python3 -m json.tool bucket/appname.json
```

## Architecture

### Bucket Structure
- `bucket/` - Contains JSON manifests for each application
- `tests/` - PowerShell test scripts for installer validation
- `.github/workflows/` - GitHub Actions for automated updates and validation

### Key Applications

**Miniforge (Custom Conda)**
- Customized version that only exposes `conda` (not `python`) to avoid system conflicts
- Installs to `Miniforge3` subdirectory within Scoop app directory
- Includes cleanup logic for previous installations
- Uses official conda-forge releases with auto-update

**AliyunDrive** 
- Special handling for download restrictions with User-Agent headers
- Fallback download mechanisms for reliability
- Placeholder URL structure with pre-install download logic

**LobeChat**
- Electron-based desktop application
- Custom installer test script supporting multiple scenarios (MSI, portable, setup.exe)
- Silent installation with `/S` flag
- Registry-based uninstall detection

**Traffic Monitor**
- Multi-architecture support (x64, x86, ARM64)
- Standard version with hardware monitoring
- Auto-updates via GitHub releases

### Auto-Update System
The bucket uses a hybrid approach:
- **Custom Python scripts** for AliyunDrive, Miniforge, and LobeChat (handles complex download logic)
- **Official Excavator** integration for standard GitHub releases (Traffic Monitor)
- **Daily schedule** at 8:00 AM Beijing Time
- **PR-based updates** with auto-merge for simple manifests

### Special Patterns

**Placeholder URL Pattern**
Used for apps with complex download logic (AliyunDrive):
```json
"url": "https://raw.githubusercontent.com/gz4zzxc/scoop-gz4zzxc/main/placeholder.txt#/aDrive-6.8.7.exe"
```
Actual download happens in `pre_install` script.

**Multi-Architecture Support**
Traffic Monitor pattern with separate URLs/hashes per architecture:
```json
"architecture": {
  "64bit": { "url": "...", "hash": "..." },
  "32bit": { "url": "...", "hash": "..." },
  "arm64": { "url": "...", "hash": "..." }
}
```

**Custom Installation Logic**
Complex installations use PowerShell scripts in `installer` section with:
- Progress indicators and error handling
- File extraction and cleanup
- Registry-based uninstall detection
- User feedback with colored output

## Testing Strategy

### LobeChat Test Script
The most comprehensive test covers:
- **Setup.exe branch** - Tests real upstream assets
- **MSI branch** - Mocks with known MSI installer
- **Portable branch** - Creates portable version with local HTTP server

### Validation Checks
- JSON syntax validation for all manifests
- Download URL accessibility verification
- Hash verification for downloaded assets
- Installation/uninstallation cycle testing
- Shim creation validation

## Important Notes

### Language Conventions
- All user-facing messages should be in Chinese with proper直角引号「」
- Comments and code should remain in English
- Error messages should be bilingual where appropriate

### Security Considerations
- All downloads use proper User-Agent headers
- Hash verification is mandatory for all packages
- Registry operations are handled with error boundaries
- Temporary files are properly cleaned up

### Version Management
- Version checking uses multiple fallback methods
- Auto-update URLs are carefully constructed
- README version table is updated automatically
- PR descriptions include detailed version change information