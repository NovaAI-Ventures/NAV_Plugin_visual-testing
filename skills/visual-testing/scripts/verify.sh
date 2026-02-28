#!/usr/bin/env bash
set -euo pipefail

# Visual Testing Protocol — Phase Gate Verification
# Usage: bash scripts/verify.sh [project-root]
#
# Checks that all visual tests pass the phase gate requirements.
# Run this before declaring any phase complete.

show_help() {
  echo "Usage: bash scripts/verify.sh [project-root]"
  echo ""
  echo "Verify all visual tests pass phase gate requirements."
  echo ""
  echo "Checks:"
  echo "  1. No empty folders in .tests/ or .tests/.completed/"
  echo "  2. Every test folder has exactly 3 files"
  echo "  3. No active tests remaining in .tests/ (all moved to .completed/)"
  echo "  4. All analysis files show Verdict: PASS"
  echo "  5. All console files show Verdict: CLEAN"
  echo ""
  echo "Exit codes:"
  echo "  0 = All checks passed (phase gate OK)"
  echo "  1 = One or more checks failed (phase gate BLOCKED)"
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  show_help
  exit 0
fi

PROJECT_ROOT="${1:-.}"
TESTS_DIR="$PROJECT_ROOT/.tests"
COMPLETED_DIR="$TESTS_DIR/.completed"
ERRORS=0

echo "=== Visual Testing — Phase Gate Verification ==="
echo ""

# Check .tests/ directory exists
if [[ ! -d "$TESTS_DIR" ]]; then
  echo "✗ FAIL: .tests/ directory does not exist"
  echo "  Run: bash scripts/init.sh"
  exit 1
fi

# Check 1: No empty folders
echo "Check 1: No empty folders"
EMPTY_DIRS=$(find "$TESTS_DIR" -type d -empty 2>/dev/null | grep -v "^$COMPLETED_DIR$" || true)
if [[ -z "$EMPTY_DIRS" ]]; then
  echo "  ✓ No empty folders found"
else
  echo "  ✗ FAIL: Empty folders found:"
  echo "$EMPTY_DIRS" | while read -r dir; do
    echo "    - $dir"
  done
  echo "  Fix: Create the 3 required files or delete the empty folder"
  ERRORS=$((ERRORS + 1))
fi

# Check 2: No active tests remaining (all should be in .completed/)
echo ""
echo "Check 2: No active tests remaining in .tests/"
ACTIVE_TESTS=$(find "$TESTS_DIR" -maxdepth 1 -mindepth 1 -type d ! -name ".completed" 2>/dev/null || true)
if [[ -z "$ACTIVE_TESTS" ]]; then
  echo "  ✓ No active tests — all moved to .completed/"
else
  ACTIVE_COUNT=$(echo "$ACTIVE_TESTS" | wc -l | tr -d ' ')
  echo "  ✗ FAIL: $ACTIVE_COUNT active test(s) still in .tests/:"
  echo "$ACTIVE_TESTS" | while read -r dir; do
    echo "    - $(basename "$dir")"
  done
  echo "  Fix: Complete the fix loop for each, then move to .completed/"
  ERRORS=$((ERRORS + 1))
fi

# Check 3: Every completed test has exactly 3 files
echo ""
echo "Check 3: Every completed test has 3 files"
if [[ -d "$COMPLETED_DIR" ]]; then
  COMPLETED_TESTS=$(find "$COMPLETED_DIR" -maxdepth 1 -mindepth 1 -type d 2>/dev/null || true)
  if [[ -z "$COMPLETED_TESTS" ]]; then
    echo "  ⚠ No completed tests found"
  else
    while IFS= read -r test_dir; do
      slug=$(basename "$test_dir")
      file_count=$(find "$test_dir" -maxdepth 1 -type f | wc -l | tr -d ' ')
      
      has_screenshot=false
      has_analysis=false
      has_console=false
      
      [[ -f "$test_dir/screenshot.png" ]] && has_screenshot=true
      [[ -f "$test_dir/$slug.md" ]] && has_analysis=true
      [[ -f "$test_dir/$slug-dev-console.md" ]] && has_console=true
      
      if $has_screenshot && $has_analysis && $has_console; then
        echo "  ✓ $slug (3/3 files)"
      else
        echo "  ✗ FAIL: $slug — missing files:"
        $has_screenshot || echo "      - screenshot.png"
        $has_analysis || echo "      - $slug.md"
        $has_console || echo "      - $slug-dev-console.md"
        ERRORS=$((ERRORS + 1))
      fi
    done <<< "$COMPLETED_TESTS"
  fi
else
  echo "  ⚠ .tests/.completed/ does not exist"
fi

# Check 4: All analysis files show Verdict: PASS
echo ""
echo "Check 4: All analysis files show Verdict: PASS"
if [[ -d "$COMPLETED_DIR" ]]; then
  ANALYSIS_FILES=$(find "$COMPLETED_DIR" -name "*.md" ! -name "*-dev-console.md" 2>/dev/null || true)
  if [[ -n "$ANALYSIS_FILES" ]]; then
    while IFS= read -r file; do
      if grep -qi "Verdict:.*PASS" "$file" 2>/dev/null; then
        echo "  ✓ $(basename "$file") — PASS"
      elif grep -qi "Verdict:.*FAIL" "$file" 2>/dev/null; then
        echo "  ✗ FAIL: $(basename "$file") — shows FAIL verdict"
        ERRORS=$((ERRORS + 1))
      else
        echo "  ✗ FAIL: $(basename "$file") — no verdict found"
        ERRORS=$((ERRORS + 1))
      fi
    done <<< "$ANALYSIS_FILES"
  fi
fi

# Check 5: All console files show Verdict: CLEAN
echo ""
echo "Check 5: All console files show Verdict: CLEAN"
if [[ -d "$COMPLETED_DIR" ]]; then
  CONSOLE_FILES=$(find "$COMPLETED_DIR" -name "*-dev-console.md" 2>/dev/null || true)
  if [[ -n "$CONSOLE_FILES" ]]; then
    while IFS= read -r file; do
      if grep -qi "Verdict:.*CLEAN" "$file" 2>/dev/null; then
        echo "  ✓ $(basename "$file") — CLEAN"
      elif grep -qi "Verdict:.*HAS.ERROR" "$file" 2>/dev/null; then
        echo "  ✗ FAIL: $(basename "$file") — shows HAS ERRORS verdict"
        ERRORS=$((ERRORS + 1))
      else
        echo "  ✗ FAIL: $(basename "$file") — no verdict found"
        ERRORS=$((ERRORS + 1))
      fi
    done <<< "$CONSOLE_FILES"
  fi
fi

# Summary
echo ""
echo "=== Phase Gate Result ==="
if [[ $ERRORS -eq 0 ]]; then
  COMPLETED_COUNT=$(find "$COMPLETED_DIR" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
  echo "✓ PASSED — $COMPLETED_COUNT test(s) verified, 0 issues"
  echo ""
  echo "Phase is clear to advance."
  exit 0
else
  echo "✗ BLOCKED — $ERRORS issue(s) found"
  echo ""
  echo "Fix all issues above before declaring the phase complete."
  exit 1
fi
