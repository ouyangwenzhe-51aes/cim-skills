# Changelog

## 1.1.0 - 2026-06-17

### Changed

- Reworked the repository into the APM plugin layout: root `plugin.json`, `.claude-plugin/`, `.cursor-plugin/`, and `skills/<name>/SKILL.md`.
- Added Cursor plugin metadata so the same `skills/` directory can be consumed from Cursor-compatible harnesses.
- Added `apm.yml` as the marketplace authoring source for release packaging.
- Synced all skill frontmatter to version `1.1.0` with `valid_until: "2026-12-17"`.

### Release

- Pinned install: `apm install ouyangwenzhe-51aes/cim-skills#v1.1.0`
- Floating install: `apm install ouyangwenzhe-51aes/cim-skills`

## 1.0.0 - 2026-06-17

### Added

- Initial CIM API skills collection with 22 skills across initialization, internet map, spatial analysis, and hospital scene capabilities.
