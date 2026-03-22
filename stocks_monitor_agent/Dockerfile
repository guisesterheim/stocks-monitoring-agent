FROM rust:1.91 AS builder

WORKDIR /app
COPY Cargo.toml ./
COPY src ./src

RUN cargo build --release --target aarch64-unknown-linux-gnu

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /app/target/release/stocks_monitor_agent .
COPY templates ./templates

EXPOSE 8080

CMD ["./stocks_monitor_agent"]
