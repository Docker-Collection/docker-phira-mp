FROM rust:1.72.1-buster@sha256:c1321bd77237a91e51a830c93c63948a0cfefcbf726e4d58e3c92aac1c8ab275 as builder

WORKDIR /build

RUN git clone https://github.com/TeamFlos/phira-mp.git .

COPY ./fixed_port.patch /build/

RUN patch -p1 -li fixed_port.patch && \
    cargo build --release -p phira-mp-server && \
    ls target/release/

FROM debian:bullseye-slim@sha256:3bc5e94a0e8329c102203c3f5f26fd67835f0c81633dd6949de0557867a87fac as libenv

WORKDIR /libenv

RUN ARCH=$([ "$(uname -m)" = "x86_64" ] && echo "x86_64" || echo "aarch64") && \
    mkdir ${ARCH}-linux-gnu && \
    cp /lib/${ARCH}-linux-gnu/libgcc_s.so.1 ${ARCH}-linux-gnu && \
    ls ${ARCH}-linux-gnu

FROM gcr.io/distroless/base-debian11:nonroot@sha256:27647a684d554b6640e32c549dacb3c898c2632fedd0e822b6ffdc24c1c18150

WORKDIR /app
COPY --from=builder /build/target/release/phira-mp-server /app/
COPY --from=libenv /libenv/ /lib/

ENV RUST_LOG=info
ENV PORT=12346

ENTRYPOINT [ "/app/phira-mp-server" ]