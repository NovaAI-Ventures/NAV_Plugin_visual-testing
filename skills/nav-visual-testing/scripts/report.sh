#!/usr/bin/env bash
set -euo pipefail

# Visual Testing Protocol — Summary Report
# Usage: bash scripts/report.sh [project-root]
#
# Generates a summary of all visual tests (active + completed).

show_help() {
  echo "Usage: bash scripts/report.sh [project-root]"
  echo ""
  echo "Generate a summary report of all visual tests."
  echo ""
  echo "Shows:"
  echo "  - Count of active (in-progress/failing) tests"
  echo "  - Count of completed (passing) tests"
  echo "  - Details for each test"
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  show_help
  exit 0
fi

PROJECT_ROOT="${1:-.}"
TESTS_DIR="$PROJECT_ROOT/.tests"
COMPLETED_DIR="$TESTS_DIR/.completed"

echo "=== Visual Testing — Summary Report ==="
echo "Generated: $(date -u '+%Y-%m-%d %H:%M UTC')"
echo ""

# Active tests
echo "── Active Tests (in progress / failing) ──"
if [[ -d "$TESTS_DIR" ]]; then
  ACTIVE=$(find "$TESTS_DIR" -maxdepth 1 -mindepth 1 -type d ! -name ".completed" 2>/dev/null || true)
  if [[ -z "$ACTIVE" ]]; then
    echo "  (none)"
  else
    while IFS= read -r dir; do
      slug=$(basename "$dir")
      files=$(find "$dir" -maxdepth 1 -type f | wc -l | tr -d ' ')
      verdict="unknown"
      if [[ -f "$dir/$slug.md" ]]; then
        if grep -qi "Verdict:.*FAIL" "$dir/$slug.md" 2>/dev/null; then
          verdict="FAIL"
        elif grep -qi "Verdict:.*PASS" "$dir/$slug.md" 2>/dev/null; then
          verdict="PASS (not yet moved)"
        fi
      fi
      echo "  🔄 $slug — $files file(s), verdict: $verdict"
    done <<< "$ACTIVE"
  fi
else
  echo "  (no .tests/ directory)"
fi

# Completed tests
echo ""
echo "── Completed Tests (passing) ──"
if [[ -d "$COMPLETED_DIR" ]]; then
  COMPLETED=$(find "$COMPLETED_DIR" -maxdepth 1 -mindepth 1 -type d 2>/dev/null || true)
  if [[ -z "$COMPLETED" ]]; then
    echo "  (none)"
  else
    while IFS= read -r dir; do
      slug=$(basename "$dir")
      files=$(find "$dir" -maxdepth 1 -type f | wc -l | tr -d ' ')
      echo "  ✅ $slug — $files file(s)"
    done <<< "$COMPLETED"
  fi
else
  echo "  (no .tests/.completed/ directory)"
fi

# Counts
echo ""
echo "── Summary ──"
ACTIVE_COUNT=0
COMPLETED_COUNT=0
[[ -d "$TESTS_DIR" ]] && ACTIVE_COUNT=$(find "$TESTS_DIR" -maxdepth 1 -mindepth 1 -type d ! -name ".completed" 2>/dev/null | wc -l | tr -d ' ')
[[ -d "$COMPLETED_DIR" ]] && COMPLETED_COUNT=$(find "$COMPLETED_DIR" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
TOTAL=$((ACTIVE_COUNT + COMPLETED_COUNT))

echo "  Active:    $ACTIVE_COUNT"
echo "  Completed: $COMPLETED_COUNT"
echo "  Total:     $TOTAL"

if [[ $ACTIVE_COUNT -eq 0 && $COMPLETED_COUNT -gt 0 ]]; then
  echo ""
  echo "  ✓ All tests passing. Phase gate clear."
elif [[ $ACTIVE_COUNT -gt 0 ]]; then
  echo ""
  echo "  ⚠ $ACTIVE_COUNT test(s) still active. Fix loop needed."
fi
