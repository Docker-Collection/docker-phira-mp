FROM rust:1.71.0-buster as builder

WORKDIR /build

RUN git clone https://github.com/TeamFlos/phira-mp.git .

COPY ./fixed_port.patch /build/

RUN patch -p1 -li fixed_port.patch && \
    cargo build --release -p phira-mp-server && \
    ls target/release/

FROM debian:bullseye-slim as libenv

WORKDIR /libenv

RUN ARCH=$([ "$(uname -m)" = "x86_64" ] && echo "x86_64" || echo "aarch64") && \
    mkdir ${ARCH}-linux-gnu && \
    cp /lib/${ARCH}-linux-gnu/libgcc_s.so.1 ${ARCH}-linux-gnu && \
    ls ${ARCH}-linux-gnu

FROM gcr.io/distroless/base-debian11:nonroot

WORKDIR /app
COPY --from=builder /build/target/release/phira-mp-server /app/
COPY --from=libenv /libenv/ /lib/

ENV RUST_LOG=info
ENV PORT=12346

ENTRYPOINT [ "/app/phira-mp-server" ]