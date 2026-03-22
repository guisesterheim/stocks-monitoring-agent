FROM messense/rust-musl-cross:aarch64-musl AS builder

WORKDIR /app
COPY Cargo.toml ./
COPY src ./src
COPY templates ./templates

RUN cargo build --release --target aarch64-unknown-linux-musl

FROM scratch

COPY --from=builder /app/target/aarch64-unknown-linux-musl/release/stocks_monitor_agent /stocks_monitor_agent
COPY --from=builder /app/templates /templates

EXPOSE 8080

CMD ["/stocks_monitor_agent"]
