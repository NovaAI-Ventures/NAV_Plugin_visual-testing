---
name: nav-visual-testing
description: >
  Enforce visual verification of every web feature using Chrome screenshots and DevTools console checks.
  Supports four modes: build-and-test (new features), CRUD verification (every data operation),
  API testing (verify backend endpoints), and targeted bug-fix (user reports a bug).
  Implements a fix-loop that automatically retests until passing, then archives evidence.
  Works with superpowers-chrome, Playwright MCP, or any Chrome automation.
---

# Visual Testing Protocol

Every web feature must be visually verified in Chrome before it can be marked complete. Code that compiles is not code that works. A page that renders is not a page that renders correctly. An API that exists is not an API that returns correct data.

## Setup

Run the init script first:

```bash
bash scripts/init.sh
```

This creates `.tests/.completed/` and verifies Chrome tools are available.

---

## Four Modes of Operation

### Mode 1: Build & Test (New Feature)

**Trigger:** You just implemented a new feature.

```
IMPLEMENT feature → create .tests/{slug}/ → enter CORE LOOP
```

### Mode 2: CRUD Verification

**Trigger:** Any feature that creates, reads, updates, or deletes data.

Every CRUD-capable feature gets **four separate tests**, one per operation. Not one test for the whole feature — four tests.

```
Feature "users" → create 4 test folders:
  .tests/users-create/
  .tests/users-read/
  .tests/users-update/
  .tests/users-delete/
Each enters CORE LOOP independently.
```

### Mode 3: API Testing

**Trigger:** Any feature that calls a backend API endpoint.

Before testing any UI feature, verify the API it depends on. If the API is broken, the UI test is meaningless.

```
Feature depends on GET /api/users → create .tests/api-get-users/ →
  Open Chrome DevTools Network tab →
  Trigger the API call →
  Screenshot the Network tab showing request + response →
  Verify status code, response body, timing →
  enter CORE LOOP
```

### Mode 4: Targeted Bug Fix

**Trigger:** User says "fix this bug" or "this feature is broken."

```
User reports bug → create .tests/bugfix-{slug}/ → REPRODUCE first →
  Can reproduce? → enter CORE LOOP (fix → retest → fix → retest)
  Cannot reproduce? → document in .md, screenshot the working state, ask user for steps
```

### Mode 5: Regression Re-Test

**Trigger:** A previously passing feature might be broken by recent changes.

```
Move .tests/.completed/{slug} back to .tests/{slug} → enter CORE LOOP
```

---

## CRUD Testing — Mandatory for Every Data Feature

**This is not optional.** If a feature has a form, a table, a list, or any data — it has CRUD. Each operation is a separate test.

### How to Identify CRUD Features

Any feature that involves:
- A form that submits data → has **Create**
- A table, list, or detail view → has **Read**
- An edit button, inline editing, or update form → has **Update**
- A delete button, remove action, or archive → has **Delete**

### CRUD Test Slug Convention

```
{entity}-create     → Test creating a new item
{entity}-read       → Test viewing/listing items
{entity}-update     → Test editing an existing item
{entity}-delete     → Test removing an item
```

### CRUD Test Procedure

#### CREATE Test (`{entity}-create`)

1. Navigate to the create form / "Add New" button
2. Screenshot the empty form
3. Fill ALL fields with valid test data
4. Submit the form
5. **Screenshot after submit** — save as `screenshot.png`
6. **Verify in the screenshot:**
   - Success message/toast appeared?
   - Redirected to list/detail view?
   - New item visible in the list/table?
   - All submitted data shown correctly?
7. **Check DevTools:**
   - POST/PUT request sent? Status 200/201?
   - Response body contains the created item?
   - No console errors?
8. If any check fails → fix → retest → loop

#### READ Test (`{entity}-read`)

1. Navigate to the list/table view
2. **Screenshot the list** — save as `screenshot.png`
3. **Verify in the screenshot:**
   - Table/list renders with data rows?
   - Column headers correct?
   - Data values are real (not "undefined", "null", "[object Object]")?
   - Pagination works (if applicable)?
   - Sorting works (if applicable)?
   - Filters work (if applicable)?
4. Click on an item to open detail view (if applicable)
5. **Screenshot the detail view** — update `screenshot.png`
6. **Check DevTools:**
   - GET request sent? Status 200?
   - Response body contains expected data array/object?
   - No console errors?
7. If any check fails → fix → retest → loop

#### UPDATE Test (`{entity}-update`)

1. Navigate to an existing item's edit form
2. Screenshot the pre-filled form
3. **Change at least 2 fields** to new values
4. Submit the form
5. **Screenshot after submit** — save as `screenshot.png`
6. **Verify in the screenshot:**
   - Success message/toast appeared?
   - Updated values reflected in the UI?
   - Old values are gone?
   - Other fields unchanged?
7. **Navigate back to the list** — verify the updated item shows new values
8. **Check DevTools:**
   - PUT/PATCH request sent? Status 200?
   - Request body contains the changed fields?
   - Response body reflects the update?
   - No console errors?
9. If any check fails → fix → retest → loop

#### DELETE Test (`{entity}-delete`)

1. Navigate to the list view, note the item count
2. Click delete on an item
3. **If confirmation dialog appears** — screenshot it, then confirm
4. **Screenshot after deletion** — save as `screenshot.png`
5. **Verify in the screenshot:**
   - Item removed from the list?
   - Item count decreased?
   - Success message/toast appeared?
   - No orphaned data or broken references?
6. **Refresh the page** — verify item is still gone (not just hidden)
7. **Check DevTools:**
   - DELETE request sent? Status 200/204?
   - No console errors?
   - Subsequent GET request returns list without deleted item?
8. If any check fails → fix → retest → loop

### CRUD Edge Cases to Test

After the basic CRUD passes, also verify:

| Edge Case | What to Test |
|---|---|
| Empty form submit | Submit with required fields empty — error messages shown? |
| Duplicate create | Create same item twice — proper error handling? |
| Edit non-existent | Try to edit a deleted item — graceful error? |
| Delete with dependencies | Delete item referenced by others — cascade or error? |
| Concurrent edit | (If applicable) Two edits at once — conflict handling? |
| Large data | Create item with max-length fields — no truncation? |

---

## API Testing — Verify Before UI Testing

**Rule: Before testing any UI feature, verify the API it depends on.**

An empty table is usually a broken API, not a broken table component. A form that doesn't submit is usually a broken endpoint, not a broken button. Test the API first.

### How to Identify APIs to Test

1. **Look at the feature code** — find all `fetch()`, `axios`, `trpc.*`, or API client calls
2. **List every endpoint** the feature depends on
3. **Each endpoint gets its own test folder**

### API Test Slug Convention

```
api-{method}-{resource}     → e.g., api-get-users, api-post-orders, api-delete-item
```

### API Test Procedure

1. **Create test folder:** `mkdir -p .tests/api-{method}-{resource}`
2. **Open Chrome** and navigate to a page that triggers the API call (or use the browser console / DevTools to trigger it directly)
3. **Open DevTools → Network tab** BEFORE triggering the call
4. **Trigger the API call** — navigate to the page, click a button, or run `fetch()` in console
5. **Click on the request in the Network tab**
6. **Screenshot the Network tab** showing:
   - Request URL and method
   - Status code
   - Response headers
   - Response body (Preview or Response tab)
7. **Save as `screenshot.png`**
8. **Write `api-{method}-{resource}.md`:**

```markdown
# API Test: {METHOD} {endpoint}

## Request
- **URL:** /api/trpc/feature.endpoint
- **Method:** GET/POST/PUT/DELETE
- **Headers:** (relevant ones)
- **Body:** (if POST/PUT — show the payload)

## Response
- **Status:** 200 / 201 / 400 / 500
- **Time:** 45ms
- **Body:** (summarize or paste key fields)

## Checks
- [ ] Status code is 2xx
- [ ] Response body has expected structure
- [ ] Response body has real data (not empty array, not null)
- [ ] Response time < 2 seconds
- [ ] No CORS errors
- [ ] Content-Type header correct

## Verdict: PASS / FAIL
```

9. **Write `api-{method}-{resource}-dev-console.md`** — check for any console errors triggered by the API call
10. **If FAIL** → fix the backend code → re-trigger → replace screenshot → update .md → loop
11. **If PASS** → move to `.tests/.completed/api-{method}-{resource}/`

### API Testing Order

Test APIs **before** testing the UI features that depend on them:

```
Phase order for a "Users" feature:
  1. .tests/api-get-users/          → Verify list endpoint works
  2. .tests/api-post-users/         → Verify create endpoint works
  3. .tests/api-put-users/          → Verify update endpoint works
  4. .tests/api-delete-users/       → Verify delete endpoint works
  5. .tests/users-read/             → Now test the UI list (API is proven)
  6. .tests/users-create/           → Now test the UI form (API is proven)
  7. .tests/users-update/           → Now test the UI edit (API is proven)
  8. .tests/users-delete/           → Now test the UI delete (API is proven)
```

If an API test fails, fix the API first. Do not proceed to UI testing with a broken API.

---

## Targeted Bug Fix Procedure

When the user says something like:
- "Fix this bug: the payment form crashes"
- "The dashboard is showing wrong data"
- "This button doesn't work"

**Your response is NOT to ask questions. Your response is:**

1. Create `.tests/bugfix-{slug}/`
2. Navigate to the feature in Chrome
3. Try to reproduce what the user described
4. Screenshot the current state
5. Check DevTools console
6. If you can see the bug → fix it → retest → loop until fixed
7. If you cannot see the bug → document what you see, screenshot it, ask user for exact steps

**After fixing the reported bug:**
- Check if the fix could have broken anything else
- Re-test related features (regression check)
- Move any regressions from `.completed/` back to `.tests/` and fix them
- Only stop when the reported bug is fixed AND no regressions are found

---

## The Core Loop

All modes converge into this loop. No exceptions. No shortcuts.

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  NAVIGATE → WAIT → INTERACT → SCREENSHOT → ANALYZE → DEVTOOLS  │
│       ↑                                                  │      │
│       │                              PASS? ──→ move to .completed/
│       │                                │       → update todo.md [x]
│       │                                │       → START NEXT IMMEDIATELY
│       │                              FAIL?                      │
│       │                                │                        │
│       └──── FIX CODE ←────────────────┘                        │
│             (replace screenshot, update .md, loop back)         │
│                                                                 │
│  If iteration >= 5: step back, rethink approach, or ask human   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**The loop is the protocol.** Everything else is setup for the loop.

---

## Autonomy — DO NOT STOP

When executing any mode — building features, testing CRUD, verifying APIs, or fixing bugs:

- Complete each item → test → fix loop → .completed/ → **start next item immediately**
- **NEVER** pause to ask "should I continue?" or "does this look right?"
- **NEVER** use `sleep` or `Bash(sleep N)` to wait for page content
- **NEVER** stop after one test to summarize progress
- **NEVER** ask permission to fix a bug — just fix it and re-test
- **NEVER** stop after fixing a bug to ask "is this what you meant?"
- **NEVER** skip CRUD tests because "the feature is simple"
- **NEVER** skip API tests because "the UI looks fine"

**The ONLY reasons to stop:**
1. Need credentials/API keys you don't have
2. Destructive action required (delete production data, push to main)
3. Failed same test 5+ consecutive times, cannot diagnose
4. Every task in the list is genuinely complete
5. Cannot reproduce a reported bug — need user to provide reproduction steps

**If you are about to type "Let me know if..." — delete that and keep working.**

**If you just fixed a bug — do NOT ask if it's fixed. Test it. The screenshot tells you.**

---

## Directory Structure

```
.tests/                                    ← ACTIVE: being tested or failing
  api-get-users/                           ← API test in progress
    screenshot.png                         ← Network tab screenshot
    api-get-users.md
    api-get-users-dev-console.md
  users-create/                            ← CRUD create test in progress
    screenshot.png
    users-create.md
    users-create-dev-console.md
  bugfix-payment-crash/                    ← Bug fix in progress
    screenshot.png
    bugfix-payment-crash.md
    bugfix-payment-crash-dev-console.md

.tests/.completed/                         ← VERIFIED: all passing
  api-get-users/                           ← API verified ✅
  api-post-users/                          ← API verified ✅
  users-read/                              ← CRUD Read verified ✅
  users-create/                            ← CRUD Create verified ✅
  users-update/                            ← CRUD Update verified ✅
  users-delete/                            ← CRUD Delete verified ✅
  dashboard-overview/                      ← Feature verified ✅
  bugfix-payment-crash/                    ← Bug fix verified ✅
```

**Movement rules:**
- Test PASSES → `mv .tests/{slug} .tests/.completed/{slug}`
- Completed test REGRESSES → `mv .tests/.completed/{slug} .tests/{slug}`
- Always **move**, never copy. One copy exists at any time.

---

## Three Required Files

Every test folder MUST have exactly 3 files:

| File | Contains | Cannot Be |
|---|---|---|
| `screenshot.png` | Real Chrome screenshot — UI feature OR DevTools Network tab for API tests | Empty, placeholder, blank page, loading spinner, error page |
| `{slug}.md` | Visual analysis with `Verdict: PASS` or `Verdict: FAIL` | Empty, template-only, no actual analysis |
| `{slug}-dev-console.md` | Console output + network check with `Verdict: CLEAN` or `Verdict: HAS ERRORS` | Empty, "not checked", missing network check |

For API tests, the screenshot shows the **Network tab** with request/response details.
For CRUD tests, the screenshot shows the **UI after the operation** (created item in list, updated values, empty row after delete).
For bug fixes, the screenshot shows the **LATEST state** after fix attempts.

---

## Slug Naming Convention

| Mode | Pattern | Example |
|---|---|---|
| New feature | `{feature-name}` | `dashboard-overview`, `login-form-validates` |
| CRUD test | `{entity}-{operation}` | `users-create`, `orders-read`, `products-update`, `items-delete` |
| API test | `api-{method}-{resource}` | `api-get-users`, `api-post-orders`, `api-delete-item` |
| Bug fix | `bugfix-{description}` | `bugfix-payment-crash`, `bugfix-empty-dashboard` |
| Regression | Same slug as original | Moved back from `.completed/` |

---

## Step-by-Step Procedure

### 1. Create test folder

```bash
mkdir -p .tests/{slug}
```

### 2. Navigate and wait

Open Chrome, navigate to the feature URL. **Wait for full load:**

```
WRONG: Bash(sleep 20)
WRONG: "Let me wait a moment..."

RIGHT: wait-for 0 "table tbody tr" 30000
RIGHT: wait-text 0 "Dashboard" 10000
RIGHT: Poll DOM until content appears or 30s timeout
RIGHT: Check snapshot, if loading → wait 2s → re-snapshot
```

If content doesn't appear in 30 seconds, that is a **bug**. Fix it. Don't sleep longer.

### 3. Interact with the feature

| Feature Type | Required Interaction |
|---|---|
| Data table | Verify rows populated. Click sort. Try pagination. |
| Form (Create) | Fill ALL fields. Submit. Verify success + item appears. |
| Form (Update) | Load existing data. Change 2+ fields. Submit. Verify changes saved. |
| Delete action | Click delete. Confirm dialog. Verify item removed. Refresh to confirm. |
| Chart | Verify data points. Hover tooltips. Check axes. |
| Dialog | Open. Fill. Submit. Verify close + result. |
| Navigation | Click. Verify destination loads. |
| API endpoint | Open Network tab. Trigger call. Verify status + response body. |
| Bug report | Reproduce the exact steps the user described. |

### 4. Screenshot

Save to `.tests/{slug}/screenshot.png`. Must show the feature post-interaction with real data visible.

For API tests: screenshot the **Network tab** showing request URL, status, and response body.
For CRUD tests: screenshot the **UI result** of the operation.

**Automatic FAILs:** blank page, loading spinner, error page, no data, wrong page, empty Network tab.

### 5. Analyze screenshot

Write `.tests/{slug}/{slug}.md` using the template in `references/analysis-template.md`.

Check: renders? real data? layout correct? text readable? colors right? charts populated? tables have rows? forms visible? CRUD operation succeeded? API returned expected data? Bug reproduced/fixed?

### 6. Check DevTools

Open Console tab — copy all errors and warnings.
Open Network tab — copy any failed requests (4xx, 5xx, CORS, timeout).

Write `.tests/{slug}/{slug}-dev-console.md` using the template in `references/console-template.md`.

| Severity | Action |
|---|---|
| Console error (red) | **MUST FIX** |
| Network failure (4xx/5xx) | **MUST FIX** |
| React warning | **MUST FIX** |
| CORS error | **MUST FIX** |
| Deprecation warning | Document, OK to ship |
| Third-party warning | Document, OK to ship |

### 7. Verdict

**PASS** = screenshot shows feature/API/CRUD working correctly AND console is clean → move to `.completed/`
**FAIL** = any visual issue OR any console error OR API returns wrong data → enter fix loop

### 8. Fix loop (THE CRITICAL PART)

```
FAIL → identify root cause from screenshot + console evidence →
  fix code → wait for hot reload / rebuild →
  re-navigate to same URL → re-interact same steps →
  REPLACE screenshot.png (overwrite, not append) →
  UPDATE {slug}.md (add iteration, update verdict) →
  UPDATE {slug}-dev-console.md (fresh console check) →
  re-check verdict →
    PASS? → move to .completed/, start next
    FAIL? → loop back to "fix code"
```

**Critical rules for the fix loop:**
- Always **REPLACE** screenshot.png — the file shows the LATEST state only
- Always **UPDATE** both .md files — add a new iteration section, update the verdict
- Never append screenshots — one screenshot per folder, always the latest
- Never leave stale analysis — the .md must match the current screenshot
- If on iteration 5+, step back and rethink. See `references/troubleshooting.md`

### 9. Move to .completed/

```bash
mv .tests/{slug} .tests/.completed/{slug}
```

Update todo.md: `- [x] Feature name → .tests/.completed/{slug}/ ✅`

**Then immediately start the next item. Do not stop. Do not summarize. Do not ask.**

---

## Hard Rules

| # | Rule |
|---|---|
| 1 | NO empty folders — `find .tests -type d -empty` must return nothing |
| 2 | NO placeholder screenshots — every screenshot.png is a real Chrome capture |
| 3 | NO loading/blank/error screenshots — those are FAILs, fix the code |
| 4 | 3 files per folder — screenshot.png + {slug}.md + {slug}-dev-console.md |
| 5 | Feature NOT done until test is in `.tests/.completed/` |
| 6 | Phase NOT done until `.tests/` has zero non-hidden directories |
| 7 | todo.md NOT marked [x] until test is in `.tests/.completed/` |
| 8 | DO NOT STOP between tests — complete the entire task |
| 9 | DO NOT use sleep — use wait-for/wait-text/DOM polling |
| 10 | DO NOT ask "should I continue?" — just continue |
| 11 | Bug fix NOT done until verified in Chrome, not just in code |
| 12 | After any bug fix, check for regressions in related features |
| 13 | CRUD features MUST have 4 separate tests (create, read, update, delete) |
| 14 | API endpoints MUST be tested BEFORE the UI features that depend on them |
| 15 | API test screenshots MUST show the Network tab with request + response |
| 16 | DO NOT skip CRUD tests because "the feature is simple" |
| 17 | DO NOT skip API tests because "the UI looks fine" |

---

## Feature Testing Checklist

For every feature, determine what tests are needed:

```
□ Does this feature call an API?
    YES → Create api-{method}-{resource} tests for each endpoint
    Test APIs FIRST before UI tests

□ Does this feature create data?
    YES → Create {entity}-create test

□ Does this feature display data?
    YES → Create {entity}-read test

□ Does this feature edit data?
    YES → Create {entity}-update test

□ Does this feature delete data?
    YES → Create {entity}-delete test

□ Does this feature have non-CRUD UI?
    YES → Create {feature-name} test (charts, dashboards, navigation, etc.)
```

**Example: "User Management" feature needs these tests:**
```
.tests/api-get-users/          ← API: list users
.tests/api-post-users/         ← API: create user
.tests/api-put-users/          ← API: update user
.tests/api-delete-users/       ← API: delete user
.tests/users-read/             ← UI: table renders with data
.tests/users-create/           ← UI: add user form works
.tests/users-update/           ← UI: edit user form works
.tests/users-delete/           ← UI: delete user action works
```

That's 8 tests for one feature. This is correct. This is thorough.

---

## Phase Gate

Before declaring any phase or task complete, run:

```bash
bash scripts/verify.sh
```

This checks: no empty folders, all tests have 3 files, all in .completed/ show PASS + CLEAN, no active tests remaining.

---

## todo.md Integration

```markdown
## User Management
- [x] API: GET /api/users → `.tests/.completed/api-get-users/` ✅
- [x] API: POST /api/users → `.tests/.completed/api-post-users/` ✅
- [x] API: PUT /api/users → `.tests/.completed/api-put-users/` ✅
- [x] API: DELETE /api/users → `.tests/.completed/api-delete-users/` ✅
- [x] UI: Users list → `.tests/.completed/users-read/` ✅
- [x] UI: Create user → `.tests/.completed/users-create/` ✅
- [x] UI: Edit user → `.tests/.completed/users-update/` ✅
- [x] UI: Delete user → `.tests/.completed/users-delete/` ✅

## Bug Fixes
- [x] Fix: payment crash → `.tests/.completed/bugfix-payment-crash/` ✅
- [ ] Fix: empty table → `.tests/bugfix-empty-table/` 🔄
```

| Symbol | Meaning |
|---|---|
| ✅ | Passed, in `.tests/.completed/` |
| 🔄 | In progress or fix loop, in `.tests/` |
| (not started) | No test folder yet |

---

## Helper Scripts

- `scripts/init.sh` — Initialize `.tests/.completed/`, check prerequisites
- `scripts/verify.sh` — Phase gate verification (run before declaring phase complete)
- `scripts/report.sh` — Generate summary report of all tests (active + completed)

Run with `--help` for usage. Use as black boxes.

## Reference Files

- `references/analysis-template.md` — Template for `{slug}.md` visual analysis files
- `references/console-template.md` — Template for `{slug}-dev-console.md` console check files
- `references/troubleshooting.md` — Common failure modes and fixes (read when stuck)
- `examples/example-pass/` — Example of a passing test folder with all 3 files
- `examples/example-fail/` — Example of a failing test folder showing 3 fix iterations
- `examples/example-bugfix/` — Example of a targeted bug fix with 3 iterations
- `examples/example-crud/` — Example of a full CRUD test set for a "products" entity
- `examples/example-api/` — Example of an API endpoint test with Network tab screenshot
