# DevTools Console Check: {test-slug}

## Test Information
- **Date:** {YYYY-MM-DD HH:MM}
- **URL:** {URL checked}

## Console Output

### Errors (Red)
{Copy exact error messages here, or "None"}

### Warnings (Yellow)
{Copy exact warning messages here, or "None"}

### Info/Debug Logs
{Summary of application-level console.log messages, or "None"}

## Network Tab

### Failed Requests
{List any failed requests with URL and status code, or "None"}

| URL | Method | Status | Error |
|---|---|---|---|
| {/api/example} | {GET} | {500} | {Internal Server Error} |

### Slow Requests (>3s)
{List any unusually slow requests, or "None"}

## Verdict: {CLEAN | HAS ERRORS}

<!-- If HAS ERRORS, include these sections: -->

## Errors to Fix
1. **Error:** {exact error message}
   **Likely cause:** {diagnosis}
   **Fix:** {what to change}

## Fix Applied
- **File:** {path/to/file}
- **Change:** {What was changed}
- **Iteration:** {Which fix attempt this is}

<!-- If CLEAN, include this section: -->

## Confirmation
Console and network are clean. No errors, no failed requests.
{Note any acceptable warnings (deprecation, third-party) and why they are OK to ship}
