# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of UBNT Monitor
- Dual mode support: Cloud API and Local LAN
- Device list and detail views
- Device management (restart, PoE power cycle)
- Client list view
- Secure Keychain storage for credentials
- Certificate pinning for LAN mode
- Biometric/Passcode protection option

### Security
- Implemented certificate pinning for local connections
- Added private IP validation (prevents SSRF)
- Secure Keychain storage with accessibility controls
- Removed sensitive data from logs

## [1.0.0] - 2026-03-08

### Added
- First public release
- Cloud mode: Connect via Ubiquiti API
- Local mode: Direct router connection
- Device monitoring (status, firmware, IP)
- Port and radio information display
- Site management and switching

---

## Release Template

When creating a new release, use this template:

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- New features

### Changed
- Changes in existing functionality

### Deprecated
- Soon-to-be removed features

### Removed
- Now removed features

### Fixed
- Bug fixes

### Security
- Security improvements
```

---

## Version Numbering

This project follows [Semantic Versioning](https://semver.org/):

- **MAJOR** version for incompatible API changes
- **MINOR** version for backwards-compatible functionality additions
- **PATCH** version for backwards-compatible bug fixes
