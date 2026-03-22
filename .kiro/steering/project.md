# Project Overview

Goal: monitor and notify registered emails about stock market moves over a certain period of time.

## Architecture

- AWS AgentCore Runtime runs a Rust-based AI agent as a container (HTTP server on port 8080)
- AgentCore Browser fetches CNBC pages for stock data
- Claude via Bedrock (IAM auth) analyzes the scraped data on every invocation
- Notifications are sent via SNS (default) or AWS SES (when sender email is configured)
- Infrastructure is managed with Terraform, bootstrap bucket via CloudFormation
- EventBridge Scheduler triggers the agent daily at 3:30pm EST

## AWS Configuration

- Region: us-east-1 (always)

## Technology Stack

- Language: Rust (AgentCore Runtime HTTP handler — axum on port 8080)
- AI: Claude via AWS Bedrock (IAM auth, no API key needed)
- Data source: CNBC via AgentCore Browser on each invocation
- Infrastructure: Terraform + CloudFormation (bootstrap only)
- Notifications: SNS (default) or SES (optional, when `ses_sender_email_address` is set)
- State backend: Terraform state stored in S3 (bootstrap bucket created via CloudFormation)
- Secrets: none — all config passed via environment variables from AgentCore Runtime

## Rust Conventions

Since this project targets developers new to Rust, follow these guidelines:

### Error Handling
- Use `anyhow` for application-level errors (simple, ergonomic)
- Always propagate errors with `?` rather than `.unwrap()` or `.expect()` except in tests
- Avoid `panic!` in production code paths

### Async
- Use `tokio` as the async runtime
- Use `async/await` throughout; avoid blocking calls inside async functions
- HTTP server uses `axum` listening on port 8080

### Dependencies (preferred crates)
- `tokio` — async runtime
- `axum` — HTTP server (AgentCore Runtime protocol)
- `serde` / `serde_json` — serialization
- `reqwest` — HTTP client (for AgentCore Browser calls)
- `aws-sdk-bedrockruntime` — Claude via Bedrock
- `aws-sdk-sesv2` — sending emails via SES
- `aws-sdk-dynamodb` — reading monitored stocks list
- `aws-sdk-sns` — SNS notifications
- `aws-config` — AWS SDK configuration
- `anyhow` — error handling
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
  main.rs          # Axum HTTP server entrypoint, minimal logic
  controller/      # Request handling, orchestration logic
  model/           # Data structures, domain types
  repository/      # External I/O: HTTP calls, AWS SDK calls
```

### Rules
1. Aim for simplicity — if it's hard to read, simplify it
2. No Rust file can exceed 200 lines
3. No folder can contain more than 10 files
4. Use clear, verbose naming — prefer `fetch_stock_market_data_from_cnbc` over `fetch`
5. Separate files by general responsibility, matching the folder structure above

## Terraform Conventions

- All modules live under `terraform/modules/`
- A single `terraform/main.tf` calls all modules
- Remote state is stored in S3 (bucket bootstrapped via CloudFormation)
- Do not hardcode secrets or credentials in Terraform
- Use `variables.tf` and `outputs.tf` per module

## Secrets Management

- No secrets needed — Claude is accessed via Bedrock IAM, all config via env vars
- Never log or expose sensitive values
- Never commit secrets to version control
- `terraform.tfvars` must never be committed (only `.example` file)

## Lifecycle policies

- We always implement lifecycle policies for every AWS service that stores data at rest like ECR, S3, EBS, etc.