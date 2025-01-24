FROM rust:1.73.0-bullseye as builder

RUN apt-get update && \
    apt-get install -y libopus-dev apt-utils && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /root/koe
COPY . .

RUN --mount=type=cache,target=/root/.cargo/bin \
    --mount=type=cache,target=/root/.cargo/registry/index \
    --mount=type=cache,target=/root/.cargo/registry/cache \
    --mount=type=cache,target=/root/.cargo/git/db \
    --mount=type=cache,target=/root/koe/target \
    cargo build --release --bin koe && \
    cp target/release/koe /usr/local/bin/koe

###

FROM debian:bullseye-slim

RUN apt-get update && \
    apt-get install -y ca-certificates ffmpeg && \
    rm -rf /var/lib/apt/lists/*

# Switch to unpriviledged user
RUN useradd --user-group koe
USER koe

COPY --from=builder /usr/local/bin/koe /usr/local/bin/koe

ARG SENTRY_RELEASE
ENV SENTRY_RELEASE=$SENTRY_RELEASE

ENTRYPOINT ["koe"]
