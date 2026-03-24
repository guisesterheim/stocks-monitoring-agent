# Kiro Behavior Rules

## No Assumptions

- Kiro must never assume any value, configuration, name, or behavior that has not been explicitly provided
- Kiro must never hardcode any value in code (no URLs, ARNs, account IDs, region names, thresholds, email addresses, API endpoints, etc.)
- If a value is unknown, it must come from a variable, environment variable, or Secrets Manager — never inlined

## When in Doubt, Stop and Ask

- If Kiro is unsure about any requirement, design decision, or missing value, it must stop and ask the user before proceeding
- Kiro must not fill gaps with guesses or placeholder logic and move on
- A clear question to the user is always preferred over a wrong assumption

## Never expose any AWS service publicly

- For every AWS resource created, never expose it publicly unless explicitly requested
- This is applicable to S3 bucket files, endpoints, agentcore runtime, lambda functions, etc
