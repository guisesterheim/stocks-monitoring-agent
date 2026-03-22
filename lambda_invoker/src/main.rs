use anyhow::{Context, Result};
use aws_sdk_bedrockagentcore::Client as AgentCoreClient;
use lambda_runtime::{run, service_fn, Error, LambdaEvent};
use serde_json::{json, Value};
use tracing::{error, info};

/// Lambda handler — invoked by EventBridge Scheduler on a daily schedule.
/// Calls InvokeAgentRuntime on the configured AgentCore Runtime ARN.
async fn handler(_event: LambdaEvent<Value>) -> Result<Value, Error> {
    invoke_agentcore_runtime()
        .await
        .map_err(|e| Error::from(e.to_string()))?;

    Ok(json!({ "status": "ok" }))
}

/// Reads the AgentCore Runtime ARN from the environment and invokes it
async fn invoke_agentcore_runtime() -> Result<()> {
    let runtime_arn = std::env::var("AGENTCORE_RUNTIME_ARN")
        .context("AGENTCORE_RUNTIME_ARN env var is missing")?;

    let aws_config = aws_config::defaults(aws_config::BehaviorVersion::latest())
        .load()
        .await;

    let client = AgentCoreClient::new(&aws_config);

    info!("Invoking AgentCore Runtime: {}", runtime_arn);

    let result = client
        .invoke_agent_runtime()
        .agent_runtime_arn(&runtime_arn)
        .runtime_session_id(uuid_session_id())
        .payload(aws_sdk_bedrockagentcore::primitives::Blob::new(
            serde_json::to_vec(&json!({ "trigger": "scheduled_daily_run" }))
                .context("Failed to serialize payload")?,
        ))
        .send()
        .await;

    match result {
        Ok(_) => {
            info!("AgentCore Runtime invoked successfully");
            Ok(())
        }
        Err(err) => {
            error!("AgentCore Runtime invocation failed: {:?}", err);
            Err(anyhow::anyhow!("Failed to invoke AgentCore Runtime: {:?}", err))
        }
    }
}

/// Generates a unique session ID that satisfies AgentCore's constraint:
/// minimum 33 characters, pattern [a-zA-Z0-9][a-zA-Z0-9-_]*
fn uuid_session_id() -> String {
    use std::time::{SystemTime, UNIX_EPOCH};
    let ts = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_millis();
    // "sched-" (6) + timestamp in ms (13) + "-" (1) + zero-padded counter (13) = 33 chars minimum
    format!("sched-{:013}-{:013}", ts, ts)
}

#[tokio::main]
async fn main() -> Result<(), Error> {
    tracing_subscriber::fmt()
        .with_env_filter(
            tracing_subscriber::EnvFilter::from_default_env()
                .add_directive("lambda_invoker=info".parse().unwrap()),
        )
        .json()
        .init();

    run(service_fn(handler)).await
}
