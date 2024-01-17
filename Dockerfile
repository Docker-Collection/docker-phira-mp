FROM rust:1.75.0-buster@sha256:5ec27e6bb2954283d19706a2c4fd2a742e2f47db7a41b9b5d94d3f81a0235c43 as builder

WORKDIR /build

RUN git clone https://github.com/TeamFlos/phira-mp.git .

COPY ./fixed_port.patch /build/

RUN patch -p1 -li fixed_port.patch && \
    cargo build --release -p phira-mp-server && \
    ls target/release/

FROM debian:bullseye-slim@sha256:41c3fecb70015fd9c72d6df95573de3f92d5f4f46fdabe8dbd8d2bfb1531594d as libenv

WORKDIR /libenv

RUN ARCH=$([ "$(uname -m)" = "x86_64" ] && echo "x86_64" || echo "aarch64") && \
    mkdir ${ARCH}-linux-gnu && \
    cp /lib/${ARCH}-linux-gnu/libgcc_s.so.1 ${ARCH}-linux-gnu && \
    ls ${ARCH}-linux-gnu

FROM gcr.io/distroless/base-debian11:nonroot@sha256:c9bf6ca0c801a004aaed66d257acffece0eae4b15a080d40fd127b20749fa104

WORKDIR /app
COPY --from=builder /build/target/release/phira-mp-server /app/
COPY --from=libenv /libenv/ /lib/

ENV RUST_LOG=info
ENV PORT=12346

ENTRYPOINT [ "/app/phira-mp-server" ]