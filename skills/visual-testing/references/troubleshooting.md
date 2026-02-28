# Troubleshooting — Common Failure Modes

## Problem: Claude Code stops between tests and waits for feedback

**Symptom:** After completing one test, Claude Code says "Let me know if you'd like me to continue" or "Shall I proceed with the next feature?"

**Root cause:** The autonomy instructions are not prominent enough in context.

**Fix:** Add this at the very top of your prompt or CLAUDE.md:

```
CRITICAL AUTONOMY RULE: Do NOT stop between features. Do NOT ask "should I continue?"
Complete ALL features in the task list autonomously. The only reasons to stop:
1. Need credentials you don't have
2. Destructive action required
3. Failed same test 5+ times
4. Genuinely done with everything
```

## Problem: Claude Code uses `sleep` instead of proper waits

**Symptom:** You see `Bash(sleep 20)` or `Bash(sleep 5)` in the output while waiting for page content.

**Root cause:** Claude Code defaults to sleep when it doesn't know the wait-for API.

**Fix:** Add specific wait patterns to CLAUDE.md:

```
NEVER use sleep/Bash(sleep N) to wait for page content.
Use these instead:
- superpowers-chrome: wait-for 0 "selector" 30000 / wait-text 0 "text" 10000
- Playwright MCP: browser_snapshot → check content → retry if missing
- Generic: eval JS that polls document.querySelector every 500ms
If content doesn't appear in 30s, it's a bug. Fix the code.
```

## Problem: Screenshots show loading spinners or blank pages

**Symptom:** The screenshot.png in the test folder shows a loading indicator, skeleton screen, or blank white page instead of the actual feature.

**Root cause:** Screenshot was taken before the page finished loading.

**Fix:** The protocol requires waiting for full load before screenshot. If this keeps happening:

1. Check that the feature actually loads data (API call succeeds)
2. Check that the wait condition targets the right element
3. Add a more specific wait: wait for the actual data element, not just the page container
4. If the page genuinely never finishes loading, that is a bug — fix the data loading code

## Problem: Empty test folders

**Symptom:** `find .tests -type d -empty` returns folders.

**Root cause:** Test folder was created but the test was never run, or files were accidentally deleted.

**Fix:** Either run the test (create all 3 files) or delete the empty folder. The protocol forbids empty folders at all times.

## Problem: DevTools console check is skipped

**Symptom:** The `{slug}-dev-console.md` file is missing, empty, or says "not checked."

**Root cause:** Claude Code sometimes skips the console check when the screenshot looks correct.

**Fix:** The console check is mandatory. A page can look perfect and have 15 hidden errors (failed API calls, React key warnings, memory leaks, CORS issues). Add to CLAUDE.md:

```
The DevTools console check is EQUALLY important as the screenshot.
You MUST check Console tab AND Network tab for EVERY test. No exceptions.
A test without a console check is an incomplete test.
```

## Problem: Test marked PASS but has console errors

**Symptom:** The `{slug}.md` says PASS but `{slug}-dev-console.md` shows errors.

**Root cause:** The visual analysis and console check were done independently without cross-referencing.

**Fix:** Both must be clean for a PASS verdict. If the screenshot looks correct but the console has errors, the overall verdict is FAIL. Fix the console errors, then re-test.

## Problem: Fix loop runs more than 5 times

**Symptom:** The same test keeps failing after multiple fix attempts.

**Root cause:** The bug may be architectural, not a simple code fix.

**Fix:** After 5 failed iterations:

1. Stop and re-read the error messages from all 5 iterations
2. Look for a pattern — is it the same error or different errors each time?
3. If same error: the fix approach is wrong. Try a completely different approach.
4. If different errors: each fix is introducing new bugs. Revert to the last known good state and try a single, comprehensive fix.
5. If still stuck: stop and ask the human for guidance. This is one of the valid reasons to stop.

## Problem: Tests pass individually but break when combined

**Symptom:** A test passes when run alone but fails after other features are added.

**Root cause:** Feature interactions, shared state, CSS conflicts, or route collisions.

**Fix:** Move the broken test from `.tests/.completed/` back to `.tests/` (regression). Run the fix loop. The fix must account for the interaction with other features.

## Problem: Screenshot doesn't match what the test claims to show

**Symptom:** The `{slug}.md` describes a feature working correctly, but the screenshot shows something different.

**Root cause:** The analysis was written before/without looking at the screenshot, or the screenshot was replaced without updating the analysis.

**Fix:** The analysis MUST describe what the screenshot ACTUALLY shows. If there's a mismatch, re-analyze the screenshot and update the .md file. Never write the analysis from memory — always describe what you see in the image.
