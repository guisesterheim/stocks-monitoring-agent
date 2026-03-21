# Project Overview

Goal: monitor and notify registered emails about stock market moves over a certain period of time.

## Architecture

- AWS Lambda runs a Rust-based AI agent
- The agent scrapes stock data from cnbc.com
- Claude API analyzes the scraped data on every Lambda invocation
- Notifications are sent via AWS SES to registered emails
- Infrastructure is managed with Terraform, secrets stored in AWS Secrets Manager

## AWS Configuration

- Region: us-east-1 (always)

## Technology Stack

- Language: Rust (Lambda handler)
- AI: Claude API (Anthropic) for stock data analysis
- Data source: cnbc.com (scraped on each Lambda invocation)
- Infrastructure: Terraform + CloudFormation (bootstrap only)
- Notifications: AWS SES
- Secrets: AWS Secrets Manager (all secrets, API keys, credentials)
- State backend: Terraform state stored in S3 (bootstrap bucket created via CloudFormation)

## Rust Conventions

Since this project targets developers new to Rust, follow these guidelines:

### Error Handling
- Use `anyhow` for application-level errors (simple, ergonomic)
- Use `thiserror` to define typed errors in library/domain code (models, repositories)
- Always propagate errors with `?` rather than `.unwrap()` or `.expect()` except in tests
- Avoid `panic!` in production code paths

### Async
- Use `tokio` as the async runtime
- Use `async/await` throughout; avoid blocking calls inside async functions
- Use `aws-lambda-rust-runtime` crate for the Lambda handler entrypoint

### Dependencies (preferred crates)
- `tokio` — async runtime
- `serde` / `serde_json` — serialization
- `reqwest` — HTTP client (for cnbc.com scraping and Claude API calls)
- `scraper` — HTML parsing for cnbc.com
- `aws-sdk-sesv2` — sending emails via SES
- `aws-sdk-secretsmanager` — fetching secrets at runtime
- `aws-lambda-rust-runtime` — Lambda handler
- `anyhow` — error handling
- `thiserror` — typed errors
- `tracing` / `tracing-subscriber` — structured logging

### Code Style
- Prefer explicit types over relying on inference when it aids readability
- Use `snake_case` for variables and functions, `PascalCase` for types and structs
- Keep functions small and single-purpose
- Document public functions and structs with `///` doc comments
- Avoid deeply nested code; extract logic into named functions

## Code Organization

Use the following folder structure under `src/`:

```
src/
  main.rs          # Lambda entrypoint only, minimal logic
  controller/      # Request handling, orchestration logic
  model/           # Data structures, domain types
  repository/      # External I/O: HTTP calls, AWS SDK calls, secret fetching
```

### Rules
1. Aim for simplicity — if it's hard to read, simplify it
2. No Rust file can exceed 200 lines
3. No folder can contain more than 10 files
4. Use clear, verbose naming — prefer `fetch_stock_price_from_cnbc` over `fetch`
5. Separate files by general responsibility, matching the folder structure above

## Terraform Conventions

- All modules live under `terraform/modules/`
- A single `terraform/main.tf` calls all modules
- Remote state is stored in S3 (bucket bootstrapped via CloudFormation)
- Do not hardcode secrets or credentials in Terraform — reference Secrets Manager or use data sources
- Use `variables.tf` and `outputs.tf` per module

## Secrets Management

- All secrets (Claude API key, SES credentials, etc.) are stored in AWS Secrets Manager
- Fetch secrets at Lambda cold start using `aws-sdk-secretsmanager`
- Never log or expose secret values
- Never commit secrets to version control
