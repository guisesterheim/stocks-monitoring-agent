FROM rust:1.91 AS builder

RUN rustup target add aarch64-unknown-linux-musl
RUN apt-get update && apt-get install -y musl-tools gcc-aarch64-linux-gnu && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY Cargo.toml ./
COPY src ./src

ENV CARGO_TARGET_AARCH64_UNKNOWN_LINUX_MUSL_LINKER=aarch64-linux-gnu-gcc
RUN cargo build --release --target aarch64-unknown-linux-musl

FROM scratch

COPY --from=builder /app/target/aarch64-unknown-linux-musl/release/stocks_monitor_agent /stocks_monitor_agent
COPY --from=builder /app/templates /templates

EXPOSE 8080

CMD ["/stocks_monitor_agent"]
