# AGENTS.md

> Machine-readable capability manifest for AI agents and orchestrators.
> Deploy this file to the root of any public repository to make its capabilities discoverable.

## System

**Name:** CIM Skills Arsenal
**Author:** CIM API Development Team
**Description:** 22 CIM API skills encoding 3D scene management, spatial analysis, POI operations, and navigation capabilities as loadable context for AI agents. Each skill documents API methods, parameters, use cases, and best practices — production-ready API documentation.
**Status:** All 22 skills production-ready and tested against CIM API v1.4.0.
**Compliance:** All 22 skills include complete API documentation with input/output specifications, error handling, and code examples. Latest audit: 2026-06-23.

## Skills

| Skill | Domain | Capabilities | Lines |
|-------|--------|-----------|-------|
| initialization | Foundation | SDK install, plugin initialization, version query, get/delete operations | 200 |
| box | Hospital | Room color blocks (geojson), color control, highlight, visibility, focus | 150 |
| device | Hospital | Attached device templates, management, deletion, listing | 200 |
| elevator | Hospital | Elevator creation, styling, animation, visibility, highlight, events | 180 |
| keycommon | Internet Map | Configure Amap (高德地图) API key | 80 |
| bycircle | POI Search | Search POI by circle radius, filter, custom style | 150 |
| bypolygon | POI Search | Search POI by polygon, filter, custom style | 150 |
| byscreen | POI Search | Search POI by screen viewport, filter, custom style | 150 |
| bytext | POI Search | Search POI by text keyword, filter, custom style | 150 |
| poi-get | POI Management | Get searched POI, filter, update, delete, focus | 150 |
| poi-reset | POI Management | Clear searched POI by category or all | 80 |
| search-path | Navigation | Create navigation path, custom style, delete | 150 |
| select-path | Navigation | Select from multiple Amap navigation routes | 100 |
| get-path | Navigation | Get added path, visibility, update, delete, focus | 150 |
| lifecircle | Life Circle | N-minute reachable range by travel mode/time | 150 |
| contour | Analysis | Terrain contour analysis, contour line/surface styling | 150 |
| dig-terrain | Analysis | Earthwork fill/cut analysis, depth configuration | 150 |
| height-limit | Analysis | Height restriction detection, threshold configuration | 150 |
| intervisible | Analysis | Intervisibility analysis, line-of-sight detection | 150 |
| openness | Analysis | Openness evaluation, sector visibility analysis | 150 |
| skyline | Analysis | Skyline analysis, building contour styling, screenshot | 150 |
| sunlight | Analysis | Solar radiation analysis, daylight assessment, compliance | 200 |

## How to Use

**Claude Code Plugin (recommended):**
```
claude plugin marketplace add ouyangwenzhe-51aes/cim-skills
```
Claude Code model-activates skills by `description` field when they match the user's task.
```
Setup: [mcp/README.md](mcp/README.md). All 22 skills tested against CIM API v1.0.0.

**GitHub Copilot (via Agency marketplace):**
Skills are listed in the Agency marketplace. Install per the marketplace instructions.

**Direct (any LLM):**
Copy the relevant `SKILL.md` file and load as system context before your task. The YAML frontmatter contains `name`, `description`, and `metadata.tags` — read these first to decide whether the skill applies.

## Quality Evidence

- **API Compliance:** All 22 skills tested against CIM API v1.4.0 official documentation
- **Production Status:** Used in real 3D scene management and spatial analysis projects
- **Complete Coverage:** Spans initialization, scene management (hospital, rooms, devices, elevators), POI operations (search, get, reset), navigation (paths, routing), and spatial analysis (contour, terrain, height, intervisibility, openness, skyline, sunlight)
- **Comprehensive Documentation:** Each skill includes method signatures, parameters, return values, error handling, and code examples

## Input/Output Schemas

Each skill declares typed schemas in its SKILL.md YAML frontmatter:

- **`name`** — skill identifier (e.g., `initialization`, `box`, `contour`)
- **`description`** — machine-readable capability description with use case guidance
- **`metadata.version`** — API version (all at 1.0.0)
- **`metadata.tags`** — capability tags for routing (e.g., `[cimapi, analysis, contour, visualization]`)

Each skill documents:
- **API Methods:** Complete method signatures with parameters
- **Input Parameters:** Parameter types, required fields, acceptable values
- **Return Values:** Output structure and data types
- **Code Examples:** Practical implementation patterns
- **Error Handling:** Common errors and recovery strategies

This is the contract an orchestrator uses to route tasks. Each skill is self-contained and production-tested.

## Contributing

For issues, feature requests, or skill updates related to CIM API changes: open a GitHub issue with version details and affected skills.


## Example Invocation

**Input:**
```
Create a 3D scene with contour analysis visualization at coordinates [116.4, 39.9] with 10-meter contour intervals.
```

**Output:** Contour skill documentation + context → LLM generates complete implementation using App.ContourAnalysis with proper scene mounting, styling, and cleanup patterns.


## Links

- **Repository:** https://github.com/ouyangwenzhe-51aes/cim-skills
- **CIM API Documentation:** Official CIM API reference
- **MCP Setup:** mcp/README.md
