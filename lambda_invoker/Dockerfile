# syntax=docker/dockerfile:1
FROM rust:1.91 AS builder

RUN rustup target add aarch64-unknown-linux-musl
RUN apt-get update && apt-get install -y gcc-aarch64-linux-gnu musl-tools && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY Cargo.toml ./
COPY src ./src

RUN cargo build --release --target aarch64-unknown-linux-musl

# AWS OS-only base image for compiled languages on Lambda (ARM64)
FROM public.ecr.aws/lambda/provided:al2023-arm64

COPY --from=builder /app/target/aarch64-unknown-linux-musl/release/bootstrap ${LAMBDA_RUNTIME_DIR}/bootstrap

CMD ["bootstrap"]
