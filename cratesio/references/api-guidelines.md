# crates.io API Guidelines

## Rate Limits
- crates.io allows approximately 60 requests per minute for unauthenticated users.
- If rate limits are hit, the skill should wait or notify the user to try again later.
- Cache results when performing repeated checks for the same sensor.
