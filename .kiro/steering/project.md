# Project Overview

Goal: monitor and notify registered emails about stock market moves over a certain period of time.

## Architecture

- AWS AgentCore Runtime runs a Python-based AI agent as a container (HTTP server on port 8080)
- AgentCore Browser fetches CNBC pages for stock data via Playwright over CDP
- Claude via Bedrock (IAM auth) analyzes the scraped data on every invocation
- Notifications are sent via SNS (default) or AWS SES (when sender email is configured)
- Infrastructure is managed with Terraform, bootstrap bucket via CloudFormation
- EventBridge Scheduler triggers the agent daily at 3:30pm EST

## AWS Configuration

- Region: us-east-1 (always)

## Technology Stack

- Language: Python 3.12 (AgentCore Runtime HTTP handler — FastAPI/uvicorn on port 8080)
- AI: Claude via AWS Bedrock (IAM auth, no API key needed)
- Data source: CNBC via AgentCore Browser (aws.browser.v1) + Playwright on each invocation
- Infrastructure: Terraform + CloudFormation (bootstrap only)
- Notifications: SNS (default) or SES (optional, when `ses_sender_email_address` is set)
- State backend: Terraform state stored in S3 (bucket bootstrapped via CloudFormation)
- Secrets: none — all config passed via environment variables from AgentCore Runtime

## Python Conventions

### Error Handling
- Raise exceptions with descriptive messages; let FastAPI catch unhandled exceptions and return 500
- Never silently swallow exceptions — always log before re-raising or returning an error response
- Avoid bare `except:` clauses; catch specific exception types

### Dependencies (preferred packages)
- `fastapi` — HTTP server (AgentCore Runtime protocol)
- `uvicorn[standard]` — ASGI server
- `boto3` — AWS SDK (DynamoDB, Bedrock, SES, SNS)
- `bedrock-agentcore` — AgentCore Browser client (`BrowserClient`)
- `playwright` — browser automation over CDP

### Code Style
- Use `snake_case` for variables and functions, `PascalCase` for classes
- Keep functions small and single-purpose
- Document public functions and classes with docstrings
- Avoid deeply nested code; extract logic into named functions
- Use type hints throughout

## Code Organization

Use the following folder structure under `app/`:

```
app/
  main.py          # FastAPI server entrypoint, /invocations + /ping, minimal logic
  controller/      # Request handling, orchestration logic
  model/           # Data structures, domain types
  repository/      # External I/O: AWS SDK calls, browser calls
```

### Rules
1. Aim for simplicity — if it's hard to read, simplify it
2. No Python file can exceed 200 lines
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
