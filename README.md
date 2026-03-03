# NAV_Plugin_nav-visual-testing

Visual testing protocol plugin for Claude Code. Enforces Chrome screenshot verification, DevTools console checks, CRUD operation testing, API endpoint verification, and an autonomous fix-loop for every web feature.

## What It Does

Every web feature must be visually verified in Chrome before it can be marked complete. Code that compiles is not code that works. A page that renders is not a page that renders correctly.

This plugin provides:

- **5 testing modes** covering new features, CRUD operations, API endpoints, bug fixes, and regression checks
- **Autonomous fix-loop** that retests until passing, then archives evidence
- **3 verification scripts** for initialization, phase gate checks, and summary reports
- **Templates and examples** for consistent test documentation

## Five Modes

| Mode | When | Test Slug Pattern |
|---|---|---|
| **Build & Test** | You just built a feature | `{feature-name}` |
| **CRUD Verification** | Feature creates/reads/updates/deletes data | `{entity}-create`, `-read`, `-update`, `-delete` |
| **API Testing** | Feature calls backend endpoints | `api-{method}-{resource}` |
| **Targeted Bug Fix** | User reports a bug | `bugfix-{description}` |
| **Regression Re-Test** | Recent changes might break things | Same slug, moved back from .completed/ |

## The Core Loop

```
IMPLEMENT -> NAVIGATE -> INTERACT -> SCREENSHOT -> ANALYZE -> DEVTOOLS CHECK
  ^                                                              |
  |                                        PASS? -> .completed/ -> next item
  |                                        FAIL? -> fix code ----+
  +--------------------------------------------------------------+
```

## Prerequisites

One of these Chrome automation tools:

- [superpowers-chrome](https://github.com/anthropics/skills) (recommended)
- [Playwright MCP](https://github.com/microsoft/playwright-mcp)
- Any Chrome automation that can take screenshots and read console output

## Quick Start

```bash
# Initialize test directories in your project
bash skills/visual-testing/scripts/init.sh /path/to/project

# Copy the CLAUDE.md snippet into your project
cat skills/visual-testing/CLAUDE-MD-SNIPPET.md >> /path/to/project/CLAUDE.md
```

## Plugin Structure

```
NAV_Plugin_nav-visual-testing/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── visual-testing/
│       ├── SKILL.md                    # Main protocol (650 lines)
│       ├── CLAUDE-MD-SNIPPET.md        # Ready to paste into project CLAUDE.md
│       ├── references/
│       │   ├── analysis-template.md    # Template for {slug}.md files
│       │   ├── console-template.md     # Template for {slug}-dev-console.md
│       │   └── troubleshooting.md      # 9 common failure modes + fixes
│       ├── scripts/
│       │   ├── init.sh                 # Initialize .tests/ directories
│       │   ├── verify.sh               # Phase gate verification
│       │   └── report.sh               # Test summary report
│       └── examples/
│           ├── example-pass/           # Passing feature test
│           ├── example-fail/           # Test with 3 fix iterations
│           ├── example-bugfix/         # Bug fix with regression check
│           ├── example-crud/           # CRUD create test
│           └── example-api/            # API endpoint test
├── README.md
└── .gitignore
```

## Key Rules

1. **3 files per test** — `screenshot.png` + `{slug}.md` + `{slug}-dev-console.md`
2. **CRUD features get 4 tests** — one per operation (create, read, update, delete)
3. **API endpoints tested before UI** — verify the backend before the frontend
4. **Never stop between tests** — complete the entire task autonomously
5. **Never use sleep** — use wait-for/wait-text/DOM polling
6. **Fix loop until PASS** — fix code, replace screenshot, update analysis, repeat

## License

MIT
