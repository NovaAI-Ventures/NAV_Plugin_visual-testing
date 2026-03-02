#!/usr/bin/env bash
set -euo pipefail

# Visual Testing Protocol — Initialization Script
# Usage: bash scripts/init.sh [project-root]
#
# Creates .tests/.completed/ directory structure and verifies prerequisites.

show_help() {
  echo "Usage: bash scripts/init.sh [project-root]"
  echo ""
  echo "Initialize visual testing in a project."
  echo ""
  echo "Arguments:"
  echo "  project-root   Path to the project root (default: current directory)"
  echo ""
  echo "What it does:"
  echo "  1. Creates .tests/ and .tests/.completed/ directories"
  echo "  2. Checks for Chrome automation tools"
  echo "  3. Adds .tests/ to .gitignore (optional)"
  echo ""
  echo "Examples:"
  echo "  bash scripts/init.sh"
  echo "  bash scripts/init.sh /path/to/my-project"
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  show_help
  exit 0
fi

PROJECT_ROOT="${1:-.}"
TESTS_DIR="$PROJECT_ROOT/.tests"
COMPLETED_DIR="$TESTS_DIR/.completed"

echo "=== Visual Testing Protocol — Init ==="
echo ""

# Create directories
if [[ -d "$COMPLETED_DIR" ]]; then
  echo "✓ .tests/.completed/ already exists"
else
  mkdir -p "$COMPLETED_DIR"
  echo "✓ Created .tests/.completed/"
fi

# Check for Chrome tools
echo ""
echo "Checking Chrome automation tools..."

TOOL_FOUND=false

# Check superpowers-chrome
if command -v chrome-ws &>/dev/null || [[ -f "./chrome-ws" ]]; then
  echo "✓ superpowers-chrome detected"
  TOOL_FOUND=true
fi

# Check Playwright
if command -v playwright &>/dev/null || python3 -c "import playwright" 2>/dev/null; then
  echo "✓ Playwright detected"
  TOOL_FOUND=true
fi

# Check if running in Claude Code with MCP
if [[ -n "${CLAUDE_CODE:-}" ]] || [[ -f ".claude" ]] || [[ -f ".claude.json" ]]; then
  echo "✓ Claude Code environment detected (MCP tools available)"
  TOOL_FOUND=true
fi

if [[ "$TOOL_FOUND" == false ]]; then
  echo "⚠ No Chrome automation tool detected."
  echo "  Install one of:"
  echo "  - superpowers-chrome: https://github.com/anthropics/skills → webapp-testing"
  echo "  - Playwright MCP: https://github.com/microsoft/playwright-mcp"
  echo "  - Or use any Chrome automation that can screenshot + read console"
  echo ""
  echo "  The protocol is tool-agnostic — it will work with whatever is available."
fi

# Check .gitignore
echo ""
if [[ -f "$PROJECT_ROOT/.gitignore" ]]; then
  if grep -q "\.tests/" "$PROJECT_ROOT/.gitignore" 2>/dev/null; then
    echo "✓ .tests/ already in .gitignore"
  else
    echo "ℹ .tests/ not in .gitignore"
    echo "  To exclude test evidence from git: echo '.tests/' >> .gitignore"
    echo "  To keep evidence in git (recommended for teams): leave .gitignore as-is"
  fi
else
  echo "ℹ No .gitignore found"
fi

# Summary
echo ""
echo "=== Setup Complete ==="
echo ""
echo "Directory structure:"
echo "  $TESTS_DIR/              ← Active tests (in progress or failing)"
echo "  $COMPLETED_DIR/   ← Verified tests (passing evidence)"
echo ""
echo "Next steps:"
echo "  1. Ensure SKILL.md is in your project (or referenced in CLAUDE.md)"
echo "  2. Start implementing features"
echo "  3. After each feature, run the visual testing loop"
echo "  4. Before declaring a phase complete, run: bash scripts/verify.sh"
