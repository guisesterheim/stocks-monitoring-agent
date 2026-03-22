use anyhow::Result;
use axum::{routing::post, Router};
use tracing_subscriber::EnvFilter;

mod controller;
mod model;
mod repository;

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::fmt()
        .with_env_filter(EnvFilter::from_default_env())
        .json()
        .init();

    let app = Router::new()
        .route("/invoke", post(controller::agent_controller::handle_invocation));

    let listener = tokio::net::TcpListener::bind("0.0.0.0:8080").await?;
    tracing::info!("Stocks monitor agent listening on port 8080");

    axum::serve(listener, app).await?;
    Ok(())
}
