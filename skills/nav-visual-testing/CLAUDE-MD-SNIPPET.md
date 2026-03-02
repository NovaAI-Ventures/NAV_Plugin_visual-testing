# CLAUDE.md — Visual Testing Section (Copy-Paste Ready)

> Copy everything below this line into your project's CLAUDE.md file.

---

## Visual Testing Protocol (MANDATORY)

**Read the `visual-testing` skill SKILL.md for full methodology.**

### Five Modes

| Mode | Trigger | Slug Pattern |
|---|---|---|
| Build & Test | You just built a feature | `{feature-name}` |
| CRUD Verification | Feature creates/reads/updates/deletes data | `{entity}-create`, `{entity}-read`, `{entity}-update`, `{entity}-delete` |
| API Testing | Feature calls backend endpoints | `api-{method}-{resource}` |
| Targeted Bug Fix | User reports a bug | `bugfix-{description}` |
| Regression Re-Test | Recent changes might break things | Same slug, moved back from .completed/ |

### Autonomy — DO NOT STOP

You are an autonomous agent. When executing a task list, testing CRUD, verifying APIs, or fixing bugs:

- Complete each item → test it → fix loop → move to .completed/ → **start the next item immediately**
- **NEVER** pause to ask "should I continue?" or "does this look right?"
- **NEVER** use `sleep` or `Bash(sleep N)` to wait for page content — use `wait-for`, `wait-text`, DOM polling, or retry loops
- **NEVER** stop after completing one test to summarize progress — keep going
- **NEVER** stop after fixing a bug to ask "is this what you meant?" — test it in Chrome, the screenshot tells you
- **NEVER** skip CRUD tests because "the feature is simple"
- **NEVER** skip API tests because "the UI looks fine"

**The ONLY reasons to stop and ask the human:**
1. You need credentials, API keys, or secrets you don't have
2. You need to perform a destructive action (delete production data, deploy, push to main)
3. You have failed the same test 5+ consecutive times and cannot diagnose the root cause
4. Every single task in the list is genuinely complete
5. You cannot reproduce a reported bug and need the user to provide exact reproduction steps

If you are about to type "Let me know if..." or "Shall I continue..." — **delete that and keep working instead.**

### The Core Loop (All Modes)

```
NAVIGATE to feature URL in Chrome
  │
  ▼
WAIT for full page load (NOT sleep — use wait-for/wait-text/DOM polling)
  │
  ▼
INTERACT with the feature (click, fill, submit, scroll)
  │
  ▼
SCREENSHOT → save to .tests/{slug}/screenshot.png
  │
  ▼
ANALYZE screenshot → write .tests/{slug}/{slug}.md
  │
  ▼
CHECK DEVTOOLS Console + Network → write .tests/{slug}/{slug}-dev-console.md
  │
  ▼
VERDICT
  ├── PASS (screenshot OK + console clean)
  │     → mv .tests/{slug} .tests/.completed/{slug}
  │     → Mark todo.md [x]
  │     → START NEXT ITEM IMMEDIATELY
  │
  └── FAIL (visual issue OR console error OR API error)
        → Fix the code
        → REPLACE screenshot.png (overwrite, not append)
        → UPDATE both .md files (add iteration, update verdict)
        → Loop back to NAVIGATE
        → Repeat until PASS
```

### CRUD Testing — MANDATORY for Every Data Feature

If a feature has a form, table, list, or any data — it has CRUD. **Each operation is a separate test.**

```
Feature "users" → create these test folders:
  .tests/users-create/    ← Fill form, submit, verify item appears
  .tests/users-read/      ← Verify table/list renders with real data
  .tests/users-update/    ← Edit item, submit, verify changes saved
  .tests/users-delete/    ← Delete item, verify removed, refresh to confirm
```

**CREATE:** Fill ALL fields → submit → screenshot shows success + item in list
**READ:** Navigate to list → screenshot shows table with real data rows (not empty, not "undefined")
**UPDATE:** Open edit form → change 2+ fields → submit → screenshot shows updated values
**DELETE:** Click delete → confirm → screenshot shows item removed → refresh to verify

### API Testing — VERIFY BEFORE UI Testing

**Rule: Before testing any UI feature, verify the API it depends on.**

```
Test order for "Users" feature:
  1. .tests/api-get-users/      ← Network tab: GET returns user array
  2. .tests/api-post-users/     ← Network tab: POST returns 201
  3. .tests/api-put-users/      ← Network tab: PUT returns 200
  4. .tests/api-delete-users/   ← Network tab: DELETE returns 200/204
  5. .tests/users-read/         ← NOW test UI (API is proven to work)
  6. .tests/users-create/       ← NOW test UI form
  7. .tests/users-update/       ← NOW test UI edit
  8. .tests/users-delete/       ← NOW test UI delete
```

API test screenshots show the **DevTools Network tab** with request URL, status code, and response body.
If an API test fails, fix the API first. Do NOT proceed to UI testing with a broken API.

### Bug Fix Mode — When User Reports a Bug

When the user says "fix this bug" or "X is broken":

1. `mkdir -p .tests/bugfix-{slug}`
2. Navigate to the broken feature in Chrome
3. **Reproduce the bug** — screenshot the broken state
4. Write analysis with `Verdict: FAIL` describing what's broken
5. Check DevTools for errors — write console check
6. **Fix the code**
7. Re-navigate → re-interact → **REPLACE screenshot** → **UPDATE .md files**
8. If still broken → loop back to step 6
9. If fixed → move to `.tests/.completed/bugfix-{slug}/`
10. **Check for regressions** — re-test related features

**Do NOT ask the user if the fix looks right. Test it in Chrome. The screenshot tells you.**

### Three Required Files Per Test

| File | Contains | Cannot Be |
|---|---|---|
| `screenshot.png` | Real Chrome screenshot — UI feature OR Network tab for API tests | Empty, placeholder, blank page, loading spinner |
| `{slug}.md` | Visual analysis with verdict PASS or FAIL | Empty, template-only, no analysis |
| `{slug}-dev-console.md` | Console + network output with verdict CLEAN or HAS ERRORS | Empty, "not checked" |

### Two Directories

| Directory | Meaning |
|---|---|
| `.tests/{slug}/` | Test is **in progress or failing** — work is not done |
| `.tests/.completed/{slug}/` | Test has **passed** — feature is verified and working |

When test PASSES: `mv .tests/{slug} .tests/.completed/{slug}`
When completed test REGRESSES: `mv .tests/.completed/{slug} .tests/{slug}`

### Hard Rules

1. **NO empty folders** — `find .tests -type d -empty` must return nothing
2. **NO placeholder screenshots** — every screenshot.png is a real Chrome capture
3. **3 files per folder** — screenshot.png + {slug}.md + {slug}-dev-console.md
4. **Feature NOT done** until test is in `.tests/.completed/`
5. **CRUD features MUST have 4 separate tests** (create, read, update, delete)
6. **API endpoints MUST be tested BEFORE UI features** that depend on them
7. **API screenshots MUST show Network tab** with request + response
8. **Bug NOT fixed** until verified in Chrome with a PASS screenshot
9. **Phase NOT done** until `.tests/` has zero test folders (all in `.completed/`)
10. **DO NOT STOP** between tests — complete the entire task

### Waiting for Content (NOT sleep)

```
WRONG: Bash(sleep 20)
WRONG: Bash(sleep 5)

RIGHT: wait-for 0 "table tbody tr" 30000
RIGHT: wait-text 0 "Dashboard" 10000
RIGHT: Poll DOM → if (!document.querySelector('.loaded')) retry in 500ms
```

If content doesn't appear within 30 seconds, that is a bug. Fix the code. Do not sleep longer.

### Feature Testing Checklist

For every feature, determine what tests are needed:

```
□ Does this feature call an API? → api-{method}-{resource} tests (test FIRST)
□ Does this feature create data? → {entity}-create test
□ Does this feature display data? → {entity}-read test
□ Does this feature edit data? → {entity}-update test
□ Does this feature delete data? → {entity}-delete test
□ Does this feature have non-CRUD UI? → {feature-name} test
```

### todo.md Integration

```markdown
## User Management
- [x] API: GET /api/users → `.tests/.completed/api-get-users/` ✅
- [x] API: POST /api/users → `.tests/.completed/api-post-users/` ✅
- [x] UI: Users list → `.tests/.completed/users-read/` ✅
- [x] UI: Create user → `.tests/.completed/users-create/` ✅
- [x] UI: Edit user → `.tests/.completed/users-update/` ✅
- [x] UI: Delete user → `.tests/.completed/users-delete/` ✅
- [x] Fix: payment crash → `.tests/.completed/bugfix-payment-crash/` ✅
- [ ] Settings form → `.tests/settings-form-saves/` 🔄
```

### Phase Completion Checklist

```
□ Every feature has tests in .tests/.completed/
□ Every CRUD feature has 4 tests (create/read/update/delete) in .completed/
□ Every API endpoint has a test in .completed/
□ Every bug fix has a test in .completed/
□ Zero folders remain in .tests/ (excluding .completed/)
□ Zero empty folders anywhere in .tests/
□ Every {slug}.md shows Verdict: PASS
□ Every {slug}-dev-console.md shows Verdict: CLEAN
□ Regression check done after every bug fix
```
