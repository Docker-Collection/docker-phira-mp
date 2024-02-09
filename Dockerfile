FROM rust:1.76.0-buster@sha256:58934b206e8c8caa9e3b34cff8e2f4dc6c03d1206d099f74d7892bdbad55fc3e as builder

WORKDIR /build

RUN git clone https://github.com/TeamFlos/phira-mp.git .

COPY ./fixed_port.patch /build/

RUN patch -p1 -li fixed_port.patch && \
    cargo build --release -p phira-mp-server && \
    ls target/release/

FROM debian:bullseye-slim@sha256:8481471cacd29779e7b6fe64a891f4b6771d8c3c7e57bb410542a3db10d1897a as libenv

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