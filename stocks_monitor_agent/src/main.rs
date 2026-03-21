use anyhow::Result;
use lambda_runtime::{run, service_fn, Error, LambdaEvent};
use serde_json::Value;
use tracing_subscriber::EnvFilter;

mod controller;
mod model;
mod repository;

#[tokio::main]
async fn main() -> Result<(), Error> {
    tracing_subscriber::fmt()
        .with_env_filter(EnvFilter::from_default_env())
        .json()
        .init();

    run(service_fn(handle_lambda_event)).await
}

async fn handle_lambda_event(event: LambdaEvent<Value>) -> Result<Value, Error> {
    controller::stocks_controller::run_stocks_monitor_pipeline(event)
        .await
        .map_err(|error| Error::from(error.to_string().as_str()))
}
