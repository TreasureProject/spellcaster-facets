FROM ghcr.io/catthehacker/ubuntu:act-latest
ARG ARCH=arm64
USER 0
RUN mkdir -p /opt/hostedtoolcache/node/18.12.1/x64
RUN wget -qO- "https://nodejs.org/download/release/v18.12.1/node-v18.12.1-linux-${ARCH}.tar.xz" | tar -Jxf - --strip-components=1 -C "/opt/hostedtoolcache/node/18.12.1/x64"

RUN echo $(ls /opt/hostedtoolcache/node/18.12.1/x64) 
# Rustup
RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- --default-toolchain stable -y

# Add .cargo/bin to PATH
ENV PATH="/root/.cargo/bin:${PATH}"

# Following commands will be executed using 
# bash shell 
SHELL [ "/bin/bash", "-c" ]

# # Install Cargo Crates
# # wasm-pack worker-build 
RUN npm i -g yarn
# # worker-rs
# RUN cargo install -q --git https://github.com/cloudflare/workers-rs