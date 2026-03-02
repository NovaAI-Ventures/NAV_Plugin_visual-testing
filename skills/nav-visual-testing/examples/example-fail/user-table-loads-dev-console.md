# DevTools Console Check: user-table-loads

## Test Information
- **Date:** 2026-02-21 15:10
- **URL:** http://localhost:3000/admin/users

## Console Output

### Iteration 1
**Errors (Red):**
- `TRPCClientError: No users found` — query returned empty array

**Fix:** Removed `.where(eq(users.active, true))` filter from `server/db.ts:getUsers()`. Users had `active: null`, not `active: true`.

### Iteration 2
**Errors (Red):**
None

**Warnings (Yellow):**
- `Warning: Each child in a list should have a unique "key" prop.` — React key warning in UserTable rows

**Fix:** Added `key={user.id}` to the `<TableRow>` mapping in `UserTable.tsx`.

### Iteration 3 (Final)

### Errors (Red)
None

### Warnings (Yellow)
None

### Info/Debug Logs
- `[tRPC] GET /api/trpc/users.list — 200 (45ms)`

## Network Tab

### Failed Requests
None

### Slow Requests (>3s)
None

## Verdict: CLEAN

## Confirmation
Console and network are clean after 3 iterations. The React key warning from iteration 2 was fixed alongside the pagination bug. The tRPC query completes in 45ms with a 200 status.
