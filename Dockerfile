FROM rust:1.79.0-buster@sha256:3ccb54f58e7853d290648010f0b6cc3432590d304f419485ce022e2b18cd1b46 as builder

WORKDIR /build

RUN git clone https://github.com/TeamFlos/phira-mp.git .

COPY ./fixed_port.patch /build/

RUN patch -p1 -li fixed_port.patch && \
    cargo build --release -p phira-mp-server && \
    ls target/release/

FROM debian:bullseye-slim@sha256:acc5810124f0929ab44fc7913c0ad936b074cbd3eadf094ac120190862ba36c4 as libenv

WORKDIR /libenv

RUN ARCH=$([ "$(uname -m)" = "x86_64" ] && echo "x86_64" || echo "aarch64") && \
    mkdir ${ARCH}-linux-gnu && \
    cp /lib/${ARCH}-linux-gnu/libgcc_s.so.1 ${ARCH}-linux-gnu && \
    ls ${ARCH}-linux-gnu

FROM gcr.io/distroless/base-debian11:nonroot@sha256:9a2cd2e284ea3a4b4c64fc530429f4a1b5f3b8fe4bbab848e858fc4f88d7172b

WORKDIR /app
COPY --from=builder /build/target/release/phira-mp-server /app/
COPY --from=libenv /libenv/ /lib/

ENV RUST_LOG=info
ENV PORT=12346

ENTRYPOINT [ "/app/phira-mp-server" ]